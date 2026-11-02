// Exposes one business operation through the domain repository contract.
import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../entities/carts_entity.dart';
import '../repositories/carts_repository.dart';

/// Exposes one business operation through the domain repository contract.
class GetCarts {
  const GetCarts(this._repository);
  final CartsRepository _repository;
  Future<Result<CartsEntity, Failure>> call() => _repository.fetch();
}
