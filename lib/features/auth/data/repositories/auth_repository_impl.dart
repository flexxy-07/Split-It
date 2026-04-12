import 'package:dartz/dartz.dart';
import 'package:split_it/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:split_it/features/auth/domain/entities/user_entity.dart';
import 'package:split_it/features/auth/domain/repositories/auth_repository.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';

class AuthRepositoryImpl implements AuthRepository{
  final AuthRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  const AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo
  });

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({required String email, required String password}) async {
    if(!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message : 'No Connection'));
    }
    try {
      final model = await remoteDatasource.signInWithEmail(email: email, password: password);
      return Right(model.toEntity());
    }on ServerException catch (e) {
      return Left(AuthFailure(
        message : e.message,
        code : _extractFirebaseCode(e.message),
      ));
    }catch(e, st){
      return Left(UnexpectedFailure(message: e.toString(), stackTrace : st));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No connection'));
    }
    try {
      final model = await remoteDatasource.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(AuthFailure(
        message: e.message,
        code: _extractFirebaseCode(e.message),
      ));
    } catch (e, st) {
      return Left(UnexpectedFailure(message: e.toString(), stackTrace: st));
    }
  }


  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    if(!await networkInfo.isConnected){
      return const Left(NetworkFailure(message : 'No connection'));
    }

    try {
      final model = await remoteDatasource.signInWithGoogle();
      return Right(model.toEntity());
    }on ServerException catch(e){
      if(e.message == 'Google Sign-In cancelled'){
        return Left(AuthFailure(message : e.message, code : 'cancelled'));
      }

      return Left(AuthFailure(
        message : e.message,
        code : _extractFirebaseCode(e.message),
      ));
    }catch(e, st){
      return Left(
        UnexpectedFailure(
          message : e.toString(), stackTrace : st
        )
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await remoteDatasource.signOut();
      return const Right(unit);
    } catch (e, st) {
      return Left(UnexpectedFailure(message: e.toString(), stackTrace: st));
    }
  }

   @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail({
    required String email,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No connection'));
    }
    try {
      await remoteDatasource.sendPasswordResetEmail(email: email);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(AuthFailure(
        message: e.message,
        code: _extractFirebaseCode(e.message),
      ));
    } catch (e, st) {
      return Left(UnexpectedFailure(message: e.toString(), stackTrace: st));
    }
  }


  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final model = await remoteDatasource.getCurrentUser();
      return Right(model?.toEntity());
    } catch (e, st) {
      return Left(UnexpectedFailure(message: e.toString(), stackTrace: st));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDatasource.authStateChanges
        .map((model) => model?.toEntity());
  }


 // Firebase error messages contain the code like [firebase_auth/user-not-found]
  //  extracting just the code part
  String _extractFirebaseCode(String message) {
    final match = RegExp(r'\[firebase_auth/([^\]]+)\]').firstMatch(message);
    return match?.group(1) ?? 'unknown';
  }

}