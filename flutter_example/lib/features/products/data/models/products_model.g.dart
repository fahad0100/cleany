// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductsModel _$ProductsModelFromJson(Map<String, dynamic> json) =>
    _ProductsModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      rating: RatingModel.fromJson(json['rating'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProductsModelToJson(_ProductsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'price': instance.price,
      'description': instance.description,
      'category': instance.category,
      'image': instance.image,
      'rating': instance.rating,
    };

_RatingModel _$RatingModelFromJson(Map<String, dynamic> json) => _RatingModel(
  rate: (json['rate'] as num).toDouble(),
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$RatingModelToJson(_RatingModel instance) =>
    <String, dynamic>{'rate': instance.rate, 'count': instance.count};
