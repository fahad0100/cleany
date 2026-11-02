// Exposes one business operation through the domain repository contract.
import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../repositories/auth_repository.dart';

import 'package:cleany_store/features/auth/domain/entities/auth_entity.dart';

/// Exposes one business operation through the domain repository contract.
/// Runs signIn through the feature's transport-independent contract.
class SignIn {
  const SignIn(this._repository);
  final AuthRepository _repository;
  Future<Result<AuthEntity, Failure>> call() => _repository.signIn();
}
