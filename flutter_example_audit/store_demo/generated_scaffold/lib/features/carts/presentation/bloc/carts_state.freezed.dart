// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'carts_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CartsState {

 UseCaseState<CartsEntity> get createCartStatus; UseCaseState<void> get deleteCartStatus;
/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartsStateCopyWith<CartsState> get copyWith => _$CartsStateCopyWithImpl<CartsState>(this as CartsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CartsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartsState&&(identical(other.createCartStatus, _this.createCartStatus) || other.createCartStatus == _this.createCartStatus)&&(identical(other.deleteCartStatus, _this.deleteCartStatus) || other.deleteCartStatus == _this.deleteCartStatus));
}


@override
int get hashCode {
  final _this = this as CartsState;
  return Object.hash(runtimeType,_this.createCartStatus,_this.deleteCartStatus);
}

@override
String toString() {
  final _this = this as CartsState;
  return 'CartsState(createCartStatus: ${_this.createCartStatus}, deleteCartStatus: ${_this.deleteCartStatus})';
}


}

/// @nodoc
abstract mixin class $CartsStateCopyWith<$Res>  {
  factory $CartsStateCopyWith(CartsState value, $Res Function(CartsState) _then) = _$CartsStateCopyWithImpl;
@useResult
$Res call({
 UseCaseState<CartsEntity> createCartStatus, UseCaseState<void> deleteCartStatus
});


$UseCaseStateCopyWith<CartsEntity, $Res> get createCartStatus;$UseCaseStateCopyWith<void, $Res> get deleteCartStatus;

}
/// @nodoc
class _$CartsStateCopyWithImpl<$Res>
    implements $CartsStateCopyWith<$Res> {
  _$CartsStateCopyWithImpl(this._self, this._then);

  final CartsState _self;
  final $Res Function(CartsState) _then;

/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createCartStatus = null,Object? deleteCartStatus = null,}) {
  return _then(_self.copyWith(
createCartStatus: null == createCartStatus ? _self.createCartStatus : createCartStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<CartsEntity>,deleteCartStatus: null == deleteCartStatus ? _self.deleteCartStatus : deleteCartStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<void>,
  ));
}
/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<CartsEntity, $Res> get createCartStatus {
  
  return $UseCaseStateCopyWith<CartsEntity, $Res>(_self.createCartStatus, (value) {
    return _then(_self.copyWith(createCartStatus: value));
  });
}/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<void, $Res> get deleteCartStatus {
  
  return $UseCaseStateCopyWith<void, $Res>(_self.deleteCartStatus, (value) {
    return _then(_self.copyWith(deleteCartStatus: value));
  });
}
}


