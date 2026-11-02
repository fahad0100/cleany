import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/products_entity.dart';

import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/core/state/use_case_state.dart';
part 'products_state.freezed.dart';

@freezed
sealed class ProductsState with _$ProductsState {
  const factory ProductsState.initial({
    @Default(UseCaseState<ProductsEntity>.initial())
    UseCaseState<ProductsEntity> getFeaturedProductStatus,
    @Default('') String query,
    String? category,
    @Default(false) bool priceAscending,
  }) = ProductsInitial;
  const factory ProductsState.loading({
    @Default(UseCaseState<ProductsEntity>.initial())
    UseCaseState<ProductsEntity> getFeaturedProductStatus,
    @Default('') String query,
    String? category,
    @Default(false) bool priceAscending,
  }) = ProductsLoading;
  const factory ProductsState.success(
    List<ProductsEntity> products, {
    @Default(UseCaseState<ProductsEntity>.initial())
    UseCaseState<ProductsEntity> getFeaturedProductStatus,
    @Default('') String query,
    String? category,
    @Default(false) bool priceAscending,
  }) = ProductsSuccess;
  const factory ProductsState.failure(
    Failure failure, {
    @Default(UseCaseState<ProductsEntity>.initial())
    UseCaseState<ProductsEntity> getFeaturedProductStatus,
    @Default('') String query,
    String? category,
    @Default(false) bool priceAscending,
  }) = ProductsFailure;
}
