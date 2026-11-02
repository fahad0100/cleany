// Defines immutable business data consumed by use cases and presentation.
import 'package:freezed_annotation/freezed_annotation.dart';
part 'carts_entity.freezed.dart';

/// Defines immutable business data consumed by use cases and presentation.
@freezed
abstract class CartsEntity with _$CartsEntity {
  const factory CartsEntity({required String id}) = _CartsEntity;
}
