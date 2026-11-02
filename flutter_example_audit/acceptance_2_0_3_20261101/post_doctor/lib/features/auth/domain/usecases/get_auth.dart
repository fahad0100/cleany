// Exposes one business operation through the domain repository contract.
import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

/// Exposes one business operation through the domain repository contract.
class GetAuth {
  const GetAuth(this._repository);
  final AuthRepository _repository;
  Future<Result<AuthEntity, Failure>> call() => _repository.fetch();
}
