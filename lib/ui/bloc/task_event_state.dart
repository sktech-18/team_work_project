import 'package:equatable/equatable.dart';
import '../../model/team_task_res_model.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskEvent {
  final bool forceRefresh;
  final bool loadMore;

  const LoadTasksEvent({this.forceRefresh = false, this.loadMore = false});

  @override
  List<Object?> get props => [forceRefresh, loadMore];
}

class CreateTaskEvent extends TaskEvent {
  final String title;
  final String description;
  final String priority;
  final String dueDate;

  const CreateTaskEvent({
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
  });

  @override
  List<Object?> get props => [title, description, priority, dueDate];
}

class UpdateTaskEvent extends TaskEvent {
  final dynamic id;
  final String title;
  final String description;
  final String priority;
  final String dueDate;
  final String status;

  const UpdateTaskEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.status,
  });

  @override
  List<Object?> get props => [id, title, description, priority, dueDate, status];
}

class DeleteTaskEvent extends TaskEvent {
  final dynamic id;

  const DeleteTaskEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class ToggleCompleteEvent extends TaskEvent {
  final dynamic id;
  final bool isCompleted;

  const ToggleCompleteEvent({required this.id, required this.isCompleted});

  @override
  List<Object?> get props => [id, isCompleted];
}

class SearchFilterEvent extends TaskEvent {
  final String? query;
  final String? statusFilter;
  final String? priorityFilter;

  const SearchFilterEvent({
    this.query,
    this.statusFilter,
    this.priorityFilter,
  });

  @override
  List<Object?> get props => [query, statusFilter, priorityFilter];
}

class SyncOfflineChangesEvent extends TaskEvent {}

// --- STATES ---

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TeamTaskResModel> allTasks; // All cached tasks
  final List<TeamTaskResModel> filteredTasks; // Tasks matching status/priority and search query
  final List<TeamTaskResModel> pagedTasks; // Tasks visible in current page
  final bool hasReachedMax;
  final int page;
  final String searchQuery;
  final String statusFilter; // "All", "Pending", "Completed"
  final String priorityFilter; // "All", "High", "Medium", "Low"
  final bool isSyncing;
  final String? syncError;

  const TaskLoaded({
    required this.allTasks,
    required this.filteredTasks,
    required this.pagedTasks,
    required this.hasReachedMax,
    required this.page,
    required this.searchQuery,
    required this.statusFilter,
    required this.priorityFilter,
    required this.isSyncing,
    this.syncError,
  });

  TaskLoaded copyWith({
    List<TeamTaskResModel>? allTasks,
    List<TeamTaskResModel>? filteredTasks,
    List<TeamTaskResModel>? pagedTasks,
    bool? hasReachedMax,
    int? page,
    String? searchQuery,
    String? statusFilter,
    String? priorityFilter,
    bool? isSyncing,
    String? syncError,
  }) {
    return TaskLoaded(
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      pagedTasks: pagedTasks ?? this.pagedTasks,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      isSyncing: isSyncing ?? this.isSyncing,
      syncError: syncError ?? this.syncError,
    );
  }

  @override
  List<Object?> get props => [
        allTasks,
        filteredTasks,
        pagedTasks,
        hasReachedMax,
        page,
        searchQuery,
        statusFilter,
        priorityFilter,
        isSyncing,
        syncError,
      ];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
