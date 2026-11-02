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

 String get id;
/// Create a copy of ProductsEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsEntityCopyWith<ProductsEntity> get copyWith => _$ProductsEntityCopyWithImpl<ProductsEntity>(this as ProductsEntity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProductsEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsEntity&&(identical(other.id, _this.id) || other.id == _this.id));
}


@override
int get hashCode {
  final _this = this as ProductsEntity;
  return Object.hash(runtimeType,_this.id);
}

@override
String toString() {
  final _this = this as ProductsEntity;
  return 'ProductsEntity(id: ${_this.id})';
}


}

/// @nodoc
abstract mixin class $ProductsEntityCopyWith<$Res>  {
  factory $ProductsEntityCopyWith(ProductsEntity value, $Res Function(ProductsEntity) _then) = _$ProductsEntityCopyWithImpl;
@useResult
$Res call({
 String id
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(ProductsEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductsEntity() when $default != null:
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
case _ProductsEntity():
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
case _ProductsEntity() when $default != null:
return $default(_that.id);case _:
  return null;

}
}

}

/// @nodoc


class _ProductsEntity implements ProductsEntity {
  const _ProductsEntity({required this.id});
  

@override final  String id;

/// Create a copy of ProductsEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductsEntityCopyWith<_ProductsEntity> get copyWith => __$ProductsEntityCopyWithImpl<_ProductsEntity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductsEntity&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id);
}

@override
String toString() {
    return 'ProductsEntity(id: $id)';
}


}

/// @nodoc
abstract mixin class _$ProductsEntityCopyWith<$Res> implements $ProductsEntityCopyWith<$Res> {
  factory _$ProductsEntityCopyWith(_ProductsEntity value, $Res Function(_ProductsEntity) _then) = __$ProductsEntityCopyWithImpl;
@override @useResult
$Res call({
 String id
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_ProductsEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
