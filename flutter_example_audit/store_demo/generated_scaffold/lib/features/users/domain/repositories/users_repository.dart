// Defines the domain repository contract returning an Entity or Failure in a Result.
import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../entities/users_entity.dart';

/// Defines the domain repository contract returning an Entity or Failure in a Result.
abstract interface class UsersRepository {
  Future<Result<UsersEntity, Failure>> fetch();

  /// Runs getUserProfile, returning domain data or a Failure.
  Future<Result<UsersEntity, Failure>> getUserProfile();
}
