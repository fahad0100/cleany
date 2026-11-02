import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../entities/carts_entity.dart';
import '../repositories/carts_repository.dart';
import '../../../products/domain/repositories/products_repository.dart';
import 'cart_enrichment.dart';

class GetCarts {
  const GetCarts(this._repository, this._products);
  final CartsRepository _repository;
  final ProductsRepository _products;
  Future<Result<List<CartsEntity>, Failure>> call() async {
    final carts = await _repository.fetch();
    if (carts.isError()) return Error(carts.tryGetError()!);
    final products = await _products.fetch();
    if (products.isError()) return Error(products.tryGetError()!);
    return Success(
      carts
          .tryGetSuccess()!
          .map((c) => enrichCart(c, products.tryGetSuccess()!))
          .toList(),
    );
  }
}