/// Adds pattern-matching-related methods to [CartsState].
extension CartsStatePatterns on CartsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CartsInitial value)?  initial,TResult Function( CartsLoading value)?  loading,TResult Function( CartsSuccess value)?  success,TResult Function( CartsFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CartsInitial() when initial != null:
return initial(_that);case CartsLoading() when loading != null:
return loading(_that);case CartsSuccess() when success != null:
return success(_that);case CartsFailure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CartsInitial value)  initial,required TResult Function( CartsLoading value)  loading,required TResult Function( CartsSuccess value)  success,required TResult Function( CartsFailure value)  failure,}){
final _that = this;
switch (_that) {
case CartsInitial():
return initial(_that);case CartsLoading():
return loading(_that);case CartsSuccess():
return success(_that);case CartsFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CartsInitial value)?  initial,TResult? Function( CartsLoading value)?  loading,TResult? Function( CartsSuccess value)?  success,TResult? Function( CartsFailure value)?  failure,}){
final _that = this;
switch (_that) {
case CartsInitial() when initial != null:
return initial(_that);case CartsLoading() when loading != null:
return loading(_that);case CartsSuccess() when success != null:
return success(_that);case CartsFailure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( UseCaseState<CartsEntity> createCartStatus,  UseCaseState<void> deleteCartStatus)?  initial,TResult Function( UseCaseState<CartsEntity> createCartStatus,  UseCaseState<void> deleteCartStatus)?  loading,TResult Function( CartsEntity entity,  UseCaseState<CartsEntity> createCartStatus,  UseCaseState<void> deleteCartStatus)?  success,TResult Function( Failure failure,  UseCaseState<CartsEntity> createCartStatus,  UseCaseState<void> deleteCartStatus)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CartsInitial() when initial != null:
return initial(_that.createCartStatus,_that.deleteCartStatus);case CartsLoading() when loading != null:
return loading(_that.createCartStatus,_that.deleteCartStatus);case CartsSuccess() when success != null:
return success(_that.entity,_that.createCartStatus,_that.deleteCartStatus);case CartsFailure() when failure != null:
return failure(_that.failure,_that.createCartStatus,_that.deleteCartStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( UseCaseState<CartsEntity> createCartStatus,  UseCaseState<void> deleteCartStatus)  initial,required TResult Function( UseCaseState<CartsEntity> createCartStatus,  UseCaseState<void> deleteCartStatus)  loading,required TResult Function( CartsEntity entity,  UseCaseState<CartsEntity> createCartStatus,  UseCaseState<void> deleteCartStatus)  success,required TResult Function( Failure failure,  UseCaseState<CartsEntity> createCartStatus,  UseCaseState<void> deleteCartStatus)  failure,}) {final _that = this;
switch (_that) {
case CartsInitial():
return initial(_that.createCartStatus,_that.deleteCartStatus);case CartsLoading():
return loading(_that.createCartStatus,_that.deleteCartStatus);case CartsSuccess():
return success(_that.entity,_that.createCartStatus,_that.deleteCartStatus);case CartsFailure():
return failure(_that.failure,_that.createCartStatus,_that.deleteCartStatus);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( UseCaseState<CartsEntity> createCartStatus,  UseCaseState<void> deleteCartStatus)?  initial,TResult? Function( UseCaseState<CartsEntity> createCartStatus,  UseCaseState<void> deleteCartStatus)?  loading,TResult? Function( CartsEntity entity,  UseCaseState<CartsEntity> createCartStatus,  UseCaseState<void> deleteCartStatus)?  success,TResult? Function( Failure failure,  UseCaseState<CartsEntity> createCartStatus,  UseCaseState<void> deleteCartStatus)?  failure,}) {final _that = this;
switch (_that) {
case CartsInitial() when initial != null:
return initial(_that.createCartStatus,_that.deleteCartStatus);case CartsLoading() when loading != null:
return loading(_that.createCartStatus,_that.deleteCartStatus);case CartsSuccess() when success != null:
return success(_that.entity,_that.createCartStatus,_that.deleteCartStatus);case CartsFailure() when failure != null:
return failure(_that.failure,_that.createCartStatus,_that.deleteCartStatus);case _:
  return null;

}
}

}

/// @nodoc


class CartsInitial implements CartsState {
  const CartsInitial({this.createCartStatus = const UseCaseState<CartsEntity>.initial(), this.deleteCartStatus = const UseCaseState<void>.initial()});
  

@override@JsonKey() final  UseCaseState<CartsEntity> createCartStatus;
@override@JsonKey() final  UseCaseState<void> deleteCartStatus;

/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartsInitialCopyWith<CartsInitial> get copyWith => _$CartsInitialCopyWithImpl<CartsInitial>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CartsInitial&&(identical(other.createCartStatus, createCartStatus) || other.createCartStatus == createCartStatus)&&(identical(other.deleteCartStatus, deleteCartStatus) || other.deleteCartStatus == deleteCartStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,createCartStatus,deleteCartStatus);
}

@override
String toString() {
    return 'CartsState.initial(createCartStatus: $createCartStatus, deleteCartStatus: $deleteCartStatus)';
}


}

/// @nodoc
abstract mixin class $CartsInitialCopyWith<$Res> implements $CartsStateCopyWith<$Res> {
  factory $CartsInitialCopyWith(CartsInitial value, $Res Function(CartsInitial) _then) = _$CartsInitialCopyWithImpl;
@override @useResult
$Res call({
 UseCaseState<CartsEntity> createCartStatus, UseCaseState<void> deleteCartStatus
});


@override $UseCaseStateCopyWith<CartsEntity, $Res> get createCartStatus;@override $UseCaseStateCopyWith<void, $Res> get deleteCartStatus;

}
/// @nodoc
class _$CartsInitialCopyWithImpl<$Res>
    implements $CartsInitialCopyWith<$Res> {
  _$CartsInitialCopyWithImpl(this._self, this._then);

  final CartsInitial _self;
  final $Res Function(CartsInitial) _then;

/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createCartStatus = null,Object? deleteCartStatus = null,}) {
  return _then(CartsInitial(
createCartStatus: null == createCartStatus ? _self.createCartStatus : createCartStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<CartsEntity>,deleteCartStatus: null == deleteCartStatus ? _self.deleteCartStatus : deleteCartStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<void>,
  ));
}

