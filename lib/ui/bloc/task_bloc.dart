import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../../dependancy/useCases/home_use_case.dart';
import '../../services/local-storage/shared_prefs_services.dart';
import '../../services/services_handle.dart';
import '../../model/team_task_res_model.dart';
import '../../model/offline_request_model.dart';
import '../../services/constants/end_points.dart';
import 'task_event_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final HomeUseCase useCase;
  final SharedPrefsService sharedPrefs;
  
  static const int _pageSize = 8;
  StreamSubscription? _connectivitySubscription;

  TaskBloc({
    required this.useCase,
    required this.sharedPrefs,
  }) : super(TaskInitial()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<ToggleCompleteEvent>(_onToggleComplete);
    on<SearchFilterEvent>(_onSearchFilter);
    on<SyncOfflineChangesEvent>(_onSyncOfflineChanges);

    // Listen to network changes to automatically trigger offline sync
    _connectivitySubscription = locator<Connectivity>()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty &&
          (results.contains(ConnectivityResult.wifi) ||
              results.contains(ConnectivityResult.mobile))) {
        add(SyncOfflineChangesEvent());
      }
    });
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }

  // --- Handlers ---

  Future<void> _onLoadTasks(LoadTasksEvent event, Emitter<TaskState> emit) async {
    final currentState = state;
    
    // pagination: load more from existing list
    if (event.loadMore && currentState is TaskLoaded) {
      if (currentState.hasReachedMax) return;
      final nextPage = currentState.page + 1;
      final int limit = nextPage * _pageSize;
      final paged = currentState.filteredTasks.take(limit).toList();
      final reachedMax = paged.length >= currentState.filteredTasks.length;
      
      emit(currentState.copyWith(
        pagedTasks: paged,
        page: nextPage,
        hasReachedMax: reachedMax,
      ));
      return;
    }

    // Refresh or initial load
    if (event.forceRefresh || currentState is! TaskLoaded) {
      emit(TaskLoading());
    }

    final result = await useCase.callTeamTaskList(forceRefresh: event.forceRefresh);

    result.fold(
      (failure) {
        emit(TaskError(failure.message ?? "Failed to fetch tasks"));
      },
      (tasks) {
        // Build initial filtered list using default filters
        final query = currentState is TaskLoaded ? currentState.searchQuery : "";
        final status = currentState is TaskLoaded ? currentState.statusFilter : "All";
        final priority = currentState is TaskLoaded ? currentState.priorityFilter : "All";

        final filtered = _filterTasksList(tasks, query, status, priority);
        final paged = filtered.take(_pageSize).toList();

        emit(TaskLoaded(
          allTasks: tasks,
          filteredTasks: filtered,
          pagedTasks: paged,
          hasReachedMax: paged.length >= filtered.length,
          page: 1,
          searchQuery: query,
          statusFilter: status,
          priorityFilter: priority,
          isSyncing: false,
        ));

        // Auto trigger synchronization of any offline mutations
        add(SyncOfflineChangesEvent());
      },
    );
  }

  Future<void> _onCreateTask(CreateTaskEvent event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final int newId = DateTime.now().millisecondsSinceEpoch;
      final newTask = TeamTaskResModel(
        id: newId,
        taskName: event.title,
        status: taskStatus.pending,
        taskDescription: event.description,
        dueDate: event.dueDate,
        priority: taskPriority.values.firstWhere(
          (e) => e.name.toLowerCase() == event.priority.toLowerCase(),
          orElse: () => taskPriority.medium,
        ),
      );

      final updatedTasks = [newTask, ...currentState.allTasks];
      await sharedPrefs.cacheTasks(updatedTasks);

      // Add to offline queue
      final queueItem = OfflineRequestModel(
        queueId: _generateQueueId(),
        action: 'create',
        taskId: newId,
        taskData: newTask.toJson(),
      );
      await _enqueueRequest(queueItem);

      // Update state immediately
      final filtered = _filterTasksList(
        updatedTasks,
        currentState.searchQuery,
        currentState.statusFilter,
        currentState.priorityFilter,
      );
      final paged = filtered.take(currentState.page * _pageSize).toList();

      emit(currentState.copyWith(
        allTasks: updatedTasks,
        filteredTasks: filtered,
        pagedTasks: paged,
        hasReachedMax: paged.length >= filtered.length,
      ));

      add(SyncOfflineChangesEvent());
    }
  }

  Future<void> _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final updatedTasks = currentState.allTasks.map((task) {
        if (task.id == event.id) {
          return TeamTaskResModel(
            id: event.id,
            taskName: event.title,
            status: taskStatus.values.firstWhere(
              (s) => s.name.toLowerCase() == event.status.toLowerCase(),
              orElse: () => taskStatus.pending,
            ),
            taskDescription: event.description,
            dueDate: event.dueDate,
            priority: taskPriority.values.firstWhere(
              (p) => p.name.toLowerCase() == event.priority.toLowerCase(),
              orElse: () => taskPriority.medium,
            ),
          );
        }
        return task;
      }).toList();

      await sharedPrefs.cacheTasks(updatedTasks);

      // Add to offline queue
      final updatedTask = updatedTasks.firstWhere((t) => t.id == event.id);
      final queueItem = OfflineRequestModel(
        queueId: _generateQueueId(),
        action: 'update',
        taskId: event.id,
        taskData: updatedTask.toJson(),
      );
      await _enqueueRequest(queueItem);

      // Update state immediately
      final filtered = _filterTasksList(
        updatedTasks,
        currentState.searchQuery,
        currentState.statusFilter,
        currentState.priorityFilter,
      );
      final paged = filtered.take(currentState.page * _pageSize).toList();

      emit(currentState.copyWith(
        allTasks: updatedTasks,
        filteredTasks: filtered,
        pagedTasks: paged,
        hasReachedMax: paged.length >= filtered.length,
      ));

      add(SyncOfflineChangesEvent());
    }
  }

  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final updatedTasks = currentState.allTasks.where((task) => task.id != event.id).toList();
      await sharedPrefs.cacheTasks(updatedTasks);

      // Add to offline queue
      final queueItem = OfflineRequestModel(
        queueId: _generateQueueId(),
        action: 'delete',
        taskId: event.id,
      );
      await _enqueueRequest(queueItem);

      // Update state immediately
      final filtered = _filterTasksList(
        updatedTasks,
        currentState.searchQuery,
        currentState.statusFilter,
        currentState.priorityFilter,
      );
      final paged = filtered.take(currentState.page * _pageSize).toList();

      emit(currentState.copyWith(
        allTasks: updatedTasks,
        filteredTasks: filtered,
        pagedTasks: paged,
        hasReachedMax: paged.length >= filtered.length,
      ));

      add(SyncOfflineChangesEvent());
    }
  }

  Future<void> _onToggleComplete(ToggleCompleteEvent event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final updatedTasks = currentState.allTasks.map((task) {
        if (task.id == event.id) {
          return TeamTaskResModel(
            id: task.id,
            taskName: task.taskName,
            status: event.isCompleted ? taskStatus.completed : taskStatus.pending,
            taskDescription: task.taskDescription,
            dueDate: task.dueDate,
            priority: task.priority,
          );
        }
        return task;
      }).toList();

      await sharedPrefs.cacheTasks(updatedTasks);

      // Add to offline queue
      final updatedTask = updatedTasks.firstWhere((t) => t.id == event.id);
      final queueItem = OfflineRequestModel(
        queueId: _generateQueueId(),
        action: 'toggle_complete',
        taskId: event.id,
        taskData: updatedTask.toJson(),
      );
      await _enqueueRequest(queueItem);

      // Update state immediately
      final filtered = _filterTasksList(
        updatedTasks,
        currentState.searchQuery,
        currentState.statusFilter,
        currentState.priorityFilter,
      );
      final paged = filtered.take(currentState.page * _pageSize).toList();

      emit(currentState.copyWith(
        allTasks: updatedTasks,
        filteredTasks: filtered,
        pagedTasks: paged,
        hasReachedMax: paged.length >= filtered.length,
      ));

      add(SyncOfflineChangesEvent());
    }
  }

  void _onSearchFilter(SearchFilterEvent event, Emitter<TaskState> emit) {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final query = event.query ?? currentState.searchQuery;
      final status = event.statusFilter ?? currentState.statusFilter;
      final priority = event.priorityFilter ?? currentState.priorityFilter;

      final filtered = _filterTasksList(currentState.allTasks, query, status, priority);
      final paged = filtered.take(_pageSize).toList();

      emit(currentState.copyWith(
        filteredTasks: filtered,
        pagedTasks: paged,
        hasReachedMax: paged.length >= filtered.length,
        page: 1,
        searchQuery: query,
        statusFilter: status,
        priorityFilter: priority,
      ));
    }
  }

  Future<void> _onSyncOfflineChanges(SyncOfflineChangesEvent event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is! TaskLoaded) return;
    if (currentState.isSyncing) return;

    final List<OfflineRequestModel> queue = sharedPrefs.getOfflineQueue();
    if (queue.isEmpty) return;

    // Check connectivity
    final isConnected = await _checkConnectivity();
    if (!isConnected) return;

    emit(currentState.copyWith(isSyncing: true, syncError: null));

    final dio = locator.get<Dio>();
    final List<OfflineRequestModel> remainingQueue = List.from(queue);
    bool hasFailed = false;
    String? lastError;

    for (final item in queue) {
      try {
        if (item.action == 'create') {
          // Send request with body data omitting local id
          final data = Map<String, dynamic>.from(item.taskData ?? {});
          data.remove('id');
          await dio.post(EndPoints.taskList, data: data);
        } else if (item.action == 'update' || item.action == 'toggle_complete') {
          final data = item.taskData ?? {};
          await dio.put("${EndPoints.taskList}/${item.taskId}", data: data);
        } else if (item.action == 'delete') {
          await dio.delete("${EndPoints.taskList}/${item.taskId}");
        }
        
        // Remove successfully synced item from the tracking queue
        remainingQueue.removeWhere((q) => q.queueId == item.queueId);
      } catch (e) {
        hasFailed = true;
        lastError = e.toString();
        // Break to avoid out-of-order execution if a request fails
        break;
      }
    }

    await sharedPrefs.saveOfflineQueue(remainingQueue);

    emit(currentState.copyWith(
      isSyncing: false,
      syncError: hasFailed ? lastError : null,
    ));
  }

  // --- Helpers ---

  List<TeamTaskResModel> _filterTasksList(
    List<TeamTaskResModel> tasks,
    String query,
    String statusFilter,
    String priorityFilter,
  ) {
    return tasks.where((task) {
      // 1. Title Search
      final name = (task.taskName ?? '').toLowerCase();
      final matchesQuery = name.contains(query.toLowerCase());

      // 2. Status filter
      bool matchesStatus = true;
      if (statusFilter == "Pending") {
        matchesStatus = task.status == taskStatus.pending;
      } else if (statusFilter == "In Progress") {
        matchesStatus = task.status == taskStatus.inProgress;
      } else if (statusFilter == "Completed") {
        matchesStatus = task.status == taskStatus.completed;
      }

      // 3. Priority filter
      bool matchesPriority = true;
      if (priorityFilter != "All") {
        matchesPriority = task.priority?.name.toLowerCase() == priorityFilter.toLowerCase();
      }

      return matchesQuery && matchesStatus && matchesPriority;
    }).toList();
  }

  Future<bool> _checkConnectivity() async {
    final connectivityList = await locator<Connectivity>().checkConnectivity();
    if (connectivityList.isEmpty) return false;
    return connectivityList.contains(ConnectivityResult.wifi) ||
        connectivityList.contains(ConnectivityResult.mobile);
  }

  String _generateQueueId() {
    final rand = Random().nextInt(1000000);
    return "${DateTime.now().millisecondsSinceEpoch}_$rand";
  }

  Future<void> _enqueueRequest(OfflineRequestModel item) async {
    final currentQueue = sharedPrefs.getOfflineQueue();
    currentQueue.add(item);
    await sharedPrefs.saveOfflineQueue(currentQueue);
  }
}
