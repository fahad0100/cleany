// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'carts_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CartsModel {

 int get id; int get userId; DateTime get date; List<CartProductModel> get products;
/// Create a copy of CartsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartsModelCopyWith<CartsModel> get copyWith => _$CartsModelCopyWithImpl<CartsModel>(this as CartsModel, _$identity);

  /// Serializes this CartsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CartsModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartsModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.date, _this.date) || other.date == _this.date)&&const DeepCollectionEquality().equals(other.products, _this.products));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CartsModel;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.date,const DeepCollectionEquality().hash(_this.products));
}

@override
String toString() {
  final _this = this as CartsModel;
  return 'CartsModel(id: ${_this.id}, userId: ${_this.userId}, date: ${_this.date}, products: ${_this.products})';
}


}

/// @nodoc
abstract mixin class $CartsModelCopyWith<$Res>  {
  factory $CartsModelCopyWith(CartsModel value, $Res Function(CartsModel) _then) = _$CartsModelCopyWithImpl;
@useResult
$Res call({
 int id, int userId, DateTime date, List<CartProductModel> products
});




}
/// @nodoc
class _$CartsModelCopyWithImpl<$Res>
    implements $CartsModelCopyWith<$Res> {
  _$CartsModelCopyWithImpl(this._self, this._then);

  final CartsModel _self;
  final $Res Function(CartsModel) _then;

/// Create a copy of CartsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? date = null,Object? products = null,}) {
  return _then(CartsModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<CartProductModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [CartsModel].
extension CartsModelPatterns on CartsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartsModel value)  $default,){
final _that = this;
switch (_that) {
case _CartsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartsModel value)?  $default,){
final _that = this;
switch (_that) {
case _CartsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int userId,  DateTime date,  List<CartProductModel> products)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartsModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int userId,  DateTime date,  List<CartProductModel> products)  $default,) {final _that = this;
switch (_that) {
case _CartsModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int userId,  DateTime date,  List<CartProductModel> products)?  $default,) {final _that = this;
switch (_that) {
case _CartsModel() when $default != null:
return $default(_that.id,_that.userId,_that.date,_that.products);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartsModel implements CartsModel {
  const _CartsModel({required this.id, required this.userId, required this.date, required  List<CartProductModel> products}): _products = products;
  factory _CartsModel.fromJson(Map<String, dynamic> json) => _$CartsModelFromJson(json);

@override final  int id;
@override final  int userId;
@override final  DateTime date;
 final  List<CartProductModel> _products;
@override List<CartProductModel> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}


/// Create a copy of CartsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartsModelCopyWith<_CartsModel> get copyWith => __$CartsModelCopyWithImpl<_CartsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartsModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartsModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.products, _products));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,date,const DeepCollectionEquality().hash(_products));
}

@override
String toString() {
    return 'CartsModel(id: $id, userId: $userId, date: $date, products: $products)';
}


}

/// @nodoc
abstract mixin class _$CartsModelCopyWith<$Res> implements $CartsModelCopyWith<$Res> {
  factory _$CartsModelCopyWith(_CartsModel value, $Res Function(_CartsModel) _then) = __$CartsModelCopyWithImpl;
@override @useResult
$Res call({
 int id, int userId, DateTime date, List<CartProductModel> products
});




}
/// @nodoc
class __$CartsModelCopyWithImpl<$Res>
    implements _$CartsModelCopyWith<$Res> {
  __$CartsModelCopyWithImpl(this._self, this._then);

  final _CartsModel _self;
  final $Res Function(_CartsModel) _then;

/// Create a copy of CartsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? date = null,Object? products = null,}) {
  return _then(_CartsModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<CartProductModel>,
  ));
}


}


/// @nodoc
mixin _$CartProductModel {

 int get productId; int get quantity;
/// Create a copy of CartProductModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartProductModelCopyWith<CartProductModel> get copyWith => _$CartProductModelCopyWithImpl<CartProductModel>(this as CartProductModel, _$identity);

  /// Serializes this CartProductModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CartProductModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartProductModel&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CartProductModel;
  return Object.hash(runtimeType,_this.productId,_this.quantity);
}

@override
String toString() {
  final _this = this as CartProductModel;
  return 'CartProductModel(productId: ${_this.productId}, quantity: ${_this.quantity})';
}


}

/// @nodoc
abstract mixin class $CartProductModelCopyWith<$Res>  {
  factory $CartProductModelCopyWith(CartProductModel value, $Res Function(CartProductModel) _then) = _$CartProductModelCopyWithImpl;
@useResult
$Res call({
 int productId, int quantity
});




}
/// @nodoc
class _$CartProductModelCopyWithImpl<$Res>
    implements $CartProductModelCopyWith<$Res> {
  _$CartProductModelCopyWithImpl(this._self, this._then);

  final CartProductModel _self;
  final $Res Function(CartProductModel) _then;

/// Create a copy of CartProductModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? quantity = null,}) {
  return _then(CartProductModel(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CartProductModel].
extension CartProductModelPatterns on CartProductModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartProductModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartProductModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartProductModel value)  $default,){
final _that = this;
switch (_that) {
case _CartProductModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartProductModel value)?  $default,){
final _that = this;
switch (_that) {
case _CartProductModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  int quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartProductModel() when $default != null:
return $default(_that.productId,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  int quantity)  $default,) {final _that = this;
switch (_that) {
case _CartProductModel():
return $default(_that.productId,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  int quantity)?  $default,) {final _that = this;
switch (_that) {
case _CartProductModel() when $default != null:
return $default(_that.productId,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartProductModel implements CartProductModel {
  const _CartProductModel({required this.productId, required this.quantity});
  factory _CartProductModel.fromJson(Map<String, dynamic> json) => _$CartProductModelFromJson(json);

@override final  int productId;
@override final  int quantity;

/// Create a copy of CartProductModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartProductModelCopyWith<_CartProductModel> get copyWith => __$CartProductModelCopyWithImpl<_CartProductModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartProductModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartProductModel&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productId,quantity);
}

@override
String toString() {
    return 'CartProductModel(productId: $productId, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$CartProductModelCopyWith<$Res> implements $CartProductModelCopyWith<$Res> {
  factory _$CartProductModelCopyWith(_CartProductModel value, $Res Function(_CartProductModel) _then) = __$CartProductModelCopyWithImpl;
@override @useResult
$Res call({
 int productId, int quantity
});




}
/// @nodoc
class __$CartProductModelCopyWithImpl<$Res>
    implements _$CartProductModelCopyWith<$Res> {
  __$CartProductModelCopyWithImpl(this._self, this._then);

  final _CartProductModel _self;
  final $Res Function(_CartProductModel) _then;

/// Create a copy of CartProductModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? quantity = null,}) {
  return _then(_CartProductModel(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
