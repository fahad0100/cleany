// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'probe_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProbeEntity {

 String get id;
/// Create a copy of ProbeEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProbeEntityCopyWith<ProbeEntity> get copyWith => _$ProbeEntityCopyWithImpl<ProbeEntity>(this as ProbeEntity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProbeEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProbeEntity&&(identical(other.id, _this.id) || other.id == _this.id));
}


@override
int get hashCode {
  final _this = this as ProbeEntity;
  return Object.hash(runtimeType,_this.id);
}

@override
String toString() {
  final _this = this as ProbeEntity;
  return 'ProbeEntity(id: ${_this.id})';
}


}

/// @nodoc
abstract mixin class $ProbeEntityCopyWith<$Res>  {
  factory $ProbeEntityCopyWith(ProbeEntity value, $Res Function(ProbeEntity) _then) = _$ProbeEntityCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$ProbeEntityCopyWithImpl<$Res>
    implements $ProbeEntityCopyWith<$Res> {
  _$ProbeEntityCopyWithImpl(this._self, this._then);

  final ProbeEntity _self;
  final $Res Function(ProbeEntity) _then;

/// Create a copy of ProbeEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(ProbeEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProbeEntity].
extension ProbeEntityPatterns on ProbeEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProbeEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProbeEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProbeEntity value)  $default,){
final _that = this;
switch (_that) {
case _ProbeEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProbeEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ProbeEntity() when $default != null:
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
case _ProbeEntity() when $default != null:
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
case _ProbeEntity():
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
case _ProbeEntity() when $default != null:
return $default(_that.id);case _:
  return null;

}
}

}

/// @nodoc


class _ProbeEntity implements ProbeEntity {
  const _ProbeEntity({required this.id});
  

@override final  String id;

/// Create a copy of ProbeEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProbeEntityCopyWith<_ProbeEntity> get copyWith => __$ProbeEntityCopyWithImpl<_ProbeEntity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProbeEntity&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id);
}

@override
String toString() {
    return 'ProbeEntity(id: $id)';
}


}

/// @nodoc
abstract mixin class _$ProbeEntityCopyWith<$Res> implements $ProbeEntityCopyWith<$Res> {
  factory _$ProbeEntityCopyWith(_ProbeEntity value, $Res Function(_ProbeEntity) _then) = __$ProbeEntityCopyWithImpl;
@override @useResult
$Res call({
 String id
});




}
/// @nodoc
class __$ProbeEntityCopyWithImpl<$Res>
    implements _$ProbeEntityCopyWith<$Res> {
  __$ProbeEntityCopyWithImpl(this._self, this._then);

  final _ProbeEntity _self;
  final $Res Function(_ProbeEntity) _then;

/// Create a copy of ProbeEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_ProbeEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
