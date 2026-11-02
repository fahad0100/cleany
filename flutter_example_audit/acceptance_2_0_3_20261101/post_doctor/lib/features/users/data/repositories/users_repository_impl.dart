import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/core/errors/error_reporter.dart';
import 'package:cleany_store/core/errors/repository_guard.dart';

import '../../domain/entities/users_entity.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/users_remote_data_source.dart';
import '../models/users_model.dart';

/// Owns JSON -> DTO -> Entity conversion and the single Failure boundary.
class UsersRepositoryImpl implements UsersRepository {
  const UsersRepositoryImpl(
    this._remote, {
    this.reportError = reportUnexpectedError,
  });
  final UsersRemoteDataSource _remote;
  final ErrorReporter reportError;
  UsersEntity _entity(UsersModel m) => UsersEntity(
    id: m.id,
    username: m.username,
    email: m.email,
    firstName: m.name.firstname,
    lastName: m.name.lastname,
    phone: m.phone,
    city: m.address.city,
    street: m.address.street,
    zipcode: m.address.zipcode,
  );
  @override
  Future<Result<List<UsersEntity>, Failure>> fetch() => repositoryGuard(
    () async => (await _remote.fetch())
        .map((j) => _entity(UsersModel.fromJson(j)))
        .toList(),
    reportError,
  );
  @override
  Future<Result<UsersEntity, Failure>> getUserProfile(int id) =>
      repositoryGuard(
        () async =>
            _entity(UsersModel.fromJson(await _remote.getUserProfile(id))),
        reportError,
      );
}
