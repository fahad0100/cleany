import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../entities/carts_entity.dart';
import '../entities/cart_draft.dart';
import '../repositories/carts_repository.dart';
import '../../../products/domain/repositories/products_repository.dart';
import 'cart_enrichment.dart';

/// Validate the business request, create a simulated API cart, then enrich it.
class CreateCart {
  const CreateCart(this._repository, this._products);
  final CartsRepository _repository;
  final ProductsRepository _products;
  Future<Result<CartsEntity, Failure>> call(CartDraft draft) async {
    if (draft.quantity < 1 ||
        draft.quantity > 99 ||
        draft.productId < 1 ||
        draft.userId < 1) {
      return const Error(ValidationFailure());
    }
    final products = await _products.fetch();
    if (products.isError()) return Error(products.tryGetError()!);
    final cart = await _repository.createCart(draft);
    return cart.when(
      (c) => Success(enrichCart(c, products.tryGetSuccess()!)),
      (f) => Error(f),
    );
  }
}
