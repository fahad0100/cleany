// Exposes one business operation through the domain repository contract.
import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../repositories/carts_repository.dart';

/// Exposes one business operation through the domain repository contract.
/// Runs deleteCart through the feature's transport-independent contract.
class DeleteCart {
  const DeleteCart(this._repository);
  final CartsRepository _repository;
  Future<Result<void, Failure>> call() => _repository.deleteCart();
}
