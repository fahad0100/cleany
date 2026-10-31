// Exposes one business operation through the domain repository contract.
import 'package:multiple_result/multiple_result.dart';
import 'package:test_cleany_dio/core/errors/failure.dart';

import '../entities/probe_entity.dart';
import '../repositories/probe_repository.dart';

/// Exposes one business operation through the domain repository contract.
class GetProbe {
  const GetProbe(this._repository);
  final ProbeRepository _repository;
  Future<Result<ProbeEntity, Failure>> call() => _repository.fetch();
}
