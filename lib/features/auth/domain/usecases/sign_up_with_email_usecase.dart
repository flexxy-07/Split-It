import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailParams {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  const SignUpWithEmailParams({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
}

class SignUpWithEmailUseCase
    implements UseCase<UserEntity, SignUpWithEmailParams> {
  final AuthRepository repository;
  const SignUpWithEmailUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(
      SignUpWithEmailParams params) async {
    if (params.name.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Name cannot be empty', field: 'name'),
      );
    }
    if (params.name.trim().length < 2) {
      return const Left(
        ValidationFailure(
            message: 'Name must be at least 2 characters', field: 'name'),
      );
    }
    if (params.email.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Email cannot be empty', field: 'email'),
      );
    }
    if (!_isValidEmail(params.email)) {
      return const Left(
        ValidationFailure(
            message: 'Enter a valid email address', field: 'email'),
      );
    }
    if (params.password.length < 6) {
      return const Left(
        ValidationFailure(
            message: 'Password must be at least 6 characters',
            field: 'password'),
      );
    }
    if (params.password != params.confirmPassword) {
      return const Left(
        ValidationFailure(
            message: 'Passwords do not match', field: 'confirmPassword'),
      );
    }

    return repository.signUpWithEmail(
      email: params.email.trim(),
      password: params.password,
      name: params.name.trim(),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}