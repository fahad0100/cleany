// The API's JSON shape; conversion to Domain belongs to the repository.
import 'package:freezed_annotation/freezed_annotation.dart';
part 'carts_model.freezed.dart';
part 'carts_model.g.dart';

@freezed
abstract class CartsModel with _$CartsModel {
  const factory CartsModel({
    required int id,
    required int userId,
    required DateTime date,
    required List<CartProductModel> products,
  }) = _CartsModel;
  factory CartsModel.fromJson(Map<String, dynamic> json) =>
      _$CartsModelFromJson(json);
}

@freezed
abstract class CartProductModel with _$CartProductModel {
  const factory CartProductModel({
    required int productId,
    required int quantity,
  }) = _CartProductModel;
  factory CartProductModel.fromJson(Map<String, dynamic> json) =>
      _$CartProductModelFromJson(json);
}
