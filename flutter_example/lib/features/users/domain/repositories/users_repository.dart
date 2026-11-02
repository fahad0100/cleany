import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../entities/users_entity.dart';

/// Business contract shared by all operations on this feature.
abstract interface class UsersRepository {
  Future<Result<List<UsersEntity>, Failure>> fetch();
  Future<Result<UsersEntity, Failure>> getUserProfile(int id);
}
