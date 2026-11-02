// Defines the domain repository contract returning an Entity or Failure in a Result.
import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../entities/auth_entity.dart';

/// Defines the domain repository contract returning an Entity or Failure in a Result.
abstract interface class AuthRepository {
  Future<Result<AuthEntity, Failure>> fetch();

  /// Runs signIn, returning domain data or a Failure.
  Future<Result<AuthEntity, Failure>> signIn();

  /// Runs signOut, returning domain data or a Failure.
  Future<Result<void, Failure>> signOut();
}
