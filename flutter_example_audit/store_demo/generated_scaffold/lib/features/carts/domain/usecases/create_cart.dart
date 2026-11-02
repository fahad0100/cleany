// Exposes one business operation through the domain repository contract.
import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../repositories/carts_repository.dart';

import 'package:cleany_store/features/carts/domain/entities/carts_entity.dart';

/// Exposes one business operation through the domain repository contract.
/// Runs createCart through the feature's transport-independent contract.
class CreateCart {
  const CreateCart(this._repository);
  final CartsRepository _repository;
  Future<Result<CartsEntity, Failure>> call() => _repository.createCart();
}
