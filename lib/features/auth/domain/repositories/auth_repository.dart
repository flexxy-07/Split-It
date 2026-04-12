import 'package:dartz/dartz.dart';
import 'package:split_it/features/auth/domain/entities/user_entity.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRepository {
  // returns the current signedIn user or null if not any
  Future<Either<Failure, UserEntity?>> getCurrentUser();


  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, Unit>> signOut();

  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, Unit>> sendPasswordResetEmail({
    required String email,
  });

  Stream<UserEntity?> get authStateChanges;


}