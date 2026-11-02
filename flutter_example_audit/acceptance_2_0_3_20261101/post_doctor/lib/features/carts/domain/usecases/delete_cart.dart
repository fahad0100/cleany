import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../repositories/carts_repository.dart';

/// Fake Store simulates deletion; a later refresh returns the server dataset.
class DeleteCart {
  const DeleteCart(this._repository);
  final CartsRepository _repository;
  Future<Result<void, Failure>> call(int id) => id > 0
      ? _repository.deleteCart(id)
      : Future.value(const Error(ValidationFailure()));
}
