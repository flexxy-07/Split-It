import 'package:dartz/dartz.dart';
import 'package:split_it/core/error/exceptions.dart';
import 'package:split_it/core/error/failures.dart';
import 'package:split_it/core/network/network_info.dart';
import 'package:split_it/features/groups/data/datasources/group_remote_datasource.dart';
import 'package:split_it/features/groups/domain/entities/group_entity.dart';
import 'package:split_it/features/groups/domain/repositories/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository{
  final GroupRemoteDatasource remoteDataSource;
  final NetworkInfo networkInfo;

  GroupRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });



  @override
  Future<Either<Failure, GroupEntity>> getGroup(String groupId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No connection'));
    }
    try {
      final model = await remoteDataSource.getGroup(groupId);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(FirestoreFailure(message: e.message));
    } catch (e, st) {
      return Left(UnexpectedFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> createGroup({
    required String name,
    required String createdByUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No connection'));
    }
    try {
      final model = await remoteDataSource.createGroup(
        name: name,
        createdByUserId: createdByUserId,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(FirestoreFailure(message: e.message));
    } catch (e, st) {
      return Left(UnexpectedFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Stream<Either<Failure, List<GroupEntity>>> watchUserGroups(
      String userId) {
    return remoteDataSource
        .watchUserGroups(userId)
        .map<Either<Failure, List<GroupEntity>>>(
          (models) => Right(models.map((m) => m.toEntity()).toList()),
        )
        .handleError((error) {
      if (error is ServerException) {
        return Left(FirestoreFailure(message: error.message));
      }
      return Left(UnexpectedFailure(message: error.toString()));
    });
  }


   @override
  Future<Either<Failure, Unit>> addMemberByEmail({
    required String groupId,
    required String email,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No connection'));
    }
    try {
      await remoteDataSource.addMemberByEmail(
        groupId: groupId,
        email: email,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(FirestoreFailure(message: e.message));
    } catch (e, st) {
      return Left(UnexpectedFailure(message: e.toString(), stackTrace: st));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> removeMember({
    required String groupId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No connection'));
    }
    try {
      await remoteDataSource.removeMember(
        groupId: groupId,
        userId: userId,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(FirestoreFailure(message: e.message));
    } catch (e, st) {
      return Left(UnexpectedFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteGroup(String groupId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No connection'));
    }
    try {
      await remoteDataSource.deleteGroup(groupId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(FirestoreFailure(message: e.message));
    } catch (e, st) {
      return Left(UnexpectedFailure(message: e.toString(), stackTrace: st));
    }
  }
  
  
  
  
}


