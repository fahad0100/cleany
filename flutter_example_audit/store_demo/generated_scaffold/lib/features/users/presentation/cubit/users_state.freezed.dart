// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'users_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UsersState {

 UseCaseState<UsersEntity> get getUserProfileStatus;
/// Create a copy of UsersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsersStateCopyWith<UsersState> get copyWith => _$UsersStateCopyWithImpl<UsersState>(this as UsersState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UsersState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UsersState&&(identical(other.getUserProfileStatus, _this.getUserProfileStatus) || other.getUserProfileStatus == _this.getUserProfileStatus));
}


@override
int get hashCode {
  final _this = this as UsersState;
  return Object.hash(runtimeType,_this.getUserProfileStatus);
}

@override
String toString() {
  final _this = this as UsersState;
  return 'UsersState(getUserProfileStatus: ${_this.getUserProfileStatus})';
}


}

/// @nodoc
abstract mixin class $UsersStateCopyWith<$Res>  {
  factory $UsersStateCopyWith(UsersState value, $Res Function(UsersState) _then) = _$UsersStateCopyWithImpl;
@useResult
$Res call({
 UseCaseState<UsersEntity> getUserProfileStatus
});


$UseCaseStateCopyWith<UsersEntity, $Res> get getUserProfileStatus;

}
/// @nodoc
class _$UsersStateCopyWithImpl<$Res>
    implements $UsersStateCopyWith<$Res> {
  _$UsersStateCopyWithImpl(this._self, this._then);

  final UsersState _self;
  final $Res Function(UsersState) _then;

/// Create a copy of UsersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? getUserProfileStatus = null,}) {
  return _then(_self.copyWith(
getUserProfileStatus: null == getUserProfileStatus ? _self.getUserProfileStatus : getUserProfileStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<UsersEntity>,
  ));
}
/// Create a copy of UsersState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<UsersEntity, $Res> get getUserProfileStatus {
  
  return $UseCaseStateCopyWith<UsersEntity, $Res>(_self.getUserProfileStatus, (value) {
    return _then(_self.copyWith(getUserProfileStatus: value));
  });
}
}


/// Adds pattern-matching-related methods to [UsersState].
extension UsersStatePatterns on UsersState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( UsersInitial value)?  initial,TResult Function( UsersLoading value)?  loading,TResult Function( UsersSuccess value)?  success,TResult Function( UsersFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case UsersInitial() when initial != null:
return initial(_that);case UsersLoading() when loading != null:
return loading(_that);case UsersSuccess() when success != null:
return success(_that);case UsersFailure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( UsersInitial value)  initial,required TResult Function( UsersLoading value)  loading,required TResult Function( UsersSuccess value)  success,required TResult Function( UsersFailure value)  failure,}){
final _that = this;
switch (_that) {
case UsersInitial():
return initial(_that);case UsersLoading():
return loading(_that);case UsersSuccess():
return success(_that);case UsersFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( UsersInitial value)?  initial,TResult? Function( UsersLoading value)?  loading,TResult? Function( UsersSuccess value)?  success,TResult? Function( UsersFailure value)?  failure,}){
final _that = this;
switch (_that) {
case UsersInitial() when initial != null:
return initial(_that);case UsersLoading() when loading != null:
return loading(_that);case UsersSuccess() when success != null:
return success(_that);case UsersFailure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( UseCaseState<UsersEntity> getUserProfileStatus)?  initial,TResult Function( UseCaseState<UsersEntity> getUserProfileStatus)?  loading,TResult Function( UsersEntity entity,  UseCaseState<UsersEntity> getUserProfileStatus)?  success,TResult Function( Failure failure,  UseCaseState<UsersEntity> getUserProfileStatus)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case UsersInitial() when initial != null:
return initial(_that.getUserProfileStatus);case UsersLoading() when loading != null:
return loading(_that.getUserProfileStatus);case UsersSuccess() when success != null:
return success(_that.entity,_that.getUserProfileStatus);case UsersFailure() when failure != null:
return failure(_that.failure,_that.getUserProfileStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( UseCaseState<UsersEntity> getUserProfileStatus)  initial,required TResult Function( UseCaseState<UsersEntity> getUserProfileStatus)  loading,required TResult Function( UsersEntity entity,  UseCaseState<UsersEntity> getUserProfileStatus)  success,required TResult Function( Failure failure,  UseCaseState<UsersEntity> getUserProfileStatus)  failure,}) {final _that = this;
switch (_that) {
case UsersInitial():
return initial(_that.getUserProfileStatus);case UsersLoading():
return loading(_that.getUserProfileStatus);case UsersSuccess():
return success(_that.entity,_that.getUserProfileStatus);case UsersFailure():
return failure(_that.failure,_that.getUserProfileStatus);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( UseCaseState<UsersEntity> getUserProfileStatus)?  initial,TResult? Function( UseCaseState<UsersEntity> getUserProfileStatus)?  loading,TResult? Function( UsersEntity entity,  UseCaseState<UsersEntity> getUserProfileStatus)?  success,TResult? Function( Failure failure,  UseCaseState<UsersEntity> getUserProfileStatus)?  failure,}) {final _that = this;
switch (_that) {
case UsersInitial() when initial != null:
return initial(_that.getUserProfileStatus);case UsersLoading() when loading != null:
return loading(_that.getUserProfileStatus);case UsersSuccess() when success != null:
return success(_that.entity,_that.getUserProfileStatus);case UsersFailure() when failure != null:
return failure(_that.failure,_that.getUserProfileStatus);case _:
  return null;

}
}

}

