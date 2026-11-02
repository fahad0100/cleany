import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/core/errors/error_reporter.dart';
import 'package:cleany_store/core/errors/repository_guard.dart';

import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_model.dart';

import 'package:cleany_store/core/storage/session_store.dart';

/// Owns JSON -> DTO -> Entity conversion and the single Failure boundary.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(
    this._remote,
    this._session, {
    this.reportError = reportUnexpectedError,
  });
  final AuthRemoteDataSource _remote;
  final ErrorReporter reportError;
  final SessionStore _session;
  @override
  Future<Result<AuthEntity, Failure>> fetch() async {
    final current = _session.value;
    if (current == null) return const Error(UnauthorizedFailure());
    return Success(
      AuthEntity(
        token: current.accessToken,
        username: current.username,
        userId: current.userId,
      ),
    );
  }

  @override
  Future<Result<AuthEntity, Failure>> signIn({
    required String username,
    required String password,
  }) => repositoryGuard(() async {
    final model = AuthModel.fromJson(await _remote.signIn(username, password));
    final users = await _remote.users();
    final user = users.where((u) => u['username'] == username).firstOrNull;
    if (model.token.isEmpty || user == null || user['id'] is! int) {
      throw const FormatException('Invalid session response.');
    }
    final entity = AuthEntity(
      token: model.token,
      username: username,
      userId: user['id'] as int,
    );
    _session.signIn(
      SessionData(
        accessToken: entity.token,
        username: entity.username,
        userId: entity.userId,
      ),
    );
    return entity;
  }, reportError);
  @override
  Future<Result<void, Failure>> signOut() async {
    _session.signOut();
    return const Success<void, Failure>(null);
  }
}
