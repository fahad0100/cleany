import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/users_entity.dart';

import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/core/state/use_case_state.dart';
part 'users_state.freezed.dart';

@freezed
sealed class UsersState with _$UsersState {
  const factory UsersState.initial({
    @Default(UseCaseState<UsersEntity>.initial())
    UseCaseState<UsersEntity> getUserProfileStatus,
    @Default('') String query,
  }) = UsersInitial;
  const factory UsersState.loading({
    @Default(UseCaseState<UsersEntity>.initial())
    UseCaseState<UsersEntity> getUserProfileStatus,
    @Default('') String query,
  }) = UsersLoading;
  const factory UsersState.success(
    List<UsersEntity> users, {
    @Default(UseCaseState<UsersEntity>.initial())
    UseCaseState<UsersEntity> getUserProfileStatus,
    @Default('') String query,
  }) = UsersSuccess;
  const factory UsersState.failure(
    Failure failure, {
    @Default(UseCaseState<UsersEntity>.initial())
    UseCaseState<UsersEntity> getUserProfileStatus,
    @Default('') String query,
  }) = UsersFailure;
}
