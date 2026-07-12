import 'package:either_dart/either.dart';
import 'package:team_work_project/model/team_task_res_model.dart';
import '../../services/error/exceptions.dart';
import '../repositories/home_repository.dart';

class HomeUseCase {
  final HomeRepositories repository;

  HomeUseCase(this.repository);

  Future<Either<ServerException, List<TeamTaskResModel>>> callTeamTaskList({bool forceRefresh = false}) async {
    return await repository.getTeamTaskList(forceRefresh: forceRefresh);
  }
}
