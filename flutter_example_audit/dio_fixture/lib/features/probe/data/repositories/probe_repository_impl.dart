// Converts JSON/models into entities and returns Success or Failure exactly once.
import 'package:multiple_result/multiple_result.dart';
import 'package:test_cleany_dio/core/errors/failure.dart';
import 'package:test_cleany_dio/core/errors/error_reporter.dart';
import 'package:test_cleany_dio/core/network/failure_mapper.dart';
import 'package:test_cleany_dio/features/probe/domain/entities/probe_entity.dart';
import 'package:test_cleany_dio/features/probe/domain/repositories/probe_repository.dart';

import '../datasources/probe_remote_data_source.dart';
import '../models/probe_model.dart';

/// Converts JSON/models into entities and returns Success or Failure exactly once.
class ProbeRepositoryImpl implements ProbeRepository {
  const ProbeRepositoryImpl(
    this._remote, {
    this.reportError = reportUnexpectedError,
  });
  final ProbeRemoteDataSource _remote;
  final ErrorReporter reportError;
  @override
  Future<Result<ProbeEntity, Failure>> fetch() async {
    try {
      final json = await _remote.fetch();
      final model = ProbeModel.fromJson(json);
      return Success(ProbeEntity(id: model.id));
    } catch (error, stackTrace) {
      final failure = mapFailure(error);
      if (failure is UnexpectedFailure) reportError(error, stackTrace);
      return Error(failure);
    }
  }
}
