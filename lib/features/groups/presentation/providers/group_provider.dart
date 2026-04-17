import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:split_it/core/error/failures.dart';
import 'package:split_it/features/auth/presentation/providers/auth_provider.dart';
import 'package:split_it/features/groups/domain/entities/group_entity.dart';
import 'package:split_it/features/groups/domain/usecases/add_member_usecase.dart';
import 'package:split_it/features/groups/domain/usecases/create_group_usecase.dart';
import 'package:split_it/features/groups/domain/usecases/watch_user_groups_usecase.dart';
import 'package:split_it/injection/injection_container.dart';

sealed class GroupActionState {}

class GroupActionInitial extends GroupActionState {}

class GroupActionLoading extends GroupActionState {}

class GroupActionSuccess extends GroupActionState {
  final String? message;
  GroupActionSuccess({this.message});
}

class GroupActionError extends GroupActionState {
  final Failure failure;
  GroupActionError(this.failure);
}

// streamProvider : Real time group list
// Depends on the auth stream - automaticaly re runs when use changes


final userGroupProvider = StreamProvider<Either<Failure, List<GroupEntity>>>((ref){
  final authState = ref.watch(authStateStreamProvider);
  return authState.when(data: (user){
    if(user == null){
      return Stream.value(const Right([]));
    }
    return sl<WatchUserGroupsUsecase>()(user.id);
  }, error: (e, _) => Stream.value(
    Left(UnexpectedFailure(message: e.toString())),
  ), loading: () => Stream.value(const Right([])));
  
});





// Action Notifier : Create Group, add members

class GroupNotifier extends StateNotifier<GroupActionState> {
  final CreateGroupUsecase _createGroup;
  final AddMemberUseCase _addmember;

  GroupNotifier({
    required CreateGroupUsecase createGroup,
    required AddMemberUseCase addMember,
  }) : _createGroup = createGroup,
  _addmember = addMember,
  super(GroupActionInitial());


  Future<void> createGroup({
    required String name, 
    required String userId,
  }) async {
    state = GroupActionLoading();
    final result = await _createGroup(
      CreateGroupParams(name: name, createdByUserId: userId)
    );

    state = result.fold((failure) => GroupActionError(failure), (_) => GroupActionSuccess(
      message: 'Group created'
    ));
  }


  Future<void> addMember ({
    required String groupId,
    required String email,
  }) async {
    state = GroupActionLoading();
    final result = await _addmember(
      AddMemberParams(groupId: groupId, email: email)
    );

    state = result.fold((failure) => GroupActionError(failure),
     (_) => GroupActionSuccess(
      message: 'Member added'
    ));
  }

  void reset() => state = GroupActionInitial();
  
}

final groupNotifierProvider = StateNotifierProvider<GroupNotifier, GroupActionState>((ref) => GroupNotifier(
  createGroup: sl<CreateGroupUsecase>(),
  addMember: sl<AddMemberUseCase>(),
));
