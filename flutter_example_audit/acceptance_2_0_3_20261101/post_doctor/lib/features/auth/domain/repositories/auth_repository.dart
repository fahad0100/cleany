import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../entities/auth_entity.dart';

/// Business contract shared by all operations on this feature.
abstract interface class AuthRepository {
  Future<Result<AuthEntity, Failure>> fetch();
  Future<Result<AuthEntity, Failure>> signIn({
    required String username,
    required String password,
  });
  Future<Result<void, Failure>> signOut();
}
