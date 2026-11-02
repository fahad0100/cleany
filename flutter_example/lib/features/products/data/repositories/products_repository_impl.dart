import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/core/errors/error_reporter.dart';
import 'package:cleany_store/core/errors/repository_guard.dart';

import '../../domain/entities/products_entity.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_data_source.dart';
import '../models/products_model.dart';

/// Owns JSON -> DTO -> Entity conversion and the single Failure boundary.
class ProductsRepositoryImpl implements ProductsRepository {
  const ProductsRepositoryImpl(
    this._remote, {
    this.reportError = reportUnexpectedError,
  });
  final ProductsRemoteDataSource _remote;
  final ErrorReporter reportError;
  ProductsEntity _entity(ProductsModel m) => ProductsEntity(
    id: m.id,
    title: m.title,
    price: m.price,
    description: m.description,
    category: m.category,
    image: m.image,
    rating: m.rating.rate,
    reviewCount: m.rating.count,
  );
  @override
  Future<Result<List<ProductsEntity>, Failure>> fetch() => repositoryGuard(
    () async => (await _remote.fetch())
        .map((j) => _entity(ProductsModel.fromJson(j)))
        .toList(),
    reportError,
  );
  @override
  Future<Result<ProductsEntity, Failure>> getFeaturedProduct() =>
      repositoryGuard(
        () async =>
            _entity(ProductsModel.fromJson(await _remote.getFeaturedProduct())),
        reportError,
      );
}
