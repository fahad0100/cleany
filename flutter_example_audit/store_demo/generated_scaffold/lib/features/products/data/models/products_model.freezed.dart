// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'products_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductsModel {

 String get id;
/// Create a copy of ProductsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsModelCopyWith<ProductsModel> get copyWith => _$ProductsModelCopyWithImpl<ProductsModel>(this as ProductsModel, _$identity);

  /// Serializes this ProductsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProductsModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsModel&&(identical(other.id, _this.id) || other.id == _this.id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductsModel;
  return Object.hash(runtimeType,_this.id);
}

@override
String toString() {
  final _this = this as ProductsModel;
  return 'ProductsModel(id: ${_this.id})';
}


}

/// @nodoc
abstract mixin class $ProductsModelCopyWith<$Res>  {
  factory $ProductsModelCopyWith(ProductsModel value, $Res Function(ProductsModel) _then) = _$ProductsModelCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$ProductsModelCopyWithImpl<$Res>
    implements $ProductsModelCopyWith<$Res> {
  _$ProductsModelCopyWithImpl(this._self, this._then);

  final ProductsModel _self;
  final $Res Function(ProductsModel) _then;

/// Create a copy of ProductsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(ProductsModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductsModel].
extension ProductsModelPatterns on ProductsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductsModel value)  $default,){
final _that = this;
switch (_that) {
case _ProductsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductsModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProductsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductsModel() when $default != null:
return $default(_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id)  $default,) {final _that = this;
switch (_that) {
case _ProductsModel():
return $default(_that.id);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id)?  $default,) {final _that = this;
switch (_that) {
case _ProductsModel() when $default != null:
return $default(_that.id);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductsModel implements ProductsModel {
  const _ProductsModel({required this.id});
  factory _ProductsModel.fromJson(Map<String, dynamic> json) => _$ProductsModelFromJson(json);

@override final  String id;

/// Create a copy of ProductsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductsModelCopyWith<_ProductsModel> get copyWith => __$ProductsModelCopyWithImpl<_ProductsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductsModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductsModel&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id);
}

@override
String toString() {
    return 'ProductsModel(id: $id)';
}


}

/// @nodoc
abstract mixin class _$ProductsModelCopyWith<$Res> implements $ProductsModelCopyWith<$Res> {
  factory _$ProductsModelCopyWith(_ProductsModel value, $Res Function(_ProductsModel) _then) = __$ProductsModelCopyWithImpl;
@override @useResult
$Res call({
 String id
});




}
/// @nodoc
class __$ProductsModelCopyWithImpl<$Res>
    implements _$ProductsModelCopyWith<$Res> {
  __$ProductsModelCopyWithImpl(this._self, this._then);

  final _ProductsModel _self;
  final $Res Function(_ProductsModel) _then;

/// Create a copy of ProductsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_ProductsModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
