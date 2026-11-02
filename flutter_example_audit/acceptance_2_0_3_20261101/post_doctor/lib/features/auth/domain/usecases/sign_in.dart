import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';

import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  const SignIn(this._repository);
  final AuthRepository _repository;
  Future<Result<AuthEntity, Failure>> call({
    required String username,
    required String password,
  }) {
    if (username.trim().isEmpty || password.isEmpty) {
      return Future.value(const Error(ValidationFailure()));
    }
    return _repository.signIn(username: username.trim(), password: password);
  }
}
