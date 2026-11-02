// The API's JSON shape; conversion to Domain belongs to the repository.
import 'package:freezed_annotation/freezed_annotation.dart';
part 'products_model.freezed.dart';
part 'products_model.g.dart';

@freezed
abstract class ProductsModel with _$ProductsModel {
  const factory ProductsModel({
    required int id,
    required String title,
    required double price,
    required String description,
    required String category,
    required String image,
    required RatingModel rating,
  }) = _ProductsModel;
  factory ProductsModel.fromJson(Map<String, dynamic> json) =>
      _$ProductsModelFromJson(json);
}

@freezed
abstract class RatingModel with _$RatingModel {
  const factory RatingModel({required double rate, required int count}) =
      _RatingModel;
  factory RatingModel.fromJson(Map<String, dynamic> json) =>
      _$RatingModelFromJson(json);
}
