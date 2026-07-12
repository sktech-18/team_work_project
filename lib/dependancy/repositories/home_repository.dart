import 'package:either_dart/either.dart';
import 'package:team_work_project/model/team_task_res_model.dart';
import '../../services/error/exceptions.dart';

abstract class HomeRepositories {
  Future<Either<ServerException, List<TeamTaskResModel>>> getTeamTaskList({bool forceRefresh = false});
}
