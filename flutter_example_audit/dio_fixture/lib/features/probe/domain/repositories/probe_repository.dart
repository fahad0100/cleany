// Defines the domain repository contract returning an Entity or Failure in a Result.
import 'package:multiple_result/multiple_result.dart';
import 'package:test_cleany_dio/core/errors/failure.dart';

import '../entities/probe_entity.dart';

/// Defines the domain repository contract returning an Entity or Failure in a Result.
abstract interface class ProbeRepository {
  Future<Result<ProbeEntity, Failure>> fetch();
}
