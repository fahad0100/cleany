import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../entities/users_entity.dart';
import '../repositories/users_repository.dart';

class GetUserProfile {
  const GetUserProfile(this._repository);
  final UsersRepository _repository;
  Future<Result<UsersEntity, Failure>> call(int id) => id > 0
      ? _repository.getUserProfile(id)
      : Future.value(const Error(ValidationFailure()));
}
