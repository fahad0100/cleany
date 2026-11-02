import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_users.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/entities/users_entity.dart';

import 'package:cleany_store/core/state/use_case_state.dart';

import 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit(this._getUsers, {required this.getUserProfileUseCase})
    : super(const UsersState.initial());
  final GetUsers _getUsers;
  final GetUserProfile getUserProfileUseCase;
  int _request = 0;
  Future<void> load() async {
    if (isClosed || state is UsersLoading) return;
    emit(
      UsersState.loading(
        query: state.query,
        getUserProfileStatus: state.getUserProfileStatus,
      ),
    );
    final result = await _getUsers();
    if (isClosed) return;
    result.when(
      (items) => emit(
        UsersState.success(
          items,
          query: state.query,
          getUserProfileStatus: state.getUserProfileStatus,
        ),
      ),
      (f) => emit(
        UsersState.failure(
          f,
          query: state.query,
          getUserProfileStatus: state.getUserProfileStatus,
        ),
      ),
    );
  }

  void search(String query) {
    if (!isClosed) emit(state.copyWith(query: query));
  }

  List<UsersEntity> get visibleUsers {
    final current = state;
    return current is UsersSuccess
        ? current.users
              .where(
                (u) => '${u.firstName} ${u.lastName} ${u.username}'
                    .toLowerCase()
                    .contains(state.query.toLowerCase()),
              )
              .toList()
        : [];
  }

  Future<void> getUserProfile(int id) async {
    if (isClosed) return;
    final request = ++_request;
    emit(state.copyWith(getUserProfileStatus: const UseCaseState.loading()));
    final result = await getUserProfileUseCase(id);
    if (isClosed || request != _request) return;
    result.when(
      (u) =>
          emit(state.copyWith(getUserProfileStatus: UseCaseState.success(u))),
      (f) =>
          emit(state.copyWith(getUserProfileStatus: UseCaseState.failure(f))),
    );
  }
}
