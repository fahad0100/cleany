import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../entities/carts_entity.dart';
import '../entities/cart_draft.dart';

/// Business contract shared by all operations on this feature.
abstract interface class CartsRepository {
  Future<Result<List<CartsEntity>, Failure>> fetch();
  Future<Result<CartsEntity, Failure>> createCart(CartDraft draft);
  Future<Result<void, Failure>> deleteCart(int id);
}
