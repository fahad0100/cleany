// Defines immutable presentation states for the generated Cubit or Bloc.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cleany_store/features/users/domain/entities/users_entity.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/core/state/use_case_state.dart';

part 'users_state.freezed.dart';

/// Defines immutable presentation states for the generated Cubit or Bloc.
@freezed
sealed class UsersState with _$UsersState {
  const factory UsersState.initial({
    @Default(UseCaseState<UsersEntity>.initial())
    UseCaseState<UsersEntity> getUserProfileStatus,
  }) = UsersInitial;
  const factory UsersState.loading({
    @Default(UseCaseState<UsersEntity>.initial())
    UseCaseState<UsersEntity> getUserProfileStatus,
  }) = UsersLoading;
  const factory UsersState.success(
    UsersEntity entity, {
    @Default(UseCaseState<UsersEntity>.initial())
    UseCaseState<UsersEntity> getUserProfileStatus,
  }) = UsersSuccess;
  const factory UsersState.failure(
    Failure failure, {
    @Default(UseCaseState<UsersEntity>.initial())
    UseCaseState<UsersEntity> getUserProfileStatus,
  }) = UsersFailure;
}
