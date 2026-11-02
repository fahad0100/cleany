import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../entities/products_entity.dart';

/// Business contract shared by all operations on this feature.
abstract interface class ProductsRepository {
  Future<Result<List<ProductsEntity>, Failure>> fetch();
  Future<Result<ProductsEntity, Failure>> getFeaturedProduct();
}
