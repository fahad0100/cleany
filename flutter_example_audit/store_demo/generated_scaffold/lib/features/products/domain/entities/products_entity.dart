// Defines immutable business data consumed by use cases and presentation.
import 'package:freezed_annotation/freezed_annotation.dart';
part 'products_entity.freezed.dart';

/// Defines immutable business data consumed by use cases and presentation.
@freezed
abstract class ProductsEntity with _$ProductsEntity {
  const factory ProductsEntity({required String id}) = _ProductsEntity;
}
