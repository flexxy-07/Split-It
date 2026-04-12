import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import 'package:split_it/features/auth/domain/entities/user_entity.dart';
import 'package:split_it/features/auth/domain/repositories/auth_repository.dart';
import 'package:split_it/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:split_it/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:split_it/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:split_it/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:split_it/injection/injection_container.dart';

sealed class AuthState{}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final UserEntity user;
  AuthSuccess(this.user);
}

class AuthError extends AuthState {
  final Failure failure;
  AuthError(this.failure);
}

class AuthPasswordResetSent extends AuthState {}

// listener for auth state changes (like user sign in or sign out)
final authStateStreamProvider = StreamProvider<UserEntity?>((ref){
  return sl<AuthRepository>().authStateChanges;
});


// auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
    final SignInWithEmailUsecase _signInWithEmail;
  final SignUpWithEmailUseCase _signUpWithEmail;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignOutUseCase _signOut; 

  AuthNotifier({
    required SignInWithEmailUsecase signInWithEmail,
    required SignUpWithEmailUseCase signUpWithEmail,
    required SignInWithGoogleUseCase signInWithGoogle,
    required SignOutUseCase signOut,
  })  : _signInWithEmail = signInWithEmail,
        _signUpWithEmail = signUpWithEmail,
        _signInWithGoogle = signInWithGoogle,
        _signOut = signOut,
        super(AuthInitial());

  Future<void> signInWithEmail({required String email, required String password}) async {
    state = AuthLoading();
    final result = await _signInWithEmail(SignInWithEmailParams(email: email, password: password));
    result.fold(
      (failure) => state = AuthError(failure),
      (user) => state = AuthSuccess(user),
    );
  }

   Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = AuthLoading();
    final result = await _signUpWithEmail(
      SignUpWithEmailParams(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      ),
    );
    state = result.fold(
      (failure) => AuthError(failure),
      (user) => AuthSuccess(user),
    );
  }

  Future<void> signInWithGoogle() async {
    state = AuthLoading();
    final result = await _signInWithGoogle(const NoParams());
    state = result.fold(
      (failure) {
        // Don't show error if user just cancelled the picker
        if (failure is AuthFailure && failure.code == 'cancelled') {
          return AuthInitial();
        }
        return AuthError(failure);
      },
      (user) => AuthSuccess(user),
    );
  }

  Future<void> signOut() async {
    state = AuthLoading();
    final result = await _signOut(const NoParams());
    state = result.fold(
      (failure) => AuthError(failure),
      (_) => AuthInitial(),
    );
  }

  // reset state back to initial
  void reset() => state = AuthInitial();


}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    signInWithEmail: sl(),
    signUpWithEmail: sl(),
    signInWithGoogle: sl(),
    signOut: sl(),
  );
});