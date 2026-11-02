// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthEntity {

 String get token; String get username; int get userId;
/// Create a copy of AuthEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthEntityCopyWith<AuthEntity> get copyWith => _$AuthEntityCopyWithImpl<AuthEntity>(this as AuthEntity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AuthEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthEntity&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.userId, _this.userId) || other.userId == _this.userId));
}


@override
int get hashCode {
  final _this = this as AuthEntity;
  return Object.hash(runtimeType,_this.token,_this.username,_this.userId);
}



}

/// @nodoc
abstract mixin class $AuthEntityCopyWith<$Res>  {
  factory $AuthEntityCopyWith(AuthEntity value, $Res Function(AuthEntity) _then) = _$AuthEntityCopyWithImpl;
@useResult
$Res call({
 String token, String username, int userId
});




}
/// @nodoc
class _$AuthEntityCopyWithImpl<$Res>
    implements $AuthEntityCopyWith<$Res> {
  _$AuthEntityCopyWithImpl(this._self, this._then);

  final AuthEntity _self;
  final $Res Function(AuthEntity) _then;

/// Create a copy of AuthEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? username = null,Object? userId = null,}) {
  return _then(AuthEntity(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthEntity].
extension AuthEntityPatterns on AuthEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthEntity value)  $default,){
final _that = this;
switch (_that) {
case _AuthEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AuthEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  String username,  int userId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthEntity() when $default != null:
return $default(_that.token,_that.username,_that.userId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  String username,  int userId)  $default,) {final _that = this;
switch (_that) {
case _AuthEntity():
return $default(_that.token,_that.username,_that.userId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  String username,  int userId)?  $default,) {final _that = this;
switch (_that) {
case _AuthEntity() when $default != null:
return $default(_that.token,_that.username,_that.userId);case _:
  return null;

}
}

}

/// @nodoc


class _AuthEntity extends AuthEntity {
  const _AuthEntity({required this.token, required this.username, required this.userId}): super._();
  

@override final  String token;
@override final  String username;
@override final  int userId;

/// Create a copy of AuthEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthEntityCopyWith<_AuthEntity> get copyWith => __$AuthEntityCopyWithImpl<_AuthEntity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthEntity&&(identical(other.token, token) || other.token == token)&&(identical(other.username, username) || other.username == username)&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,token,username,userId);
}



}

/// @nodoc
abstract mixin class _$AuthEntityCopyWith<$Res> implements $AuthEntityCopyWith<$Res> {
  factory _$AuthEntityCopyWith(_AuthEntity value, $Res Function(_AuthEntity) _then) = __$AuthEntityCopyWithImpl;
@override @useResult
$Res call({
 String token, String username, int userId
});




}
/// @nodoc
class __$AuthEntityCopyWithImpl<$Res>
    implements _$AuthEntityCopyWith<$Res> {
  __$AuthEntityCopyWithImpl(this._self, this._then);

  final _AuthEntity _self;
  final $Res Function(_AuthEntity) _then;

/// Create a copy of AuthEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? username = null,Object? userId = null,}) {
  return _then(_AuthEntity(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
