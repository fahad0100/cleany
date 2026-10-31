// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'probe_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProbeModel {

 String get id;
/// Create a copy of ProbeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProbeModelCopyWith<ProbeModel> get copyWith => _$ProbeModelCopyWithImpl<ProbeModel>(this as ProbeModel, _$identity);

  /// Serializes this ProbeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProbeModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProbeModel&&(identical(other.id, _this.id) || other.id == _this.id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProbeModel;
  return Object.hash(runtimeType,_this.id);
}

@override
String toString() {
  final _this = this as ProbeModel;
  return 'ProbeModel(id: ${_this.id})';
}


}

/// @nodoc
abstract mixin class $ProbeModelCopyWith<$Res>  {
  factory $ProbeModelCopyWith(ProbeModel value, $Res Function(ProbeModel) _then) = _$ProbeModelCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$ProbeModelCopyWithImpl<$Res>
    implements $ProbeModelCopyWith<$Res> {
  _$ProbeModelCopyWithImpl(this._self, this._then);

  final ProbeModel _self;
  final $Res Function(ProbeModel) _then;

/// Create a copy of ProbeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(ProbeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProbeModel].
extension ProbeModelPatterns on ProbeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProbeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProbeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProbeModel value)  $default,){
final _that = this;
switch (_that) {
case _ProbeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProbeModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProbeModel() when $default != null:
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
case _ProbeModel() when $default != null:
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
case _ProbeModel():
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
case _ProbeModel() when $default != null:
return $default(_that.id);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProbeModel implements ProbeModel {
  const _ProbeModel({required this.id});
  factory _ProbeModel.fromJson(Map<String, dynamic> json) => _$ProbeModelFromJson(json);

@override final  String id;

/// Create a copy of ProbeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProbeModelCopyWith<_ProbeModel> get copyWith => __$ProbeModelCopyWithImpl<_ProbeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProbeModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProbeModel&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id);
}

@override
String toString() {
    return 'ProbeModel(id: $id)';
}


}

/// @nodoc
abstract mixin class _$ProbeModelCopyWith<$Res> implements $ProbeModelCopyWith<$Res> {
  factory _$ProbeModelCopyWith(_ProbeModel value, $Res Function(_ProbeModel) _then) = __$ProbeModelCopyWithImpl;
@override @useResult
$Res call({
 String id
});




}
/// @nodoc
class __$ProbeModelCopyWithImpl<$Res>
    implements _$ProbeModelCopyWith<$Res> {
  __$ProbeModelCopyWithImpl(this._self, this._then);

  final _ProbeModel _self;
  final $Res Function(_ProbeModel) _then;

/// Create a copy of ProbeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_ProbeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
