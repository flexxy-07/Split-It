import 'package:dartz/dartz.dart';
import 'package:split_it/core/error/failures.dart';
import 'package:split_it/core/usecases/usecase.dart';
import 'package:split_it/features/groups/domain/entities/group_entity.dart';
import 'package:split_it/features/groups/domain/repositories/group_repository.dart';

class CreateGroupParams {
  final String name;
  final String createdByUserId;
  const CreateGroupParams({
    required this.name,
    required this.createdByUserId,
  });


}

class CreateGroupUsecase implements UseCase<GroupEntity, CreateGroupParams>{
  final GroupRepository repository;
  const CreateGroupUsecase(this.repository);


  @override
  Future<Either<Failure, GroupEntity>> call(CreateGroupParams params) async {
    if(params.name.trim().isEmpty){
      return const Left(
        ValidationFailure(field: 'name', message: 'Group name cannot be empty')
      );
    }

    if(params.name.trim().length < 2){
      return const Left(
        ValidationFailure(field: 'name', message: 'Group name must be atleast 2 characters')
      );
    }

    if(params.name.trim().length > 40){
      return const Left(
        ValidationFailure(field: 'name', message: 'Group name must be under 40 characters')
      );
    }

    return repository.createGroup(name: params.name.trim(), createdByUserId: params.createdByUserId);
  }
}