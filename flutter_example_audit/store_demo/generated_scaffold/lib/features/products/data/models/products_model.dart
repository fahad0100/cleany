// Defines the API data model and its generated JSON serialization.
// Freezed forwards JSON annotations to the generated properties.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
part 'products_model.freezed.dart';
part 'products_model.g.dart';

/// Defines the API data model and its generated JSON serialization.
@freezed
abstract class ProductsModel with _$ProductsModel {
  const factory ProductsModel({required String id}) = _ProductsModel;
  factory ProductsModel.fromJson(Map<String, dynamic> json) =>
      _$ProductsModelFromJson(json);
}