/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<CartsEntity, $Res> get createCartStatus {
  
  return $UseCaseStateCopyWith<CartsEntity, $Res>(_self.createCartStatus, (value) {
    return _then(_self.copyWith(createCartStatus: value));
  });
}/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<void, $Res> get deleteCartStatus {
  
  return $UseCaseStateCopyWith<void, $Res>(_self.deleteCartStatus, (value) {
    return _then(_self.copyWith(deleteCartStatus: value));
  });
}
}

/// @nodoc


class CartsLoading implements CartsState {
  const CartsLoading({this.createCartStatus = const UseCaseState<CartsEntity>.initial(), this.deleteCartStatus = const UseCaseState<void>.initial()});
  

@override@JsonKey() final  UseCaseState<CartsEntity> createCartStatus;
@override@JsonKey() final  UseCaseState<void> deleteCartStatus;

/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartsLoadingCopyWith<CartsLoading> get copyWith => _$CartsLoadingCopyWithImpl<CartsLoading>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CartsLoading&&(identical(other.createCartStatus, createCartStatus) || other.createCartStatus == createCartStatus)&&(identical(other.deleteCartStatus, deleteCartStatus) || other.deleteCartStatus == deleteCartStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,createCartStatus,deleteCartStatus);
}

@override
String toString() {
    return 'CartsState.loading(createCartStatus: $createCartStatus, deleteCartStatus: $deleteCartStatus)';
}


}

/// @nodoc
abstract mixin class $CartsLoadingCopyWith<$Res> implements $CartsStateCopyWith<$Res> {
  factory $CartsLoadingCopyWith(CartsLoading value, $Res Function(CartsLoading) _then) = _$CartsLoadingCopyWithImpl;
@override @useResult
$Res call({
 UseCaseState<CartsEntity> createCartStatus, UseCaseState<void> deleteCartStatus
});


@override $UseCaseStateCopyWith<CartsEntity, $Res> get createCartStatus;@override $UseCaseStateCopyWith<void, $Res> get deleteCartStatus;

}
/// @nodoc
class _$CartsLoadingCopyWithImpl<$Res>
    implements $CartsLoadingCopyWith<$Res> {
  _$CartsLoadingCopyWithImpl(this._self, this._then);

  final CartsLoading _self;
  final $Res Function(CartsLoading) _then;

/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createCartStatus = null,Object? deleteCartStatus = null,}) {
  return _then(CartsLoading(
createCartStatus: null == createCartStatus ? _self.createCartStatus : createCartStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<CartsEntity>,deleteCartStatus: null == deleteCartStatus ? _self.deleteCartStatus : deleteCartStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<void>,
  ));
}

/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<CartsEntity, $Res> get createCartStatus {
  
  return $UseCaseStateCopyWith<CartsEntity, $Res>(_self.createCartStatus, (value) {
    return _then(_self.copyWith(createCartStatus: value));
  });
}/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<void, $Res> get deleteCartStatus {
  
  return $UseCaseStateCopyWith<void, $Res>(_self.deleteCartStatus, (value) {
    return _then(_self.copyWith(deleteCartStatus: value));
  });
}
}

/// @nodoc


class CartsSuccess implements CartsState {
  const CartsSuccess(this.entity, {this.createCartStatus = const UseCaseState<CartsEntity>.initial(), this.deleteCartStatus = const UseCaseState<void>.initial()});
  

 final  CartsEntity entity;
@override@JsonKey() final  UseCaseState<CartsEntity> createCartStatus;
@override@JsonKey() final  UseCaseState<void> deleteCartStatus;

/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartsSuccessCopyWith<CartsSuccess> get copyWith => _$CartsSuccessCopyWithImpl<CartsSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CartsSuccess&&(identical(other.entity, entity) || other.entity == entity)&&(identical(other.createCartStatus, createCartStatus) || other.createCartStatus == createCartStatus)&&(identical(other.deleteCartStatus, deleteCartStatus) || other.deleteCartStatus == deleteCartStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,entity,createCartStatus,deleteCartStatus);
}

@override
String toString() {
    return 'CartsState.success(entity: $entity, createCartStatus: $createCartStatus, deleteCartStatus: $deleteCartStatus)';
}


}

