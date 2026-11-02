// Converts JSON/models into entities and returns Success or Failure exactly once.
import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/core/errors/error_reporter.dart';
import 'package:cleany_store/core/network/failure_mapper.dart';
import 'package:cleany_store/features/carts/domain/entities/carts_entity.dart';
import 'package:cleany_store/features/carts/domain/repositories/carts_repository.dart';

import '../datasources/carts_remote_data_source.dart';
import '../models/carts_model.dart';

/// Converts JSON/models into entities and returns Success or Failure exactly once.
class CartsRepositoryImpl implements CartsRepository {
  const CartsRepositoryImpl(
    this._remote, {
    this.reportError = reportUnexpectedError,
  });
  final CartsRemoteDataSource _remote;
  final ErrorReporter reportError;
  @override
  Future<Result<CartsEntity, Failure>> fetch() async {
    try {
      final json = await _remote.fetch();
      final model = CartsModel.fromJson(json);
      return Success(CartsEntity(id: model.id));
    } catch (error, stackTrace) {
      final failure = mapFailure(error);
      if (failure is UnexpectedFailure) reportError(error, stackTrace);
      return Error(failure);
    }
  }

  /// Executes createCart; maps transport data and errors at this boundary.
  @override
  Future<Result<CartsEntity, Failure>> createCart() async {
    try {
      final json = await _remote.createCart();
      final model = CartsModel.fromJson(json);
      return Success(CartsEntity(id: model.id));
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

  /// Executes deleteCart; maps transport data and errors at this boundary.
  @override
  Future<Result<void, Failure>> deleteCart() async {
    try {
      await _remote.deleteCart();
      return const Success<void, Failure>(null);
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
