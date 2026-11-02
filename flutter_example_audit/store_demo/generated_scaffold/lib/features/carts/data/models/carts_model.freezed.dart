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

 String get id;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartsModel&&(identical(other.id, _this.id) || other.id == _this.id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CartsModel;
  return Object.hash(runtimeType,_this.id);
}

@override
String toString() {
  final _this = this as CartsModel;
  return 'CartsModel(id: ${_this.id})';
}


}

/// @nodoc
abstract mixin class $CartsModelCopyWith<$Res>  {
  factory $CartsModelCopyWith(CartsModel value, $Res Function(CartsModel) _then) = _$CartsModelCopyWithImpl;
@useResult
$Res call({
 String id
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(CartsModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartsModel() when $default != null:
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
case _CartsModel():
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
case _CartsModel() when $default != null:
return $default(_that.id);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartsModel implements CartsModel {
  const _CartsModel({required this.id});
  factory _CartsModel.fromJson(Map<String, dynamic> json) => _$CartsModelFromJson(json);

@override final  String id;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartsModel&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id);
}

@override
String toString() {
    return 'CartsModel(id: $id)';
}


}

/// @nodoc
abstract mixin class _$CartsModelCopyWith<$Res> implements $CartsModelCopyWith<$Res> {
  factory _$CartsModelCopyWith(_CartsModel value, $Res Function(_CartsModel) _then) = __$CartsModelCopyWithImpl;
@override @useResult
$Res call({
 String id
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_CartsModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