/// @nodoc


class UsersInitial implements UsersState {
  const UsersInitial({this.getUserProfileStatus = const UseCaseState<UsersEntity>.initial()});
  

@override@JsonKey() final  UseCaseState<UsersEntity> getUserProfileStatus;

/// Create a copy of UsersState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsersInitialCopyWith<UsersInitial> get copyWith => _$UsersInitialCopyWithImpl<UsersInitial>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UsersInitial&&(identical(other.getUserProfileStatus, getUserProfileStatus) || other.getUserProfileStatus == getUserProfileStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,getUserProfileStatus);
}

@override
String toString() {
    return 'UsersState.initial(getUserProfileStatus: $getUserProfileStatus)';
}


}

/// @nodoc
abstract mixin class $UsersInitialCopyWith<$Res> implements $UsersStateCopyWith<$Res> {
  factory $UsersInitialCopyWith(UsersInitial value, $Res Function(UsersInitial) _then) = _$UsersInitialCopyWithImpl;
@override @useResult
$Res call({
 UseCaseState<UsersEntity> getUserProfileStatus
});


@override $UseCaseStateCopyWith<UsersEntity, $Res> get getUserProfileStatus;

}
/// @nodoc
class _$UsersInitialCopyWithImpl<$Res>
    implements $UsersInitialCopyWith<$Res> {
  _$UsersInitialCopyWithImpl(this._self, this._then);

  final UsersInitial _self;
  final $Res Function(UsersInitial) _then;

/// Create a copy of UsersState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? getUserProfileStatus = null,}) {
  return _then(UsersInitial(
getUserProfileStatus: null == getUserProfileStatus ? _self.getUserProfileStatus : getUserProfileStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<UsersEntity>,
  ));
}

/// Create a copy of UsersState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<UsersEntity, $Res> get getUserProfileStatus {
  
  return $UseCaseStateCopyWith<UsersEntity, $Res>(_self.getUserProfileStatus, (value) {
    return _then(_self.copyWith(getUserProfileStatus: value));
  });
}
}

/// @nodoc


class UsersLoading implements UsersState {
  const UsersLoading({this.getUserProfileStatus = const UseCaseState<UsersEntity>.initial()});
  

@override@JsonKey() final  UseCaseState<UsersEntity> getUserProfileStatus;

/// Create a copy of UsersState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsersLoadingCopyWith<UsersLoading> get copyWith => _$UsersLoadingCopyWithImpl<UsersLoading>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UsersLoading&&(identical(other.getUserProfileStatus, getUserProfileStatus) || other.getUserProfileStatus == getUserProfileStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,getUserProfileStatus);
}

@override
String toString() {
    return 'UsersState.loading(getUserProfileStatus: $getUserProfileStatus)';
}


}

/// @nodoc
abstract mixin class $UsersLoadingCopyWith<$Res> implements $UsersStateCopyWith<$Res> {
  factory $UsersLoadingCopyWith(UsersLoading value, $Res Function(UsersLoading) _then) = _$UsersLoadingCopyWithImpl;
@override @useResult
$Res call({
 UseCaseState<UsersEntity> getUserProfileStatus
});


@override $UseCaseStateCopyWith<UsersEntity, $Res> get getUserProfileStatus;

}
/// @nodoc
class _$UsersLoadingCopyWithImpl<$Res>
    implements $UsersLoadingCopyWith<$Res> {
  _$UsersLoadingCopyWithImpl(this._self, this._then);

  final UsersLoading _self;
  final $Res Function(UsersLoading) _then;

/// Create a copy of UsersState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? getUserProfileStatus = null,}) {
  return _then(UsersLoading(
getUserProfileStatus: null == getUserProfileStatus ? _self.getUserProfileStatus : getUserProfileStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<UsersEntity>,
  ));
}

/// Create a copy of UsersState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<UsersEntity, $Res> get getUserProfileStatus {
  
  return $UseCaseStateCopyWith<UsersEntity, $Res>(_self.getUserProfileStatus, (value) {
    return _then(_self.copyWith(getUserProfileStatus: value));
  });
}
}

