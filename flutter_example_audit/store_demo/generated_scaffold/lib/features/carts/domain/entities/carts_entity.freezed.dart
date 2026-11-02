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

 String get id;
/// Create a copy of CartsEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartsEntityCopyWith<CartsEntity> get copyWith => _$CartsEntityCopyWithImpl<CartsEntity>(this as CartsEntity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CartsEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartsEntity&&(identical(other.id, _this.id) || other.id == _this.id));
}


@override
int get hashCode {
  final _this = this as CartsEntity;
  return Object.hash(runtimeType,_this.id);
}

@override
String toString() {
  final _this = this as CartsEntity;
  return 'CartsEntity(id: ${_this.id})';
}


}

/// @nodoc
abstract mixin class $CartsEntityCopyWith<$Res>  {
  factory $CartsEntityCopyWith(CartsEntity value, $Res Function(CartsEntity) _then) = _$CartsEntityCopyWithImpl;
@useResult
$Res call({
 String id
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(CartsEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartsEntity() when $default != null:
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
case _CartsEntity():
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
case _CartsEntity() when $default != null:
return $default(_that.id);case _:
  return null;

}
}

}

/// @nodoc


class _CartsEntity implements CartsEntity {
  const _CartsEntity({required this.id});
  

@override final  String id;

/// Create a copy of CartsEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartsEntityCopyWith<_CartsEntity> get copyWith => __$CartsEntityCopyWithImpl<_CartsEntity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartsEntity&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id);
}

@override
String toString() {
    return 'CartsEntity(id: $id)';
}


}

/// @nodoc
abstract mixin class _$CartsEntityCopyWith<$Res> implements $CartsEntityCopyWith<$Res> {
  factory _$CartsEntityCopyWith(_CartsEntity value, $Res Function(_CartsEntity) _then) = __$CartsEntityCopyWithImpl;
@override @useResult
$Res call({
 String id
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_CartsEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