/// @nodoc
abstract mixin class $CartsSuccessCopyWith<$Res> implements $CartsStateCopyWith<$Res> {
  factory $CartsSuccessCopyWith(CartsSuccess value, $Res Function(CartsSuccess) _then) = _$CartsSuccessCopyWithImpl;
@override @useResult
$Res call({
 CartsEntity entity, UseCaseState<CartsEntity> createCartStatus, UseCaseState<void> deleteCartStatus
});


$CartsEntityCopyWith<$Res> get entity;@override $UseCaseStateCopyWith<CartsEntity, $Res> get createCartStatus;@override $UseCaseStateCopyWith<void, $Res> get deleteCartStatus;

}
/// @nodoc
class _$CartsSuccessCopyWithImpl<$Res>
    implements $CartsSuccessCopyWith<$Res> {
  _$CartsSuccessCopyWithImpl(this._self, this._then);

  final CartsSuccess _self;
  final $Res Function(CartsSuccess) _then;

/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entity = null,Object? createCartStatus = null,Object? deleteCartStatus = null,}) {
  return _then(CartsSuccess(
null == entity ? _self.entity : entity // ignore: cast_nullable_to_non_nullable
as CartsEntity,createCartStatus: null == createCartStatus ? _self.createCartStatus : createCartStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<CartsEntity>,deleteCartStatus: null == deleteCartStatus ? _self.deleteCartStatus : deleteCartStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<void>,
  ));
}

/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CartsEntityCopyWith<$Res> get entity {
  
  return $CartsEntityCopyWith<$Res>(_self.entity, (value) {
    return _then(_self.copyWith(entity: value));
  });
}/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<CartsEntity, $Res> get createCartStatus {
  
  return $UseCaseStateCopyWith<CartsEntity, $Res>(_self.createCartStatus, (value) {
    return _then(_self.copyWith(createCartStatus: value));
  });
}/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<void, $Res> get deleteCartStatus {
  
  return $UseCaseStateCopyWith<void, $Res>(_self.deleteCartStatus, (value) {
    return _then(_self.copyWith(deleteCartStatus: value));
  });
}
}

/// @nodoc


class CartsFailure implements CartsState {
  const CartsFailure(this.failure, {this.createCartStatus = const UseCaseState<CartsEntity>.initial(), this.deleteCartStatus = const UseCaseState<void>.initial()});
  

 final  Failure failure;
@override@JsonKey() final  UseCaseState<CartsEntity> createCartStatus;
@override@JsonKey() final  UseCaseState<void> deleteCartStatus;

/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartsFailureCopyWith<CartsFailure> get copyWith => _$CartsFailureCopyWithImpl<CartsFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CartsFailure&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.createCartStatus, createCartStatus) || other.createCartStatus == createCartStatus)&&(identical(other.deleteCartStatus, deleteCartStatus) || other.deleteCartStatus == deleteCartStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,failure,createCartStatus,deleteCartStatus);
}

@override
String toString() {
    return 'CartsState.failure(failure: $failure, createCartStatus: $createCartStatus, deleteCartStatus: $deleteCartStatus)';
}


}

/// @nodoc
abstract mixin class $CartsFailureCopyWith<$Res> implements $CartsStateCopyWith<$Res> {
  factory $CartsFailureCopyWith(CartsFailure value, $Res Function(CartsFailure) _then) = _$CartsFailureCopyWithImpl;
@override @useResult
$Res call({
 Failure failure, UseCaseState<CartsEntity> createCartStatus, UseCaseState<void> deleteCartStatus
});


@override $UseCaseStateCopyWith<CartsEntity, $Res> get createCartStatus;@override $UseCaseStateCopyWith<void, $Res> get deleteCartStatus;

}
/// @nodoc
class _$CartsFailureCopyWithImpl<$Res>
    implements $CartsFailureCopyWith<$Res> {
  _$CartsFailureCopyWithImpl(this._self, this._then);

  final CartsFailure _self;
  final $Res Function(CartsFailure) _then;

/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failure = null,Object? createCartStatus = null,Object? deleteCartStatus = null,}) {
  return _then(CartsFailure(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,createCartStatus: null == createCartStatus ? _self.createCartStatus : createCartStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<CartsEntity>,deleteCartStatus: null == deleteCartStatus ? _self.deleteCartStatus : deleteCartStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<void>,
  ));
}

/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<CartsEntity, $Res> get createCartStatus {
  
  return $UseCaseStateCopyWith<CartsEntity, $Res>(_self.createCartStatus, (value) {
    return _then(_self.copyWith(createCartStatus: value));
  });
}/// Create a copy of CartsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<void, $Res> get deleteCartStatus {
  
  return $UseCaseStateCopyWith<void, $Res>(_self.deleteCartStatus, (value) {
    return _then(_self.copyWith(deleteCartStatus: value));
  });
}
}

// dart format on
