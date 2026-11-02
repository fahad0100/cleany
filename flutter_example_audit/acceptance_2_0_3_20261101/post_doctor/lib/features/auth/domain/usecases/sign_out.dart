// Exposes one business operation through the domain repository contract.
import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../repositories/auth_repository.dart';

/// Exposes one business operation through the domain repository contract.
/// Runs signOut through the feature's transport-independent contract.
class SignOut {
  const SignOut(this._repository);
  final AuthRepository _repository;
  Future<Result<void, Failure>> call() => _repository.signOut();
}
