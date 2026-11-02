// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'products_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductsEntity {

 int get id; String get title; double get price; String get description; String get category; String get image; double get rating; int get reviewCount;
/// Create a copy of ProductsEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsEntityCopyWith<ProductsEntity> get copyWith => _$ProductsEntityCopyWithImpl<ProductsEntity>(this as ProductsEntity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProductsEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsEntity&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.image, _this.image) || other.image == _this.image)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.reviewCount, _this.reviewCount) || other.reviewCount == _this.reviewCount));
}


@override
int get hashCode {
  final _this = this as ProductsEntity;
  return Object.hash(runtimeType,_this.id,_this.title,_this.price,_this.description,_this.category,_this.image,_this.rating,_this.reviewCount);
}

@override
String toString() {
  final _this = this as ProductsEntity;
  return 'ProductsEntity(id: ${_this.id}, title: ${_this.title}, price: ${_this.price}, description: ${_this.description}, category: ${_this.category}, image: ${_this.image}, rating: ${_this.rating}, reviewCount: ${_this.reviewCount})';
}


}

/// @nodoc
abstract mixin class $ProductsEntityCopyWith<$Res>  {
  factory $ProductsEntityCopyWith(ProductsEntity value, $Res Function(ProductsEntity) _then) = _$ProductsEntityCopyWithImpl;
@useResult
$Res call({
 int id, String title, double price, String description, String category, String image, double rating, int reviewCount
});




}
/// @nodoc
class _$ProductsEntityCopyWithImpl<$Res>
    implements $ProductsEntityCopyWith<$Res> {
  _$ProductsEntityCopyWithImpl(this._self, this._then);

  final ProductsEntity _self;
  final $Res Function(ProductsEntity) _then;

/// Create a copy of ProductsEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? price = null,Object? description = null,Object? category = null,Object? image = null,Object? rating = null,Object? reviewCount = null,}) {
  return _then(ProductsEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductsEntity].
extension ProductsEntityPatterns on ProductsEntity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductsEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductsEntity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductsEntity value)  $default,){
final _that = this;
switch (_that) {
case _ProductsEntity():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductsEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ProductsEntity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  double price,  String description,  String category,  String image,  double rating,  int reviewCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductsEntity() when $default != null:
return $default(_that.id,_that.title,_that.price,_that.description,_that.category,_that.image,_that.rating,_that.reviewCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  double price,  String description,  String category,  String image,  double rating,  int reviewCount)  $default,) {final _that = this;
switch (_that) {
case _ProductsEntity():
return $default(_that.id,_that.title,_that.price,_that.description,_that.category,_that.image,_that.rating,_that.reviewCount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  double price,  String description,  String category,  String image,  double rating,  int reviewCount)?  $default,) {final _that = this;
switch (_that) {
case _ProductsEntity() when $default != null:
return $default(_that.id,_that.title,_that.price,_that.description,_that.category,_that.image,_that.rating,_that.reviewCount);case _:
  return null;

}
}

}

/// @nodoc


class _ProductsEntity implements ProductsEntity {
  const _ProductsEntity({required this.id, required this.title, required this.price, required this.description, required this.category, required this.image, this.rating = 0, this.reviewCount = 0});
  

@override final  int id;
@override final  String title;
@override final  double price;
@override final  String description;
@override final  String category;
@override final  String image;
@override@JsonKey() final  double rating;
@override@JsonKey() final  int reviewCount;

/// Create a copy of ProductsEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductsEntityCopyWith<_ProductsEntity> get copyWith => __$ProductsEntityCopyWithImpl<_ProductsEntity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductsEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.image, image) || other.image == image)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,title,price,description,category,image,rating,reviewCount);
}

@override
String toString() {
    return 'ProductsEntity(id: $id, title: $title, price: $price, description: $description, category: $category, image: $image, rating: $rating, reviewCount: $reviewCount)';
}


}

/// @nodoc
abstract mixin class _$ProductsEntityCopyWith<$Res> implements $ProductsEntityCopyWith<$Res> {
  factory _$ProductsEntityCopyWith(_ProductsEntity value, $Res Function(_ProductsEntity) _then) = __$ProductsEntityCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, double price, String description, String category, String image, double rating, int reviewCount
});




}
/// @nodoc
class __$ProductsEntityCopyWithImpl<$Res>
    implements _$ProductsEntityCopyWith<$Res> {
  __$ProductsEntityCopyWithImpl(this._self, this._then);

  final _ProductsEntity _self;
  final $Res Function(_ProductsEntity) _then;

/// Create a copy of ProductsEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? price = null,Object? description = null,Object? category = null,Object? image = null,Object? rating = null,Object? reviewCount = null,}) {
  return _then(_ProductsEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
