import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/get_featured_product.dart';
import '../../domain/entities/products_entity.dart';

import 'package:cleany_store/core/state/use_case_state.dart';

import 'products_state.dart';

/// Owns catalog loading, local presentation filters and the generated spotlight action.
class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._getProducts, {required this.getFeaturedProductUseCase})
    : super(const ProductsState.initial());
  final GetProducts _getProducts;
  final GetFeaturedProduct getFeaturedProductUseCase;
  Future<void> load() async {
    if (isClosed || state is ProductsLoading) return;
    emit(
      ProductsState.loading(
        query: state.query,
        category: state.category,
        priceAscending: state.priceAscending,
        getFeaturedProductStatus: state.getFeaturedProductStatus,
      ),
    );
    final result = await _getProducts();
    if (isClosed) return;
    result.when(
      (items) => emit(
        ProductsState.success(
          items,
          query: state.query,
          category: state.category,
          priceAscending: state.priceAscending,
          getFeaturedProductStatus: state.getFeaturedProductStatus,
        ),
      ),
      (failure) => emit(
        ProductsState.failure(
          failure,
          query: state.query,
          category: state.category,
          priceAscending: state.priceAscending,
          getFeaturedProductStatus: state.getFeaturedProductStatus,
        ),
      ),
    );
  }

  void search(String query) {
    if (!isClosed) emit(state.copyWith(query: query));
  }

  void selectCategory(String? category) {
    if (!isClosed) emit(state.copyWith(category: category));
  }

  void toggleSort() {
    if (!isClosed) emit(state.copyWith(priceAscending: !state.priceAscending));
  }

  List<ProductsEntity> get visibleProducts {
    final current = state;
    if (current is! ProductsSuccess) return [];
    final result = current.products
        .where(
          (p) =>
              (state.category == null || p.category == state.category) &&
              p.title.toLowerCase().contains(state.query.toLowerCase()),
        )
        .toList();
    if (state.priceAscending) result.sort((a, b) => a.price.compareTo(b.price));
    return result;
  }

  Future<void> getFeaturedProduct() async {
    if (isClosed ||
        state.getFeaturedProductStatus is UseCaseLoading<ProductsEntity>) {
      return;
    }
    emit(
      state.copyWith(getFeaturedProductStatus: const UseCaseState.loading()),
    );
    final result = await getFeaturedProductUseCase();
    if (isClosed) return;
    result.when(
      (p) => emit(
        state.copyWith(getFeaturedProductStatus: UseCaseState.success(p)),
      ),
      (f) => emit(
        state.copyWith(getFeaturedProductStatus: UseCaseState.failure(f)),
      ),
    );
  }
}
