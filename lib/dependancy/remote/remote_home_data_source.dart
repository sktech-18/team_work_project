import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:team_work_project/model/team_task_res_model.dart';
import '../../services/constants/end_points.dart';
import '../../services/error/exceptions.dart';
import '../../services/helper/failure_helper.dart';
import '../../services/local-storage/shared_prefs_services.dart';
import '../../services/network/app_flavor_config.dart';
import '../../services/network/network_info.dart';
import '../../services/services_handle.dart';
import '../repositories/home_repository.dart';

class HomeDataSourceImp implements HomeRepositories {
  final NetworkInfo networkInfo;

  HomeDataSourceImp({required this.networkInfo});

  @override
  Future<Either<ServerException, List<TeamTaskResModel>>> getTeamTaskList({bool forceRefresh = false}) async {
    final sharedPrefs = locator.get<SharedPrefsService>();

    // 1. If not forcing a refresh, try loading from local cache first
    if (!forceRefresh) {
      final List<TeamTaskResModel> cachedTasks = sharedPrefs.getCachedTasks();
      if (cachedTasks.isNotEmpty) {
        debugPrint("[HomeDataSource] Loaded ${cachedTasks.length} tasks from local cache");
        return Right(cachedTasks);
      }
    }

    // 2. Check network connectivity
    bool isConnected = await networkInfo.isConnected();
    if (!isConnected) {
      final List<TeamTaskResModel> cachedTasks = sharedPrefs.getCachedTasks();
      if (cachedTasks.isNotEmpty) {
        debugPrint("[HomeDataSource] Offline but returning ${cachedTasks.length} tasks from local cache");
        return Right(cachedTasks);
      }
      return const Left(
        NoInternetConnectionException("No Internet Connection"),
      );
    }

    // 3. Fetch from Remote API
    try {
      debugPrint("[HomeDataSource] Fetching tasks from remote API...");
      Response response = await locator.get<Dio>().get(
        "${AppFlavorConfig.shared.baseUrl}${EndPoints.taskList}",
      );

      if (response.data is List) {
        final List<dynamic> rawList = response.data;
        final List<TeamTaskResModel> fetchedTasks = rawList
            .map((json) => TeamTaskResModel.fromJson(json))
            .toList();

        // Save to cache
        await sharedPrefs.cacheTasks(fetchedTasks);
        debugPrint("[HomeDataSource] Successfully fetched ${fetchedTasks.length} tasks and cached them");
        return Right(fetchedTasks);
      } else {
        throw const ServerException("Invalid response format");
      }
    } on DioException catch (e) {
      debugPrint("[HomeDataSource] DioError fetched: ${e.message}");
      // Fallback on cached if api fails
      final List<TeamTaskResModel> cachedTasks = sharedPrefs.getCachedTasks();
      if (cachedTasks.isNotEmpty) {
        return Right(cachedTasks);
      }
      final statusCode = e.response?.statusCode ?? 500;
      var res = FailersHelper.dynamicDioError(e, statusCode);
      return Left(res);
    } catch (e) {
      debugPrint("[HomeDataSource] Unexpected error: $e");
      final List<TeamTaskResModel> cachedTasks = sharedPrefs.getCachedTasks();
      if (cachedTasks.isNotEmpty) {
        return Right(cachedTasks);
      }
      return Left(ServerException(e.toString()));
    }
  }
}
