// Defines immutable presentation states for the generated Cubit or Bloc.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cleany_store/features/auth/domain/entities/auth_entity.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/core/state/use_case_state.dart';

part 'auth_state.freezed.dart';

/// Defines immutable presentation states for the generated Cubit or Bloc.
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial({
    @Default(UseCaseState<AuthEntity>.initial())
    UseCaseState<AuthEntity> signInStatus,
    @Default(UseCaseState<void>.initial()) UseCaseState<void> signOutStatus,
  }) = AuthInitial;
  const factory AuthState.loading({
    @Default(UseCaseState<AuthEntity>.initial())
    UseCaseState<AuthEntity> signInStatus,
    @Default(UseCaseState<void>.initial()) UseCaseState<void> signOutStatus,
  }) = AuthLoading;
  const factory AuthState.success(
    AuthEntity entity, {
    @Default(UseCaseState<AuthEntity>.initial())
    UseCaseState<AuthEntity> signInStatus,
    @Default(UseCaseState<void>.initial()) UseCaseState<void> signOutStatus,
  }) = AuthSuccess;
  const factory AuthState.failure(
    Failure failure, {
    @Default(UseCaseState<AuthEntity>.initial())
    UseCaseState<AuthEntity> signInStatus,
    @Default(UseCaseState<void>.initial()) UseCaseState<void> signOutStatus,
  }) = AuthFailure;
}
