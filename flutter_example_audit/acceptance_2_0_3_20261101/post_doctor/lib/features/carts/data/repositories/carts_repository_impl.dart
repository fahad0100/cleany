import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/core/errors/error_reporter.dart';
import 'package:cleany_store/core/errors/repository_guard.dart';

import '../../domain/entities/carts_entity.dart';
import '../../domain/repositories/carts_repository.dart';
import '../datasources/carts_remote_data_source.dart';
import '../models/carts_model.dart';
import '../../domain/entities/cart_draft.dart';

/// Owns JSON -> DTO -> Entity conversion and the single Failure boundary.
class CartsRepositoryImpl implements CartsRepository {
  const CartsRepositoryImpl(
    this._remote, {
    this.reportError = reportUnexpectedError,
  });
  final CartsRemoteDataSource _remote;
  final ErrorReporter reportError;
  CartsEntity _entity(CartsModel m) => CartsEntity(
    id: m.id,
    userId: m.userId,
    date: m.date,
    products: m.products
        .map(
          (p) => CartLineEntity(productId: p.productId, quantity: p.quantity),
        )
        .toList(),
  );
  @override
  Future<Result<List<CartsEntity>, Failure>> fetch() => repositoryGuard(
    () async => (await _remote.fetch())
        .map((j) => _entity(CartsModel.fromJson(j)))
        .toList(),
    reportError,
  );
  @override
  Future<Result<CartsEntity, Failure>> createCart(CartDraft draft) =>
      repositoryGuard(
        () async => _entity(
          CartsModel.fromJson(
            await _remote.createCart({
              'userId': draft.userId,
              'date': DateTime.now().toUtc().toIso8601String(),
              'products': [
                {'productId': draft.productId, 'quantity': draft.quantity},
              ],
            }),
          ),
        ),
        reportError,
      );
  @override
  Future<Result<void, Failure>> deleteCart(int id) =>
      repositoryGuard<void>(() => _remote.deleteCart(id), reportError);
}
