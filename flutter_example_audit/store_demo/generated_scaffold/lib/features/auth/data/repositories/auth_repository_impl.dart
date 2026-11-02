// Converts JSON/models into entities and returns Success or Failure exactly once.
import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/core/errors/error_reporter.dart';
import 'package:cleany_store/core/network/failure_mapper.dart';
import 'package:cleany_store/features/auth/domain/entities/auth_entity.dart';
import 'package:cleany_store/features/auth/domain/repositories/auth_repository.dart';

import '../datasources/auth_remote_data_source.dart';
import '../models/auth_model.dart';

/// Converts JSON/models into entities and returns Success or Failure exactly once.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(
    this._remote, {
    this.reportError = reportUnexpectedError,
  });
  final AuthRemoteDataSource _remote;
  final ErrorReporter reportError;
  @override
  Future<Result<AuthEntity, Failure>> fetch() async {
    try {
      final json = await _remote.fetch();
      final model = AuthModel.fromJson(json);
      return Success(AuthEntity(id: model.id));
    } catch (error, stackTrace) {
      final failure = mapFailure(error);
      if (failure is UnexpectedFailure) reportError(error, stackTrace);
      return Error(failure);
    }
  }

  /// Executes signIn; maps transport data and errors at this boundary.
  @override
  Future<Result<AuthEntity, Failure>> signIn() async {
    try {
      final json = await _remote.signIn();
      final model = AuthModel.fromJson(json);
      return Success(AuthEntity(id: model.id));
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

  /// Executes signOut; maps transport data and errors at this boundary.
  @override
  Future<Result<void, Failure>> signOut() async {
    try {
      await _remote.signOut();
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
