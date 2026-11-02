// Defines the API data model and its generated JSON serialization.
// Freezed forwards JSON annotations to the generated properties.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
part 'carts_model.freezed.dart';
part 'carts_model.g.dart';

/// Defines the API data model and its generated JSON serialization.
@freezed
abstract class CartsModel with _$CartsModel {
  const factory CartsModel({required String id}) = _CartsModel;
  factory CartsModel.fromJson(Map<String, dynamic> json) =>
      _$CartsModelFromJson(json);
}
