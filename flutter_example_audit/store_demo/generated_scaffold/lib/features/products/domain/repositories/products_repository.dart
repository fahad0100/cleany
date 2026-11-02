// Defines the domain repository contract returning an Entity or Failure in a Result.
import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../entities/products_entity.dart';

/// Defines the domain repository contract returning an Entity or Failure in a Result.
abstract interface class ProductsRepository {
  Future<Result<ProductsEntity, Failure>> fetch();

  /// Runs getFeaturedProduct, returning domain data or a Failure.
  Future<Result<ProductsEntity, Failure>> getFeaturedProduct();
}
