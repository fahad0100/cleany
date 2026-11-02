// Converts JSON/models into entities and returns Success or Failure exactly once.
import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/core/errors/error_reporter.dart';
import 'package:cleany_store/core/network/failure_mapper.dart';
import 'package:cleany_store/features/users/domain/entities/users_entity.dart';
import 'package:cleany_store/features/users/domain/repositories/users_repository.dart';

import '../datasources/users_remote_data_source.dart';
import '../models/users_model.dart';

/// Converts JSON/models into entities and returns Success or Failure exactly once.
class UsersRepositoryImpl implements UsersRepository {
  const UsersRepositoryImpl(
    this._remote, {
    this.reportError = reportUnexpectedError,
  });
  final UsersRemoteDataSource _remote;
  final ErrorReporter reportError;
  @override
  Future<Result<UsersEntity, Failure>> fetch() async {
    try {
      final json = await _remote.fetch();
      final model = UsersModel.fromJson(json);
      return Success(UsersEntity(id: model.id));
    } catch (error, stackTrace) {
      final failure = mapFailure(error);
      if (failure is UnexpectedFailure) reportError(error, stackTrace);
      return Error(failure);
    }
  }

  /// Executes getUserProfile; maps transport data and errors at this boundary.
  @override
  Future<Result<UsersEntity, Failure>> getUserProfile() async {
    try {
      final json = await _remote.getUserProfile();
      final model = UsersModel.fromJson(json);
      return Success(UsersEntity(id: model.id));
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
