// Defines immutable presentation states for the generated Cubit or Bloc.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cleany_store/features/carts/domain/entities/carts_entity.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/core/state/use_case_state.dart';

part 'carts_state.freezed.dart';

/// Defines immutable presentation states for the generated Cubit or Bloc.
@freezed
sealed class CartsState with _$CartsState {
  const factory CartsState.initial({
    @Default(UseCaseState<CartsEntity>.initial())
    UseCaseState<CartsEntity> createCartStatus,
    @Default(UseCaseState<void>.initial()) UseCaseState<void> deleteCartStatus,
  }) = CartsInitial;
  const factory CartsState.loading({
    @Default(UseCaseState<CartsEntity>.initial())
    UseCaseState<CartsEntity> createCartStatus,
    @Default(UseCaseState<void>.initial()) UseCaseState<void> deleteCartStatus,
  }) = CartsLoading;
  const factory CartsState.success(
    CartsEntity entity, {
    @Default(UseCaseState<CartsEntity>.initial())
    UseCaseState<CartsEntity> createCartStatus,
    @Default(UseCaseState<void>.initial()) UseCaseState<void> deleteCartStatus,
  }) = CartsSuccess;
  const factory CartsState.failure(
    Failure failure, {
    @Default(UseCaseState<CartsEntity>.initial())
    UseCaseState<CartsEntity> createCartStatus,
    @Default(UseCaseState<void>.initial()) UseCaseState<void> deleteCartStatus,
  }) = CartsFailure;
}
