// Runs presentation actions and emits the corresponding immutable states.
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cleany_store/features/users/domain/usecases/get_users.dart';

import 'users_state.dart';

import 'package:cleany_store/features/users/domain/usecases/get_user_profile.dart';
import 'package:cleany_store/core/state/use_case_state.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/features/users/domain/entities/users_entity.dart';

/// Runs presentation actions and emits the corresponding immutable states.
class UsersCubit extends Cubit<UsersState> {
  final GetUsers _getUsers;
  UsersCubit(this._getUsers, {this.getUserProfileUseCase})
    : super(const UsersState.initial());

  Future<void> load() async {
    if (isClosed || state is UsersLoading) return;
    emit(UsersState.loading(getUserProfileStatus: state.getUserProfileStatus));
    final result = await _getUsers();
    if (isClosed) return;
    result.when(
      (entity) => emit(
        UsersState.success(
          entity,
          getUserProfileStatus: state.getUserProfileStatus,
        ),
      ),
      (failure) => emit(
        UsersState.failure(
          failure,
          getUserProfileStatus: state.getUserProfileStatus,
        ),
      ),
    );
  }

  /// Optional for existing manual construction; central DI always supplies this action.
  final GetUserProfile? getUserProfileUseCase;

  /// Updates only getUserProfileStatus; other actions keep their current state.
  Future<void> getUserProfile() async {
    if (isClosed || state.getUserProfileStatus is UseCaseLoading<UsersEntity>) {
      return;
    }
    emit(
      state.copyWith(
        getUserProfileStatus: const UseCaseState<UsersEntity>.loading(),
      ),
    );
    final useCase = getUserProfileUseCase;
    if (useCase == null) {
      emit(
        state.copyWith(
          getUserProfileStatus: const UseCaseState<UsersEntity>.failure(
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
        state.copyWith(
          getUserProfileStatus: UseCaseState<UsersEntity>.success(entity),
        ),
      ),
      (failure) => emit(
        state.copyWith(
          getUserProfileStatus: UseCaseState<UsersEntity>.failure(failure),
        ),
      ),
    );
  }
}
