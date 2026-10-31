// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'probe_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProbeState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProbeState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ProbeState()';
}


}

/// @nodoc
class $ProbeStateCopyWith<$Res>  {
$ProbeStateCopyWith(ProbeState _, $Res Function(ProbeState) __);
}


/// Adds pattern-matching-related methods to [ProbeState].
extension ProbeStatePatterns on ProbeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProbeInitial value)?  initial,TResult Function( ProbeLoading value)?  loading,TResult Function( ProbeSuccess value)?  success,TResult Function( ProbeFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProbeInitial() when initial != null:
return initial(_that);case ProbeLoading() when loading != null:
return loading(_that);case ProbeSuccess() when success != null:
return success(_that);case ProbeFailure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProbeInitial value)  initial,required TResult Function( ProbeLoading value)  loading,required TResult Function( ProbeSuccess value)  success,required TResult Function( ProbeFailure value)  failure,}){
final _that = this;
switch (_that) {
case ProbeInitial():
return initial(_that);case ProbeLoading():
return loading(_that);case ProbeSuccess():
return success(_that);case ProbeFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProbeInitial value)?  initial,TResult? Function( ProbeLoading value)?  loading,TResult? Function( ProbeSuccess value)?  success,TResult? Function( ProbeFailure value)?  failure,}){
final _that = this;
switch (_that) {
case ProbeInitial() when initial != null:
return initial(_that);case ProbeLoading() when loading != null:
return loading(_that);case ProbeSuccess() when success != null:
return success(_that);case ProbeFailure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( ProbeEntity entity)?  success,TResult Function( Failure failure)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProbeInitial() when initial != null:
return initial();case ProbeLoading() when loading != null:
return loading();case ProbeSuccess() when success != null:
return success(_that.entity);case ProbeFailure() when failure != null:
return failure(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( ProbeEntity entity)  success,required TResult Function( Failure failure)  failure,}) {final _that = this;
switch (_that) {
case ProbeInitial():
return initial();case ProbeLoading():
return loading();case ProbeSuccess():
return success(_that.entity);case ProbeFailure():
return failure(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( ProbeEntity entity)?  success,TResult? Function( Failure failure)?  failure,}) {final _that = this;
switch (_that) {
case ProbeInitial() when initial != null:
return initial();case ProbeLoading() when loading != null:
return loading();case ProbeSuccess() when success != null:
return success(_that.entity);case ProbeFailure() when failure != null:
return failure(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class ProbeInitial implements ProbeState {
  const ProbeInitial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProbeInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ProbeState.initial()';
}


}




/// @nodoc


class ProbeLoading implements ProbeState {
  const ProbeLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProbeLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ProbeState.loading()';
}


}




/// @nodoc


class ProbeSuccess implements ProbeState {
  const ProbeSuccess(this.entity);
  

 final  ProbeEntity entity;

/// Create a copy of ProbeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProbeSuccessCopyWith<ProbeSuccess> get copyWith => _$ProbeSuccessCopyWithImpl<ProbeSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProbeSuccess&&(identical(other.entity, entity) || other.entity == entity));
}


@override
int get hashCode {
    return Object.hash(runtimeType,entity);
}

@override
String toString() {
    return 'ProbeState.success(entity: $entity)';
}


}

/// @nodoc
abstract mixin class $ProbeSuccessCopyWith<$Res> implements $ProbeStateCopyWith<$Res> {
  factory $ProbeSuccessCopyWith(ProbeSuccess value, $Res Function(ProbeSuccess) _then) = _$ProbeSuccessCopyWithImpl;
@useResult
$Res call({
 ProbeEntity entity
});


$ProbeEntityCopyWith<$Res> get entity;

}
/// @nodoc
class _$ProbeSuccessCopyWithImpl<$Res>
    implements $ProbeSuccessCopyWith<$Res> {
  _$ProbeSuccessCopyWithImpl(this._self, this._then);

  final ProbeSuccess _self;
  final $Res Function(ProbeSuccess) _then;

/// Create a copy of ProbeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? entity = null,}) {
  return _then(ProbeSuccess(
null == entity ? _self.entity : entity // ignore: cast_nullable_to_non_nullable
as ProbeEntity,
  ));
}

/// Create a copy of ProbeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProbeEntityCopyWith<$Res> get entity {
  
  return $ProbeEntityCopyWith<$Res>(_self.entity, (value) {
    return _then(_self.copyWith(entity: value));
  });
}
}

/// @nodoc


class ProbeFailure implements ProbeState {
  const ProbeFailure(this.failure);
  

 final  Failure failure;

/// Create a copy of ProbeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProbeFailureCopyWith<ProbeFailure> get copyWith => _$ProbeFailureCopyWithImpl<ProbeFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProbeFailure&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,failure);
}

@override
String toString() {
    return 'ProbeState.failure(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $ProbeFailureCopyWith<$Res> implements $ProbeStateCopyWith<$Res> {
  factory $ProbeFailureCopyWith(ProbeFailure value, $Res Function(ProbeFailure) _then) = _$ProbeFailureCopyWithImpl;
@useResult
$Res call({
 Failure failure
});




}
/// @nodoc
class _$ProbeFailureCopyWithImpl<$Res>
    implements $ProbeFailureCopyWith<$Res> {
  _$ProbeFailureCopyWithImpl(this._self, this._then);

  final ProbeFailure _self;
  final $Res Function(ProbeFailure) _then;

/// Create a copy of ProbeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(ProbeFailure(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

// dart format on
