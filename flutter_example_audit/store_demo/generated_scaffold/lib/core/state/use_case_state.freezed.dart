// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'use_case_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UseCaseState<T> {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UseCaseState<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'UseCaseState<$T>()';
}


}

/// @nodoc
class $UseCaseStateCopyWith<T,$Res>  {
$UseCaseStateCopyWith(UseCaseState<T> _, $Res Function(UseCaseState<T>) __);
}


/// Adds pattern-matching-related methods to [UseCaseState].
extension UseCaseStatePatterns<T> on UseCaseState<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( UseCaseInitial<T> value)?  initial,TResult Function( UseCaseLoading<T> value)?  loading,TResult Function( UseCaseSuccess<T> value)?  success,TResult Function( UseCaseFailure<T> value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case UseCaseInitial() when initial != null:
return initial(_that);case UseCaseLoading() when loading != null:
return loading(_that);case UseCaseSuccess() when success != null:
return success(_that);case UseCaseFailure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( UseCaseInitial<T> value)  initial,required TResult Function( UseCaseLoading<T> value)  loading,required TResult Function( UseCaseSuccess<T> value)  success,required TResult Function( UseCaseFailure<T> value)  failure,}){
final _that = this;
switch (_that) {
case UseCaseInitial():
return initial(_that);case UseCaseLoading():
return loading(_that);case UseCaseSuccess():
return success(_that);case UseCaseFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( UseCaseInitial<T> value)?  initial,TResult? Function( UseCaseLoading<T> value)?  loading,TResult? Function( UseCaseSuccess<T> value)?  success,TResult? Function( UseCaseFailure<T> value)?  failure,}){
final _that = this;
switch (_that) {
case UseCaseInitial() when initial != null:
return initial(_that);case UseCaseLoading() when loading != null:
return loading(_that);case UseCaseSuccess() when success != null:
return success(_that);case UseCaseFailure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( T value)?  success,TResult Function( Failure failure)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case UseCaseInitial() when initial != null:
return initial();case UseCaseLoading() when loading != null:
return loading();case UseCaseSuccess() when success != null:
return success(_that.value);case UseCaseFailure() when failure != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( T value)  success,required TResult Function( Failure failure)  failure,}) {final _that = this;
switch (_that) {
case UseCaseInitial():
return initial();case UseCaseLoading():
return loading();case UseCaseSuccess():
return success(_that.value);case UseCaseFailure():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( T value)?  success,TResult? Function( Failure failure)?  failure,}) {final _that = this;
switch (_that) {
case UseCaseInitial() when initial != null:
return initial();case UseCaseLoading() when loading != null:
return loading();case UseCaseSuccess() when success != null:
return success(_that.value);case UseCaseFailure() when failure != null:
return failure(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class UseCaseInitial<T> implements UseCaseState<T> {
  const UseCaseInitial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UseCaseInitial<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'UseCaseState<$T>.initial()';
}


}




/// @nodoc


class UseCaseLoading<T> implements UseCaseState<T> {
  const UseCaseLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UseCaseLoading<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'UseCaseState<$T>.loading()';
}


}




/// @nodoc


class UseCaseSuccess<T> implements UseCaseState<T> {
  const UseCaseSuccess(this.value);
  

 final  T value;

/// Create a copy of UseCaseState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UseCaseSuccessCopyWith<T, UseCaseSuccess<T>> get copyWith => _$UseCaseSuccessCopyWithImpl<T, UseCaseSuccess<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UseCaseSuccess<T>&&const DeepCollectionEquality().equals(other.value, value));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(value));
}

@override
String toString() {
    return 'UseCaseState<$T>.success(value: $value)';
}


}

/// @nodoc
abstract mixin class $UseCaseSuccessCopyWith<T,$Res> implements $UseCaseStateCopyWith<T, $Res> {
  factory $UseCaseSuccessCopyWith(UseCaseSuccess<T> value, $Res Function(UseCaseSuccess<T>) _then) = _$UseCaseSuccessCopyWithImpl;
@useResult
$Res call({
 T value
});




}
/// @nodoc
class _$UseCaseSuccessCopyWithImpl<T,$Res>
    implements $UseCaseSuccessCopyWith<T, $Res> {
  _$UseCaseSuccessCopyWithImpl(this._self, this._then);

  final UseCaseSuccess<T> _self;
  final $Res Function(UseCaseSuccess<T>) _then;

/// Create a copy of UseCaseState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = freezed,}) {
  return _then(UseCaseSuccess<T>(
freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class UseCaseFailure<T> implements UseCaseState<T> {
  const UseCaseFailure(this.failure);
  

 final  Failure failure;

/// Create a copy of UseCaseState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UseCaseFailureCopyWith<T, UseCaseFailure<T>> get copyWith => _$UseCaseFailureCopyWithImpl<T, UseCaseFailure<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UseCaseFailure<T>&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,failure);
}

@override
String toString() {
    return 'UseCaseState<$T>.failure(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $UseCaseFailureCopyWith<T,$Res> implements $UseCaseStateCopyWith<T, $Res> {
  factory $UseCaseFailureCopyWith(UseCaseFailure<T> value, $Res Function(UseCaseFailure<T>) _then) = _$UseCaseFailureCopyWithImpl;
@useResult
$Res call({
 Failure failure
});




}
/// @nodoc
class _$UseCaseFailureCopyWithImpl<T,$Res>
    implements $UseCaseFailureCopyWith<T, $Res> {
  _$UseCaseFailureCopyWithImpl(this._self, this._then);

  final UseCaseFailure<T> _self;
  final $Res Function(UseCaseFailure<T>) _then;

/// Create a copy of UseCaseState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(UseCaseFailure<T>(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

// dart format on
