// Immutable business data; transport DTOs stay in Data.
import 'package:freezed_annotation/freezed_annotation.dart';
part 'products_entity.freezed.dart';

@freezed
abstract class ProductsEntity with _$ProductsEntity {
  const factory ProductsEntity({
    required int id,
    required String title,
    required double price,
    required String description,
    required String category,
    required String image,
    @Default(0) double rating,
    @Default(0) int reviewCount,
  }) = _ProductsEntity;
}
