// Converts JSON/models into entities and returns Success or Failure exactly once.
import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/core/errors/error_reporter.dart';
import 'package:cleany_store/core/network/failure_mapper.dart';
import 'package:cleany_store/features/products/domain/entities/products_entity.dart';
import 'package:cleany_store/features/products/domain/repositories/products_repository.dart';

import '../datasources/products_remote_data_source.dart';
import '../models/products_model.dart';

/// Converts JSON/models into entities and returns Success or Failure exactly once.
class ProductsRepositoryImpl implements ProductsRepository {
  const ProductsRepositoryImpl(
    this._remote, {
    this.reportError = reportUnexpectedError,
  });
  final ProductsRemoteDataSource _remote;
  final ErrorReporter reportError;
  @override
  Future<Result<ProductsEntity, Failure>> fetch() async {
    try {
      final json = await _remote.fetch();
      final model = ProductsModel.fromJson(json);
      return Success(ProductsEntity(id: model.id));
    } catch (error, stackTrace) {
      final failure = mapFailure(error);
      if (failure is UnexpectedFailure) reportError(error, stackTrace);
      return Error(failure);
    }
  }

  /// Executes getFeaturedProduct; maps transport data and errors at this boundary.
  @override
  Future<Result<ProductsEntity, Failure>> getFeaturedProduct() async {
    try {
      final json = await _remote.getFeaturedProduct();
      final model = ProductsModel.fromJson(json);
      return Success(ProductsEntity(id: model.id));
    } catch (error, stackTrace) {
      final failure = mapFailure(error);
      if (failure is UnexpectedFailure) {
        // Reporting is observational and must preserve the original Result.
        try {
          reportError(error, stackTrace);
        } catch (_) {
          /* Keep the original failure. */
        }
      }
      return Error(failure);
    }
  }
}
