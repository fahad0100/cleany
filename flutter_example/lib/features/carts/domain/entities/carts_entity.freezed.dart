// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'carts_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CartsEntity {

 int get id; int get userId; DateTime get date; List<CartLineEntity> get products;
/// Create a copy of CartsEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartsEntityCopyWith<CartsEntity> get copyWith => _$CartsEntityCopyWithImpl<CartsEntity>(this as CartsEntity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CartsEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartsEntity&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.date, _this.date) || other.date == _this.date)&&const DeepCollectionEquality().equals(other.products, _this.products));
}


@override
int get hashCode {
  final _this = this as CartsEntity;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.date,const DeepCollectionEquality().hash(_this.products));
}

@override
String toString() {
  final _this = this as CartsEntity;
  return 'CartsEntity(id: ${_this.id}, userId: ${_this.userId}, date: ${_this.date}, products: ${_this.products})';
}


}

/// @nodoc
abstract mixin class $CartsEntityCopyWith<$Res>  {
  factory $CartsEntityCopyWith(CartsEntity value, $Res Function(CartsEntity) _then) = _$CartsEntityCopyWithImpl;
@useResult
$Res call({
 int id, int userId, DateTime date, List<CartLineEntity> products
});




}
/// @nodoc
class _$CartsEntityCopyWithImpl<$Res>
    implements $CartsEntityCopyWith<$Res> {
  _$CartsEntityCopyWithImpl(this._self, this._then);

  final CartsEntity _self;
  final $Res Function(CartsEntity) _then;

/// Create a copy of CartsEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? date = null,Object? products = null,}) {
  return _then(CartsEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<CartLineEntity>,
  ));
}

}


/// Adds pattern-matching-related methods to [CartsEntity].
extension CartsEntityPatterns on CartsEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartsEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartsEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartsEntity value)  $default,){
final _that = this;
switch (_that) {
case _CartsEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartsEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CartsEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int userId,  DateTime date,  List<CartLineEntity> products)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartsEntity() when $default != null:
return $default(_that.id,_that.userId,_that.date,_that.products);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int userId,  DateTime date,  List<CartLineEntity> products)  $default,) {final _that = this;
switch (_that) {
case _CartsEntity():
return $default(_that.id,_that.userId,_that.date,_that.products);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int userId,  DateTime date,  List<CartLineEntity> products)?  $default,) {final _that = this;
switch (_that) {
case _CartsEntity() when $default != null:
return $default(_that.id,_that.userId,_that.date,_that.products);case _:
  return null;

}
}

}

/// @nodoc


class _CartsEntity implements CartsEntity {
  const _CartsEntity({required this.id, required this.userId, required this.date, required  List<CartLineEntity> products}): _products = products;
  

@override final  int id;
@override final  int userId;
@override final  DateTime date;
 final  List<CartLineEntity> _products;
@override List<CartLineEntity> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}


/// Create a copy of CartsEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartsEntityCopyWith<_CartsEntity> get copyWith => __$CartsEntityCopyWithImpl<_CartsEntity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartsEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.products, _products));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,date,const DeepCollectionEquality().hash(_products));
}

@override
String toString() {
    return 'CartsEntity(id: $id, userId: $userId, date: $date, products: $products)';
}


}

/// @nodoc
abstract mixin class _$CartsEntityCopyWith<$Res> implements $CartsEntityCopyWith<$Res> {
  factory _$CartsEntityCopyWith(_CartsEntity value, $Res Function(_CartsEntity) _then) = __$CartsEntityCopyWithImpl;
@override @useResult
$Res call({
 int id, int userId, DateTime date, List<CartLineEntity> products
});




}
/// @nodoc
class __$CartsEntityCopyWithImpl<$Res>
    implements _$CartsEntityCopyWith<$Res> {
  __$CartsEntityCopyWithImpl(this._self, this._then);

  final _CartsEntity _self;
  final $Res Function(_CartsEntity) _then;

/// Create a copy of CartsEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? date = null,Object? products = null,}) {
  return _then(_CartsEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<CartLineEntity>,
  ));
}


}

