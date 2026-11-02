// Runs presentation actions and emits the corresponding immutable states.
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cleany_store/features/products/domain/usecases/get_products.dart';

import 'products_state.dart';

import 'package:cleany_store/features/products/domain/usecases/get_featured_product.dart';
import 'package:cleany_store/core/state/use_case_state.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/features/products/domain/entities/products_entity.dart';

/// Runs presentation actions and emits the corresponding immutable states.
class ProductsCubit extends Cubit<ProductsState> {
  final GetProducts _getProducts;
  ProductsCubit(this._getProducts, {this.getFeaturedProductUseCase})
    : super(const ProductsState.initial());

  Future<void> load() async {
    if (isClosed || state is ProductsLoading) return;
    emit(
      ProductsState.loading(
        getFeaturedProductStatus: state.getFeaturedProductStatus,
      ),
    );
    final result = await _getProducts();
    if (isClosed) return;
    result.when(
      (entity) => emit(
        ProductsState.success(
          entity,
          getFeaturedProductStatus: state.getFeaturedProductStatus,
        ),
      ),
      (failure) => emit(
        ProductsState.failure(
          failure,
          getFeaturedProductStatus: state.getFeaturedProductStatus,
        ),
      ),
    );
  }

  /// Optional for existing manual construction; central DI always supplies this action.
  final GetFeaturedProduct? getFeaturedProductUseCase;

  /// Updates only getFeaturedProductStatus; other actions keep their current state.
  Future<void> getFeaturedProduct() async {
    if (isClosed ||
        state.getFeaturedProductStatus is UseCaseLoading<ProductsEntity>) {
      return;
    }
    emit(
      state.copyWith(
        getFeaturedProductStatus: const UseCaseState<ProductsEntity>.loading(),
      ),
    );
    final useCase = getFeaturedProductUseCase;
    if (useCase == null) {
      emit(
        state.copyWith(
          getFeaturedProductStatus: const UseCaseState<ProductsEntity>.failure(
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
          getFeaturedProductStatus: UseCaseState<ProductsEntity>.success(
            entity,
          ),
        ),
      ),
      (failure) => emit(
        state.copyWith(
          getFeaturedProductStatus: UseCaseState<ProductsEntity>.failure(
            failure,
          ),
        ),
      ),
    );
  }
}
