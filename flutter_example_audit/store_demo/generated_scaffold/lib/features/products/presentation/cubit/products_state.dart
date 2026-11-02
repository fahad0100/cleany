// Defines immutable presentation states for the generated Cubit or Bloc.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cleany_store/features/products/domain/entities/products_entity.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/core/state/use_case_state.dart';

part 'products_state.freezed.dart';

/// Defines immutable presentation states for the generated Cubit or Bloc.
@freezed
sealed class ProductsState with _$ProductsState {
  const factory ProductsState.initial({
    @Default(UseCaseState<ProductsEntity>.initial())
    UseCaseState<ProductsEntity> getFeaturedProductStatus,
  }) = ProductsInitial;
  const factory ProductsState.loading({
    @Default(UseCaseState<ProductsEntity>.initial())
    UseCaseState<ProductsEntity> getFeaturedProductStatus,
  }) = ProductsLoading;
  const factory ProductsState.success(
    ProductsEntity entity, {
    @Default(UseCaseState<ProductsEntity>.initial())
    UseCaseState<ProductsEntity> getFeaturedProductStatus,
  }) = ProductsSuccess;
  const factory ProductsState.failure(
    Failure failure, {
    @Default(UseCaseState<ProductsEntity>.initial())
    UseCaseState<ProductsEntity> getFeaturedProductStatus,
  }) = ProductsFailure;
}
