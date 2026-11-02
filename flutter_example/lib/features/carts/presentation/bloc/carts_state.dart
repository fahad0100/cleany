import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/carts_entity.dart';

import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/core/state/use_case_state.dart';
part 'carts_state.freezed.dart';

@freezed
sealed class CartsState with _$CartsState {
  const factory CartsState.initial({
    @Default(UseCaseState<CartsEntity>.initial())
    UseCaseState<CartsEntity> createCartStatus,
    @Default(UseCaseState<void>.initial()) UseCaseState<void> deleteCartStatus,
    @Default(<int>[]) List<int> deletedIds,
  }) = CartsInitial;
  const factory CartsState.loading({
    @Default(UseCaseState<CartsEntity>.initial())
    UseCaseState<CartsEntity> createCartStatus,
    @Default(UseCaseState<void>.initial()) UseCaseState<void> deleteCartStatus,
    @Default(<int>[]) List<int> deletedIds,
  }) = CartsLoading;
  const factory CartsState.success(
    List<CartsEntity> carts, {
    @Default(UseCaseState<CartsEntity>.initial())
    UseCaseState<CartsEntity> createCartStatus,
    @Default(UseCaseState<void>.initial()) UseCaseState<void> deleteCartStatus,
    @Default(<int>[]) List<int> deletedIds,
  }) = CartsSuccess;
  const factory CartsState.failure(
    Failure failure, {
    @Default(UseCaseState<CartsEntity>.initial())
    UseCaseState<CartsEntity> createCartStatus,
    @Default(UseCaseState<void>.initial()) UseCaseState<void> deleteCartStatus,
    @Default(<int>[]) List<int> deletedIds,
  }) = CartsFailure;
}
