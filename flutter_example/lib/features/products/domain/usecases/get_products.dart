import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../entities/products_entity.dart';
import '../repositories/products_repository.dart';

class GetProducts {
  const GetProducts(this._repository);
  final ProductsRepository _repository;
  Future<Result<List<ProductsEntity>, Failure>> call() => _repository.fetch();
}
