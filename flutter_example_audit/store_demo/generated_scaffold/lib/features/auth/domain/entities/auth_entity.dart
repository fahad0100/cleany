// Defines immutable business data consumed by use cases and presentation.
import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_entity.freezed.dart';

/// Defines immutable business data consumed by use cases and presentation.
@freezed
abstract class AuthEntity with _$AuthEntity {
  const factory AuthEntity({required String id}) = _AuthEntity;
}
