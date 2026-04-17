import 'package:dartz/dartz.dart';
import 'package:split_it/core/error/failures.dart';
import 'package:split_it/core/usecases/usecase.dart';
import 'package:split_it/features/groups/domain/repositories/group_repository.dart';

class AddMemberParams {
  final String groupId;
  final String email;

  const AddMemberParams({required this.groupId, required this.email});
}

class AddMemberUseCase implements UseCase<Unit, AddMemberParams> {
  final GroupRepository repository;
  const AddMemberUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(AddMemberParams params) async {
    if (params.email.trim().isEmpty) {
      return const Left(
        ValidationFailure(field: 'email', message: 'Email cannot be empty'),
      );
    }
    if (!params.email.contains('@')) {
      return const Left(
        ValidationFailure(
          field: 'email',
          message: 'Enter a valid email address',
        ),
      );
    }

    return repository.addMemberByEmail(
      groupId: params.groupId,
      email: params.email.trim().toLowerCase(),
    );
  }
}
