// Defines immutable business data consumed by use cases and presentation.
import 'package:freezed_annotation/freezed_annotation.dart';
part 'users_entity.freezed.dart';

/// Defines immutable business data consumed by use cases and presentation.
@freezed
abstract class UsersEntity with _$UsersEntity {
  const factory UsersEntity({required String id}) = _UsersEntity;
}
