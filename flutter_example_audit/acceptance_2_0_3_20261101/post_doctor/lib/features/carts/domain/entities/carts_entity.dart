// Immutable business data; transport DTOs stay in Data.
import 'package:freezed_annotation/freezed_annotation.dart';
part 'carts_entity.freezed.dart';

@freezed
abstract class CartsEntity with _$CartsEntity {
  const factory CartsEntity({
    required int id,
    required int userId,
    required DateTime date,
    required List<CartLineEntity> products,
  }) = _CartsEntity;
}

@freezed
abstract class CartLineEntity with _$CartLineEntity {
  const factory CartLineEntity({
    required int productId,
    required int quantity,
    @Default('') String title,
    @Default('') String image,
    @Default(0) double unitPrice,
  }) = _CartLineEntity;
}
