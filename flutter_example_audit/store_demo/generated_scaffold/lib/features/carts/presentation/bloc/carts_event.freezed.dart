// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'carts_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CartsEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CartsEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CartsEvent()';
}


}

/// @nodoc
class $CartsEventCopyWith<$Res>  {
$CartsEventCopyWith(CartsEvent _, $Res Function(CartsEvent) __);
}


/// Adds pattern-matching-related methods to [CartsEvent].
extension CartsEventPatterns on CartsEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CartsRequested value)?  requested,TResult Function( CartsCreateCartRequested value)?  createCartRequested,TResult Function( CartsDeleteCartRequested value)?  deleteCartRequested,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CartsRequested() when requested != null:
return requested(_that);case CartsCreateCartRequested() when createCartRequested != null:
return createCartRequested(_that);case CartsDeleteCartRequested() when deleteCartRequested != null:
return deleteCartRequested(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CartsRequested value)  requested,required TResult Function( CartsCreateCartRequested value)  createCartRequested,required TResult Function( CartsDeleteCartRequested value)  deleteCartRequested,}){
final _that = this;
switch (_that) {
case CartsRequested():
return requested(_that);case CartsCreateCartRequested():
return createCartRequested(_that);case CartsDeleteCartRequested():
return deleteCartRequested(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CartsRequested value)?  requested,TResult? Function( CartsCreateCartRequested value)?  createCartRequested,TResult? Function( CartsDeleteCartRequested value)?  deleteCartRequested,}){
final _that = this;
switch (_that) {
case CartsRequested() when requested != null:
return requested(_that);case CartsCreateCartRequested() when createCartRequested != null:
return createCartRequested(_that);case CartsDeleteCartRequested() when deleteCartRequested != null:
return deleteCartRequested(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  requested,TResult Function()?  createCartRequested,TResult Function()?  deleteCartRequested,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CartsRequested() when requested != null:
return requested();case CartsCreateCartRequested() when createCartRequested != null:
return createCartRequested();case CartsDeleteCartRequested() when deleteCartRequested != null:
return deleteCartRequested();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  requested,required TResult Function()  createCartRequested,required TResult Function()  deleteCartRequested,}) {final _that = this;
switch (_that) {
case CartsRequested():
return requested();case CartsCreateCartRequested():
return createCartRequested();case CartsDeleteCartRequested():
return deleteCartRequested();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  requested,TResult? Function()?  createCartRequested,TResult? Function()?  deleteCartRequested,}) {final _that = this;
switch (_that) {
case CartsRequested() when requested != null:
return requested();case CartsCreateCartRequested() when createCartRequested != null:
return createCartRequested();case CartsDeleteCartRequested() when deleteCartRequested != null:
return deleteCartRequested();case _:
  return null;

}
}

}

/// @nodoc


class CartsRequested implements CartsEvent {
  const CartsRequested();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CartsRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CartsEvent.requested()';
}


}




/// @nodoc


class CartsCreateCartRequested implements CartsEvent {
  const CartsCreateCartRequested();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CartsCreateCartRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CartsEvent.createCartRequested()';
}


}




/// @nodoc


class CartsDeleteCartRequested implements CartsEvent {
  const CartsDeleteCartRequested();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CartsDeleteCartRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CartsEvent.deleteCartRequested()';
}


}




// dart format on
