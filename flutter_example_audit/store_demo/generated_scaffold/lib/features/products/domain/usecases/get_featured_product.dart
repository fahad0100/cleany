// Exposes one business operation through the domain repository contract.
import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../repositories/products_repository.dart';

import 'package:cleany_store/features/products/domain/entities/products_entity.dart';

/// Exposes one business operation through the domain repository contract.
/// Runs getFeaturedProduct through the feature's transport-independent contract.
class GetFeaturedProduct {
  const GetFeaturedProduct(this._repository);
  final ProductsRepository _repository;
  Future<Result<ProductsEntity, Failure>> call() =>
      _repository.getFeaturedProduct();
}
