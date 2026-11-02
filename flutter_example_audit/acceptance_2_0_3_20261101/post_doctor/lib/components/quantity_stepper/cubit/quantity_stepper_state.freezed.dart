// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quantity_stepper_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QuantityStepperState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is QuantityStepperState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'QuantityStepperState()';
}


}

/// @nodoc
class $QuantityStepperStateCopyWith<$Res>  {
$QuantityStepperStateCopyWith(QuantityStepperState _, $Res Function(QuantityStepperState) __);
}


/// Adds pattern-matching-related methods to [QuantityStepperState].
extension QuantityStepperStatePatterns on QuantityStepperState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( QuantityStepperInitial value)?  initial,TResult Function( QuantityStepperUpdated value)?  updated,required TResult orElse(),}){
final _that = this;
switch (_that) {
case QuantityStepperInitial() when initial != null:
return initial(_that);case QuantityStepperUpdated() when updated != null:
return updated(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( QuantityStepperInitial value)  initial,required TResult Function( QuantityStepperUpdated value)  updated,}){
final _that = this;
switch (_that) {
case QuantityStepperInitial():
return initial(_that);case QuantityStepperUpdated():
return updated(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( QuantityStepperInitial value)?  initial,TResult? Function( QuantityStepperUpdated value)?  updated,}){
final _that = this;
switch (_that) {
case QuantityStepperInitial() when initial != null:
return initial(_that);case QuantityStepperUpdated() when updated != null:
return updated(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( int value)?  updated,required TResult orElse(),}) {final _that = this;
switch (_that) {
case QuantityStepperInitial() when initial != null:
return initial();case QuantityStepperUpdated() when updated != null:
return updated(_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( int value)  updated,}) {final _that = this;
switch (_that) {
case QuantityStepperInitial():
return initial();case QuantityStepperUpdated():
return updated(_that.value);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( int value)?  updated,}) {final _that = this;
switch (_that) {
case QuantityStepperInitial() when initial != null:
return initial();case QuantityStepperUpdated() when updated != null:
return updated(_that.value);case _:
  return null;

}
}

}

/// @nodoc


class QuantityStepperInitial implements QuantityStepperState {
  const QuantityStepperInitial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is QuantityStepperInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'QuantityStepperState.initial()';
}


}




/// @nodoc


class QuantityStepperUpdated implements QuantityStepperState {
  const QuantityStepperUpdated(this.value);
  

 final  int value;

/// Create a copy of QuantityStepperState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuantityStepperUpdatedCopyWith<QuantityStepperUpdated> get copyWith => _$QuantityStepperUpdatedCopyWithImpl<QuantityStepperUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is QuantityStepperUpdated&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode {
    return Object.hash(runtimeType,value);
}

@override
String toString() {
    return 'QuantityStepperState.updated(value: $value)';
}


}

/// @nodoc
abstract mixin class $QuantityStepperUpdatedCopyWith<$Res> implements $QuantityStepperStateCopyWith<$Res> {
  factory $QuantityStepperUpdatedCopyWith(QuantityStepperUpdated value, $Res Function(QuantityStepperUpdated) _then) = _$QuantityStepperUpdatedCopyWithImpl;
@useResult
$Res call({
 int value
});




}
/// @nodoc
class _$QuantityStepperUpdatedCopyWithImpl<$Res>
    implements $QuantityStepperUpdatedCopyWith<$Res> {
  _$QuantityStepperUpdatedCopyWithImpl(this._self, this._then);

  final QuantityStepperUpdated _self;
  final $Res Function(QuantityStepperUpdated) _then;

/// Create a copy of QuantityStepperState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(QuantityStepperUpdated(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
