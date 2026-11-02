// Runs presentation actions and emits the corresponding immutable states.
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cleany_store/features/auth/domain/usecases/get_auth.dart';

import 'auth_state.dart';

import 'package:cleany_store/features/auth/domain/usecases/sign_in.dart';
import 'package:cleany_store/core/state/use_case_state.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/features/auth/domain/entities/auth_entity.dart';
import 'package:cleany_store/features/auth/domain/usecases/sign_out.dart';

/// Runs presentation actions and emits the corresponding immutable states.
class AuthCubit extends Cubit<AuthState> {
  final GetAuth _getAuth;
  AuthCubit(this._getAuth, {this.signInUseCase, this.signOutUseCase})
    : super(const AuthState.initial());

  Future<void> load() async {
    if (isClosed || state is AuthLoading) return;
    emit(
      AuthState.loading(
        signInStatus: state.signInStatus,
        signOutStatus: state.signOutStatus,
      ),
    );
    final result = await _getAuth();
    if (isClosed) return;
    result.when(
      (entity) => emit(
        AuthState.success(
          entity,
          signInStatus: state.signInStatus,
          signOutStatus: state.signOutStatus,
        ),
      ),
      (failure) => emit(
        AuthState.failure(
          failure,
          signInStatus: state.signInStatus,
          signOutStatus: state.signOutStatus,
        ),
      ),
    );
  }

  /// Optional for existing manual construction; central DI always supplies this action.
  final SignIn? signInUseCase;

  /// Updates only signInStatus; other actions keep their current state.
  Future<void> signIn() async {
    if (isClosed || state.signInStatus is UseCaseLoading<AuthEntity>) {
      return;
    }
    emit(
      state.copyWith(signInStatus: const UseCaseState<AuthEntity>.loading()),
    );
    final useCase = signInUseCase;
    if (useCase == null) {
      emit(
        state.copyWith(
          signInStatus: const UseCaseState<AuthEntity>.failure(
            UnexpectedFailure('This action is unavailable.'),
          ),
        ),
      );
      return;
    }
    final result = await useCase();
    if (isClosed) {
      return;
    }
    result.when(
      (entity) => emit(
        state.copyWith(signInStatus: UseCaseState<AuthEntity>.success(entity)),
      ),
      (failure) => emit(
        state.copyWith(signInStatus: UseCaseState<AuthEntity>.failure(failure)),
      ),
    );
  }

  /// Optional for existing manual construction; central DI always supplies this action.
  final SignOut? signOutUseCase;

  /// Updates only signOutStatus; other actions keep their current state.
  Future<void> signOut() async {
    if (isClosed || state.signOutStatus is UseCaseLoading<void>) {
      return;
    }
    emit(state.copyWith(signOutStatus: const UseCaseState<void>.loading()));
    final useCase = signOutUseCase;
    if (useCase == null) {
      emit(
        state.copyWith(
          signOutStatus: const UseCaseState<void>.failure(
            UnexpectedFailure('This action is unavailable.'),
          ),
        ),
      );
      return;
    }
    final result = await useCase();
    if (isClosed) {
      return;
    }
    result.when(
      (_) => emit(
        state.copyWith(signOutStatus: const UseCaseState<void>.success(null)),
      ),
      (failure) => emit(
        state.copyWith(signOutStatus: UseCaseState<void>.failure(failure)),
      ),
    );
  }
}
