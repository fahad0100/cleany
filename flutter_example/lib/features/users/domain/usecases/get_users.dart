import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../entities/users_entity.dart';
import '../repositories/users_repository.dart';

class GetUsers {
  const GetUsers(this._repository);
  final UsersRepository _repository;
  Future<Result<List<UsersEntity>, Failure>> call() => _repository.fetch();
}
