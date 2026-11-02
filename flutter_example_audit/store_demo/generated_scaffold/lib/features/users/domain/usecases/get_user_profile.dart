// Exposes one business operation through the domain repository contract.
import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../repositories/users_repository.dart';

import 'package:cleany_store/features/users/domain/entities/users_entity.dart';

/// Exposes one business operation through the domain repository contract.
/// Runs getUserProfile through the feature's transport-independent contract.
class GetUserProfile {
  const GetUserProfile(this._repository);
  final UsersRepository _repository;
  Future<Result<UsersEntity, Failure>> call() => _repository.getUserProfile();
}
