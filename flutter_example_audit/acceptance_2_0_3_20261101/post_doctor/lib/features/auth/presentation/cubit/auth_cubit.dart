import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_auth.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/entities/auth_entity.dart';

import 'package:cleany_store/core/state/use_case_state.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._getAuth, {
    required this.signInUseCase,
    required this.signOutUseCase,
  }) : super(const AuthState.initial());
  final GetAuth _getAuth;
  final SignIn signInUseCase;
  final SignOut signOutUseCase;
  Future<void> load() async {
    final result = await _getAuth();
    if (isClosed) return;
    result.when(
      (s) => emit(AuthState.success(s)),
      (f) => emit(AuthState.failure(f)),
    );
  }

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    if (isClosed || state.signInStatus is UseCaseLoading<AuthEntity>) return;
    emit(state.copyWith(signInStatus: const UseCaseState.loading()));
    final result = await signInUseCase(username: username, password: password);
    if (isClosed) return;
    result.when(
      (session) => emit(
        AuthState.success(session, signInStatus: UseCaseState.success(session)),
      ),
      (f) => emit(state.copyWith(signInStatus: UseCaseState.failure(f))),
    );
  }

  Future<void> signOut() async {
    if (isClosed || state.signOutStatus is UseCaseLoading<void>) return;
    emit(state.copyWith(signOutStatus: const UseCaseState.loading()));
    final result = await signOutUseCase();
    if (isClosed) return;
    result.when(
      (_) => emit(
        const AuthState.initial(
          signOutStatus: UseCaseState<void>.success(null),
        ),
      ),
      (f) => emit(state.copyWith(signOutStatus: UseCaseState.failure(f))),
    );
  }
}
