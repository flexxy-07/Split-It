import 'package:dartz/dartz.dart';
import 'package:split_it/core/error/failures.dart';
import 'package:split_it/features/groups/domain/entities/group_entity.dart';
import 'package:split_it/features/groups/domain/repositories/group_repository.dart';

class WatchUserGroupsUsecase {
  final GroupRepository repository;
  const WatchUserGroupsUsecase(this.repository);
  
  Stream<Either<Failure, List<GroupEntity>>> call(String userId) {
    return repository.watchUserGroups(userId);
  }
}