/// @nodoc
mixin _$CartLineEntity {

 int get productId; int get quantity; String get title; String get image; double get unitPrice;
/// Create a copy of CartLineEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartLineEntityCopyWith<CartLineEntity> get copyWith => _$CartLineEntityCopyWithImpl<CartLineEntity>(this as CartLineEntity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CartLineEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartLineEntity&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.image, _this.image) || other.image == _this.image)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice));
}


@override
int get hashCode {
  final _this = this as CartLineEntity;
  return Object.hash(runtimeType,_this.productId,_this.quantity,_this.title,_this.image,_this.unitPrice);
}

@override
String toString() {
  final _this = this as CartLineEntity;
  return 'CartLineEntity(productId: ${_this.productId}, quantity: ${_this.quantity}, title: ${_this.title}, image: ${_this.image}, unitPrice: ${_this.unitPrice})';
}


}

/// @nodoc
abstract mixin class $CartLineEntityCopyWith<$Res>  {
  factory $CartLineEntityCopyWith(CartLineEntity value, $Res Function(CartLineEntity) _then) = _$CartLineEntityCopyWithImpl;
@useResult
$Res call({
 int productId, int quantity, String title, String image, double unitPrice
});




}
/// @nodoc
class _$CartLineEntityCopyWithImpl<$Res>
    implements $CartLineEntityCopyWith<$Res> {
  _$CartLineEntityCopyWithImpl(this._self, this._then);

  final CartLineEntity _self;
  final $Res Function(CartLineEntity) _then;

/// Create a copy of CartLineEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? quantity = null,Object? title = null,Object? image = null,Object? unitPrice = null,}) {
  return _then(CartLineEntity(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CartLineEntity].
extension CartLineEntityPatterns on CartLineEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartLineEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartLineEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartLineEntity value)  $default,){
final _that = this;
switch (_that) {
case _CartLineEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartLineEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CartLineEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  int quantity,  String title,  String image,  double unitPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartLineEntity() when $default != null:
return $default(_that.productId,_that.quantity,_that.title,_that.image,_that.unitPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  int quantity,  String title,  String image,  double unitPrice)  $default,) {final _that = this;
switch (_that) {
case _CartLineEntity():
return $default(_that.productId,_that.quantity,_that.title,_that.image,_that.unitPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  int quantity,  String title,  String image,  double unitPrice)?  $default,) {final _that = this;
switch (_that) {
case _CartLineEntity() when $default != null:
return $default(_that.productId,_that.quantity,_that.title,_that.image,_that.unitPrice);case _:
  return null;

}
}

}

/// @nodoc


class _CartLineEntity implements CartLineEntity {
  const _CartLineEntity({required this.productId, required this.quantity, this.title = '', this.image = '', this.unitPrice = 0});
  

@override final  int productId;
@override final  int quantity;
@override@JsonKey() final  String title;
@override@JsonKey() final  String image;
@override@JsonKey() final  double unitPrice;

/// Create a copy of CartLineEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartLineEntityCopyWith<_CartLineEntity> get copyWith => __$CartLineEntityCopyWithImpl<_CartLineEntity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartLineEntity&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.title, title) || other.title == title)&&(identical(other.image, image) || other.image == image)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,quantity,title,image,unitPrice);
}

@override
String toString() {
    return 'CartLineEntity(productId: $productId, quantity: $quantity, title: $title, image: $image, unitPrice: $unitPrice)';
}


}

/// @nodoc
abstract mixin class _$CartLineEntityCopyWith<$Res> implements $CartLineEntityCopyWith<$Res> {
  factory _$CartLineEntityCopyWith(_CartLineEntity value, $Res Function(_CartLineEntity) _then) = __$CartLineEntityCopyWithImpl;
@override @useResult
$Res call({
 int productId, int quantity, String title, String image, double unitPrice
});




}
/// @nodoc
class __$CartLineEntityCopyWithImpl<$Res>
    implements _$CartLineEntityCopyWith<$Res> {
  __$CartLineEntityCopyWithImpl(this._self, this._then);

  final _CartLineEntity _self;
  final $Res Function(_CartLineEntity) _then;

/// Create a copy of CartLineEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? quantity = null,Object? title = null,Object? image = null,Object? unitPrice = null,}) {
  return _then(_CartLineEntity(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
