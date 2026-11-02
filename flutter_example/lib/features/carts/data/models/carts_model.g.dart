// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carts_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartsModel _$CartsModelFromJson(Map<String, dynamic> json) => _CartsModel(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  date: DateTime.parse(json['date'] as String),
  products: (json['products'] as List<dynamic>)
      .map((e) => CartProductModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CartsModelToJson(_CartsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'date': instance.date.toIso8601String(),
      'products': instance.products,
    };

_CartProductModel _$CartProductModelFromJson(Map<String, dynamic> json) =>
    _CartProductModel(
      productId: (json['productId'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$CartProductModelToJson(_CartProductModel instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'quantity': instance.quantity,
    };
