import 'package:dartz/dartz.dart';
import 'package:split_it/features/auth/domain/entities/user_entity.dart';
import 'package:split_it/features/auth/domain/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class SignInWithEmailParams {
  final String email;
  final String password;

  const SignInWithEmailParams({
    required this.email,
    required this.password
  });

}

class SignInWithEmailUsecase implements UseCase<UserEntity, SignInWithEmailParams>{

  final AuthRepository repository;
  const SignInWithEmailUsecase(this.repository);


  @override
  Future<Either<Failure, UserEntity>> call(
    SignInWithEmailParams params
  ) async {
    // validation rules
    if(params.email.trim().isEmpty){
      return const Left(
        ValidationFailure(message : 'Email cannot be empty', field : 'email'),
      );
    }

    if(!_isValidEmail(params.email)){
      return const Left(
        ValidationFailure(
          message : 'Enter a valid emailAddress', field : 'email'
        ),
      );
    }

    if(params.password.isEmpty){
      return const Left(
        ValidationFailure(
          message : 'Password cannot be empty', field : 'password'
        ),
      );
    }

    return repository.signInWithEmail(
      email: params.email.trim(),
      password: params.password,
    );
  }

  bool _isValidEmail(String email){
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }



} 