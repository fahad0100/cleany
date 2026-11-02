// Immutable business data; transport DTOs stay in Data.
import 'package:freezed_annotation/freezed_annotation.dart';
part 'users_entity.freezed.dart';

@freezed
abstract class UsersEntity with _$UsersEntity {
  const factory UsersEntity({
    required int id,
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String street,
    required String zipcode,
  }) = _UsersEntity;
}
