// Defines the domain repository contract returning an Entity or Failure in a Result.
import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../entities/carts_entity.dart';

/// Defines the domain repository contract returning an Entity or Failure in a Result.
abstract interface class CartsRepository {
  Future<Result<CartsEntity, Failure>> fetch();

  /// Runs createCart, returning domain data or a Failure.
  Future<Result<CartsEntity, Failure>> createCart();

  /// Runs deleteCart, returning domain data or a Failure.
  Future<Result<void, Failure>> deleteCart();
}
