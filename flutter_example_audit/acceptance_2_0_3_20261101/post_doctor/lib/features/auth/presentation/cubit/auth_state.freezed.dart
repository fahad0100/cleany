// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthState {

 UseCaseState<AuthEntity> get signInStatus; UseCaseState<void> get signOutStatus;
/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthStateCopyWith<AuthState> get copyWith => _$AuthStateCopyWithImpl<AuthState>(this as AuthState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AuthState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState&&(identical(other.signInStatus, _this.signInStatus) || other.signInStatus == _this.signInStatus)&&(identical(other.signOutStatus, _this.signOutStatus) || other.signOutStatus == _this.signOutStatus));
}


@override
int get hashCode {
  final _this = this as AuthState;
  return Object.hash(runtimeType,_this.signInStatus,_this.signOutStatus);
}

@override
String toString() {
  final _this = this as AuthState;
  return 'AuthState(signInStatus: ${_this.signInStatus}, signOutStatus: ${_this.signOutStatus})';
}


}

/// @nodoc
abstract mixin class $AuthStateCopyWith<$Res>  {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) _then) = _$AuthStateCopyWithImpl;
@useResult
$Res call({
 UseCaseState<AuthEntity> signInStatus, UseCaseState<void> signOutStatus
});


$UseCaseStateCopyWith<AuthEntity, $Res> get signInStatus;$UseCaseStateCopyWith<void, $Res> get signOutStatus;

}
/// @nodoc
class _$AuthStateCopyWithImpl<$Res>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._self, this._then);

  final AuthState _self;
  final $Res Function(AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? signInStatus = null,Object? signOutStatus = null,}) {
  return _then(_self.copyWith(
signInStatus: null == signInStatus ? _self.signInStatus : signInStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<AuthEntity>,signOutStatus: null == signOutStatus ? _self.signOutStatus : signOutStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<void>,
  ));
}
/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<AuthEntity, $Res> get signInStatus {
  
  return $UseCaseStateCopyWith<AuthEntity, $Res>(_self.signInStatus, (value) {
    return _then(_self.copyWith(signInStatus: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<void, $Res> get signOutStatus {
  
  return $UseCaseStateCopyWith<void, $Res>(_self.signOutStatus, (value) {
    return _then(_self.copyWith(signOutStatus: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AuthInitial value)?  initial,TResult Function( AuthLoading value)?  loading,TResult Function( AuthSuccess value)?  success,TResult Function( AuthFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AuthInitial() when initial != null:
return initial(_that);case AuthLoading() when loading != null:
return loading(_that);case AuthSuccess() when success != null:
return success(_that);case AuthFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AuthInitial value)  initial,required TResult Function( AuthLoading value)  loading,required TResult Function( AuthSuccess value)  success,required TResult Function( AuthFailure value)  failure,}){
final _that = this;
switch (_that) {
case AuthInitial():
return initial(_that);case AuthLoading():
return loading(_that);case AuthSuccess():
return success(_that);case AuthFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AuthInitial value)?  initial,TResult? Function( AuthLoading value)?  loading,TResult? Function( AuthSuccess value)?  success,TResult? Function( AuthFailure value)?  failure,}){
final _that = this;
switch (_that) {
case AuthInitial() when initial != null:
return initial(_that);case AuthLoading() when loading != null:
return loading(_that);case AuthSuccess() when success != null:
return success(_that);case AuthFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( UseCaseState<AuthEntity> signInStatus,  UseCaseState<void> signOutStatus)?  initial,TResult Function( UseCaseState<AuthEntity> signInStatus,  UseCaseState<void> signOutStatus)?  loading,TResult Function( AuthEntity entity,  UseCaseState<AuthEntity> signInStatus,  UseCaseState<void> signOutStatus)?  success,TResult Function( Failure failure,  UseCaseState<AuthEntity> signInStatus,  UseCaseState<void> signOutStatus)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AuthInitial() when initial != null:
return initial(_that.signInStatus,_that.signOutStatus);case AuthLoading() when loading != null:
return loading(_that.signInStatus,_that.signOutStatus);case AuthSuccess() when success != null:
return success(_that.entity,_that.signInStatus,_that.signOutStatus);case AuthFailure() when failure != null:
return failure(_that.failure,_that.signInStatus,_that.signOutStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( UseCaseState<AuthEntity> signInStatus,  UseCaseState<void> signOutStatus)  initial,required TResult Function( UseCaseState<AuthEntity> signInStatus,  UseCaseState<void> signOutStatus)  loading,required TResult Function( AuthEntity entity,  UseCaseState<AuthEntity> signInStatus,  UseCaseState<void> signOutStatus)  success,required TResult Function( Failure failure,  UseCaseState<AuthEntity> signInStatus,  UseCaseState<void> signOutStatus)  failure,}) {final _that = this;
switch (_that) {
case AuthInitial():
return initial(_that.signInStatus,_that.signOutStatus);case AuthLoading():
return loading(_that.signInStatus,_that.signOutStatus);case AuthSuccess():
return success(_that.entity,_that.signInStatus,_that.signOutStatus);case AuthFailure():
return failure(_that.failure,_that.signInStatus,_that.signOutStatus);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( UseCaseState<AuthEntity> signInStatus,  UseCaseState<void> signOutStatus)?  initial,TResult? Function( UseCaseState<AuthEntity> signInStatus,  UseCaseState<void> signOutStatus)?  loading,TResult? Function( AuthEntity entity,  UseCaseState<AuthEntity> signInStatus,  UseCaseState<void> signOutStatus)?  success,TResult? Function( Failure failure,  UseCaseState<AuthEntity> signInStatus,  UseCaseState<void> signOutStatus)?  failure,}) {final _that = this;
switch (_that) {
case AuthInitial() when initial != null:
return initial(_that.signInStatus,_that.signOutStatus);case AuthLoading() when loading != null:
return loading(_that.signInStatus,_that.signOutStatus);case AuthSuccess() when success != null:
return success(_that.entity,_that.signInStatus,_that.signOutStatus);case AuthFailure() when failure != null:
return failure(_that.failure,_that.signInStatus,_that.signOutStatus);case _:
  return null;

}
}

}

/// @nodoc


class AuthInitial implements AuthState {
  const AuthInitial({this.signInStatus = const UseCaseState<AuthEntity>.initial(), this.signOutStatus = const UseCaseState<void>.initial()});
  

@override@JsonKey() final  UseCaseState<AuthEntity> signInStatus;
@override@JsonKey() final  UseCaseState<void> signOutStatus;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthInitialCopyWith<AuthInitial> get copyWith => _$AuthInitialCopyWithImpl<AuthInitial>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthInitial&&(identical(other.signInStatus, signInStatus) || other.signInStatus == signInStatus)&&(identical(other.signOutStatus, signOutStatus) || other.signOutStatus == signOutStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,signInStatus,signOutStatus);
}

@override
String toString() {
    return 'AuthState.initial(signInStatus: $signInStatus, signOutStatus: $signOutStatus)';
}


}

/// @nodoc
abstract mixin class $AuthInitialCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthInitialCopyWith(AuthInitial value, $Res Function(AuthInitial) _then) = _$AuthInitialCopyWithImpl;
@override @useResult
$Res call({
 UseCaseState<AuthEntity> signInStatus, UseCaseState<void> signOutStatus
});


@override $UseCaseStateCopyWith<AuthEntity, $Res> get signInStatus;@override $UseCaseStateCopyWith<void, $Res> get signOutStatus;

}
/// @nodoc
class _$AuthInitialCopyWithImpl<$Res>
    implements $AuthInitialCopyWith<$Res> {
  _$AuthInitialCopyWithImpl(this._self, this._then);

  final AuthInitial _self;
  final $Res Function(AuthInitial) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? signInStatus = null,Object? signOutStatus = null,}) {
  return _then(AuthInitial(
signInStatus: null == signInStatus ? _self.signInStatus : signInStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<AuthEntity>,signOutStatus: null == signOutStatus ? _self.signOutStatus : signOutStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<void>,
  ));
}

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<AuthEntity, $Res> get signInStatus {
  
  return $UseCaseStateCopyWith<AuthEntity, $Res>(_self.signInStatus, (value) {
    return _then(_self.copyWith(signInStatus: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<void, $Res> get signOutStatus {
  
  return $UseCaseStateCopyWith<void, $Res>(_self.signOutStatus, (value) {
    return _then(_self.copyWith(signOutStatus: value));
  });
}
}

/// @nodoc


class AuthLoading implements AuthState {
  const AuthLoading({this.signInStatus = const UseCaseState<AuthEntity>.initial(), this.signOutStatus = const UseCaseState<void>.initial()});
  

@override@JsonKey() final  UseCaseState<AuthEntity> signInStatus;
@override@JsonKey() final  UseCaseState<void> signOutStatus;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthLoadingCopyWith<AuthLoading> get copyWith => _$AuthLoadingCopyWithImpl<AuthLoading>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthLoading&&(identical(other.signInStatus, signInStatus) || other.signInStatus == signInStatus)&&(identical(other.signOutStatus, signOutStatus) || other.signOutStatus == signOutStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,signInStatus,signOutStatus);
}

@override
String toString() {
    return 'AuthState.loading(signInStatus: $signInStatus, signOutStatus: $signOutStatus)';
}


}

/// @nodoc
abstract mixin class $AuthLoadingCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthLoadingCopyWith(AuthLoading value, $Res Function(AuthLoading) _then) = _$AuthLoadingCopyWithImpl;
@override @useResult
$Res call({
 UseCaseState<AuthEntity> signInStatus, UseCaseState<void> signOutStatus
});


@override $UseCaseStateCopyWith<AuthEntity, $Res> get signInStatus;@override $UseCaseStateCopyWith<void, $Res> get signOutStatus;

}
/// @nodoc
class _$AuthLoadingCopyWithImpl<$Res>
    implements $AuthLoadingCopyWith<$Res> {
  _$AuthLoadingCopyWithImpl(this._self, this._then);

  final AuthLoading _self;
  final $Res Function(AuthLoading) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? signInStatus = null,Object? signOutStatus = null,}) {
  return _then(AuthLoading(
signInStatus: null == signInStatus ? _self.signInStatus : signInStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<AuthEntity>,signOutStatus: null == signOutStatus ? _self.signOutStatus : signOutStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<void>,
  ));
}

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<AuthEntity, $Res> get signInStatus {
  
  return $UseCaseStateCopyWith<AuthEntity, $Res>(_self.signInStatus, (value) {
    return _then(_self.copyWith(signInStatus: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<void, $Res> get signOutStatus {
  
  return $UseCaseStateCopyWith<void, $Res>(_self.signOutStatus, (value) {
    return _then(_self.copyWith(signOutStatus: value));
  });
}
}

/// @nodoc


class AuthSuccess implements AuthState {
  const AuthSuccess(this.entity, {this.signInStatus = const UseCaseState<AuthEntity>.initial(), this.signOutStatus = const UseCaseState<void>.initial()});
  

 final  AuthEntity entity;
@override@JsonKey() final  UseCaseState<AuthEntity> signInStatus;
@override@JsonKey() final  UseCaseState<void> signOutStatus;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSuccessCopyWith<AuthSuccess> get copyWith => _$AuthSuccessCopyWithImpl<AuthSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSuccess&&(identical(other.entity, entity) || other.entity == entity)&&(identical(other.signInStatus, signInStatus) || other.signInStatus == signInStatus)&&(identical(other.signOutStatus, signOutStatus) || other.signOutStatus == signOutStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,entity,signInStatus,signOutStatus);
}

@override
String toString() {
    return 'AuthState.success(entity: $entity, signInStatus: $signInStatus, signOutStatus: $signOutStatus)';
}


}

/// @nodoc
abstract mixin class $AuthSuccessCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthSuccessCopyWith(AuthSuccess value, $Res Function(AuthSuccess) _then) = _$AuthSuccessCopyWithImpl;
@override @useResult
$Res call({
 AuthEntity entity, UseCaseState<AuthEntity> signInStatus, UseCaseState<void> signOutStatus
});


$AuthEntityCopyWith<$Res> get entity;@override $UseCaseStateCopyWith<AuthEntity, $Res> get signInStatus;@override $UseCaseStateCopyWith<void, $Res> get signOutStatus;

}
/// @nodoc
class _$AuthSuccessCopyWithImpl<$Res>
    implements $AuthSuccessCopyWith<$Res> {
  _$AuthSuccessCopyWithImpl(this._self, this._then);

  final AuthSuccess _self;
  final $Res Function(AuthSuccess) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entity = null,Object? signInStatus = null,Object? signOutStatus = null,}) {
  return _then(AuthSuccess(
null == entity ? _self.entity : entity // ignore: cast_nullable_to_non_nullable
as AuthEntity,signInStatus: null == signInStatus ? _self.signInStatus : signInStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<AuthEntity>,signOutStatus: null == signOutStatus ? _self.signOutStatus : signOutStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<void>,
  ));
}

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthEntityCopyWith<$Res> get entity {
  
  return $AuthEntityCopyWith<$Res>(_self.entity, (value) {
    return _then(_self.copyWith(entity: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<AuthEntity, $Res> get signInStatus {
  
  return $UseCaseStateCopyWith<AuthEntity, $Res>(_self.signInStatus, (value) {
    return _then(_self.copyWith(signInStatus: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<void, $Res> get signOutStatus {
  
  return $UseCaseStateCopyWith<void, $Res>(_self.signOutStatus, (value) {
    return _then(_self.copyWith(signOutStatus: value));
  });
}
}

/// @nodoc


class AuthFailure implements AuthState {
  const AuthFailure(this.failure, {this.signInStatus = const UseCaseState<AuthEntity>.initial(), this.signOutStatus = const UseCaseState<void>.initial()});
  

 final  Failure failure;
@override@JsonKey() final  UseCaseState<AuthEntity> signInStatus;
@override@JsonKey() final  UseCaseState<void> signOutStatus;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthFailureCopyWith<AuthFailure> get copyWith => _$AuthFailureCopyWithImpl<AuthFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailure&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.signInStatus, signInStatus) || other.signInStatus == signInStatus)&&(identical(other.signOutStatus, signOutStatus) || other.signOutStatus == signOutStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,failure,signInStatus,signOutStatus);
}

@override
String toString() {
    return 'AuthState.failure(failure: $failure, signInStatus: $signInStatus, signOutStatus: $signOutStatus)';
}


}

/// @nodoc
abstract mixin class $AuthFailureCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthFailureCopyWith(AuthFailure value, $Res Function(AuthFailure) _then) = _$AuthFailureCopyWithImpl;
@override @useResult
$Res call({
 Failure failure, UseCaseState<AuthEntity> signInStatus, UseCaseState<void> signOutStatus
});


@override $UseCaseStateCopyWith<AuthEntity, $Res> get signInStatus;@override $UseCaseStateCopyWith<void, $Res> get signOutStatus;

}
/// @nodoc
class _$AuthFailureCopyWithImpl<$Res>
    implements $AuthFailureCopyWith<$Res> {
  _$AuthFailureCopyWithImpl(this._self, this._then);

  final AuthFailure _self;
  final $Res Function(AuthFailure) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failure = null,Object? signInStatus = null,Object? signOutStatus = null,}) {
  return _then(AuthFailure(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,signInStatus: null == signInStatus ? _self.signInStatus : signInStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<AuthEntity>,signOutStatus: null == signOutStatus ? _self.signOutStatus : signOutStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<void>,
  ));
}

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<AuthEntity, $Res> get signInStatus {
  
  return $UseCaseStateCopyWith<AuthEntity, $Res>(_self.signInStatus, (value) {
    return _then(_self.copyWith(signInStatus: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<void, $Res> get signOutStatus {
  
  return $UseCaseStateCopyWith<void, $Res>(_self.signOutStatus, (value) {
    return _then(_self.copyWith(signOutStatus: value));
  });
}
}

// dart format on
