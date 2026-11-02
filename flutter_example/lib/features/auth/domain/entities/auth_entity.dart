// Immutable business data; transport DTOs stay in Data.
import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_entity.freezed.dart';

@Freezed(toStringOverride: false)
abstract class AuthEntity with _$AuthEntity {
  const AuthEntity._();
  const factory AuthEntity({
    required String token,
    required String username,
    required int userId,
  }) = _AuthEntity;
  @override
  String toString() =>
      'AuthEntity(userId: $userId, authenticated: ${token.isNotEmpty})';
}
