import 'package:dartz/dartz.dart';
import 'package:split_it/core/error/failures.dart';
import 'package:split_it/features/groups/domain/entities/group_entity.dart';

abstract class GroupRepository {

  // creaiting a new group
  Future<Either<Failure, GroupEntity>> createGroup({
    required String name,
    required String createdByUserId,
  });

  // Get all groups for the user -returns a stream for real time updates
  Stream<Either<Failure, List<GroupEntity>>> watchUserGroups(String userId);

  // get a single group by Id

  Future<Either<Failure, GroupEntity>> getGroup(String groupId);

  // Add a member to a group by their email
  Future<Either<Failure, Unit>> addMemberByEmail({
    required String groupId,
    required String email,
  });

  // Remove a member
  Future<Either<Failure, Unit>> removeMember({
    required String groupId,
    required String userId,
  });

  // Delete the entire group(Only allowed for the creator of the group)
  Future<Either<Failure, Unit>> deleteGroup(String groupId);

}