/// @nodoc


class UsersSuccess implements UsersState {
  const UsersSuccess(this.entity, {this.getUserProfileStatus = const UseCaseState<UsersEntity>.initial()});
  

 final  UsersEntity entity;
@override@JsonKey() final  UseCaseState<UsersEntity> getUserProfileStatus;

/// Create a copy of UsersState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsersSuccessCopyWith<UsersSuccess> get copyWith => _$UsersSuccessCopyWithImpl<UsersSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UsersSuccess&&(identical(other.entity, entity) || other.entity == entity)&&(identical(other.getUserProfileStatus, getUserProfileStatus) || other.getUserProfileStatus == getUserProfileStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,entity,getUserProfileStatus);
}

@override
String toString() {
    return 'UsersState.success(entity: $entity, getUserProfileStatus: $getUserProfileStatus)';
}


}

/// @nodoc
abstract mixin class $UsersSuccessCopyWith<$Res> implements $UsersStateCopyWith<$Res> {
  factory $UsersSuccessCopyWith(UsersSuccess value, $Res Function(UsersSuccess) _then) = _$UsersSuccessCopyWithImpl;
@override @useResult
$Res call({
 UsersEntity entity, UseCaseState<UsersEntity> getUserProfileStatus
});


$UsersEntityCopyWith<$Res> get entity;@override $UseCaseStateCopyWith<UsersEntity, $Res> get getUserProfileStatus;

}
/// @nodoc
class _$UsersSuccessCopyWithImpl<$Res>
    implements $UsersSuccessCopyWith<$Res> {
  _$UsersSuccessCopyWithImpl(this._self, this._then);

  final UsersSuccess _self;
  final $Res Function(UsersSuccess) _then;

/// Create a copy of UsersState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entity = null,Object? getUserProfileStatus = null,}) {
  return _then(UsersSuccess(
null == entity ? _self.entity : entity // ignore: cast_nullable_to_non_nullable
as UsersEntity,getUserProfileStatus: null == getUserProfileStatus ? _self.getUserProfileStatus : getUserProfileStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<UsersEntity>,
  ));
}

/// Create a copy of UsersState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsersEntityCopyWith<$Res> get entity {
  
  return $UsersEntityCopyWith<$Res>(_self.entity, (value) {
    return _then(_self.copyWith(entity: value));
  });
}/// Create a copy of UsersState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<UsersEntity, $Res> get getUserProfileStatus {
  
  return $UseCaseStateCopyWith<UsersEntity, $Res>(_self.getUserProfileStatus, (value) {
    return _then(_self.copyWith(getUserProfileStatus: value));
  });
}
}

/// @nodoc


class UsersFailure implements UsersState {
  const UsersFailure(this.failure, {this.getUserProfileStatus = const UseCaseState<UsersEntity>.initial()});
  

 final  Failure failure;
@override@JsonKey() final  UseCaseState<UsersEntity> getUserProfileStatus;

/// Create a copy of UsersState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsersFailureCopyWith<UsersFailure> get copyWith => _$UsersFailureCopyWithImpl<UsersFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UsersFailure&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.getUserProfileStatus, getUserProfileStatus) || other.getUserProfileStatus == getUserProfileStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,failure,getUserProfileStatus);
}

@override
String toString() {
    return 'UsersState.failure(failure: $failure, getUserProfileStatus: $getUserProfileStatus)';
}


}

/// @nodoc
abstract mixin class $UsersFailureCopyWith<$Res> implements $UsersStateCopyWith<$Res> {
  factory $UsersFailureCopyWith(UsersFailure value, $Res Function(UsersFailure) _then) = _$UsersFailureCopyWithImpl;
@override @useResult
$Res call({
 Failure failure, UseCaseState<UsersEntity> getUserProfileStatus
});


@override $UseCaseStateCopyWith<UsersEntity, $Res> get getUserProfileStatus;

}
/// @nodoc
class _$UsersFailureCopyWithImpl<$Res>
    implements $UsersFailureCopyWith<$Res> {
  _$UsersFailureCopyWithImpl(this._self, this._then);

  final UsersFailure _self;
  final $Res Function(UsersFailure) _then;

/// Create a copy of UsersState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failure = null,Object? getUserProfileStatus = null,}) {
  return _then(UsersFailure(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,getUserProfileStatus: null == getUserProfileStatus ? _self.getUserProfileStatus : getUserProfileStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<UsersEntity>,
  ));
}

/// Create a copy of UsersState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<UsersEntity, $Res> get getUserProfileStatus {
  
  return $UseCaseStateCopyWith<UsersEntity, $Res>(_self.getUserProfileStatus, (value) {
    return _then(_self.copyWith(getUserProfileStatus: value));
  });
}
}

// dart format on
