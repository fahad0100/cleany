// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'products_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductsState {

 UseCaseState<ProductsEntity> get getFeaturedProductStatus;
/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsStateCopyWith<ProductsState> get copyWith => _$ProductsStateCopyWithImpl<ProductsState>(this as ProductsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProductsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsState&&(identical(other.getFeaturedProductStatus, _this.getFeaturedProductStatus) || other.getFeaturedProductStatus == _this.getFeaturedProductStatus));
}


@override
int get hashCode {
  final _this = this as ProductsState;
  return Object.hash(runtimeType,_this.getFeaturedProductStatus);
}

@override
String toString() {
  final _this = this as ProductsState;
  return 'ProductsState(getFeaturedProductStatus: ${_this.getFeaturedProductStatus})';
}


}

/// @nodoc
abstract mixin class $ProductsStateCopyWith<$Res>  {
  factory $ProductsStateCopyWith(ProductsState value, $Res Function(ProductsState) _then) = _$ProductsStateCopyWithImpl;
@useResult
$Res call({
 UseCaseState<ProductsEntity> getFeaturedProductStatus
});


$UseCaseStateCopyWith<ProductsEntity, $Res> get getFeaturedProductStatus;

}
/// @nodoc
class _$ProductsStateCopyWithImpl<$Res>
    implements $ProductsStateCopyWith<$Res> {
  _$ProductsStateCopyWithImpl(this._self, this._then);

  final ProductsState _self;
  final $Res Function(ProductsState) _then;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? getFeaturedProductStatus = null,}) {
  return _then(_self.copyWith(
getFeaturedProductStatus: null == getFeaturedProductStatus ? _self.getFeaturedProductStatus : getFeaturedProductStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<ProductsEntity>,
  ));
}
/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<ProductsEntity, $Res> get getFeaturedProductStatus {
  
  return $UseCaseStateCopyWith<ProductsEntity, $Res>(_self.getFeaturedProductStatus, (value) {
    return _then(_self.copyWith(getFeaturedProductStatus: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProductsState].
extension ProductsStatePatterns on ProductsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProductsInitial value)?  initial,TResult Function( ProductsLoading value)?  loading,TResult Function( ProductsSuccess value)?  success,TResult Function( ProductsFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProductsInitial() when initial != null:
return initial(_that);case ProductsLoading() when loading != null:
return loading(_that);case ProductsSuccess() when success != null:
return success(_that);case ProductsFailure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProductsInitial value)  initial,required TResult Function( ProductsLoading value)  loading,required TResult Function( ProductsSuccess value)  success,required TResult Function( ProductsFailure value)  failure,}){
final _that = this;
switch (_that) {
case ProductsInitial():
return initial(_that);case ProductsLoading():
return loading(_that);case ProductsSuccess():
return success(_that);case ProductsFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProductsInitial value)?  initial,TResult? Function( ProductsLoading value)?  loading,TResult? Function( ProductsSuccess value)?  success,TResult? Function( ProductsFailure value)?  failure,}){
final _that = this;
switch (_that) {
case ProductsInitial() when initial != null:
return initial(_that);case ProductsLoading() when loading != null:
return loading(_that);case ProductsSuccess() when success != null:
return success(_that);case ProductsFailure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( UseCaseState<ProductsEntity> getFeaturedProductStatus)?  initial,TResult Function( UseCaseState<ProductsEntity> getFeaturedProductStatus)?  loading,TResult Function( ProductsEntity entity,  UseCaseState<ProductsEntity> getFeaturedProductStatus)?  success,TResult Function( Failure failure,  UseCaseState<ProductsEntity> getFeaturedProductStatus)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProductsInitial() when initial != null:
return initial(_that.getFeaturedProductStatus);case ProductsLoading() when loading != null:
return loading(_that.getFeaturedProductStatus);case ProductsSuccess() when success != null:
return success(_that.entity,_that.getFeaturedProductStatus);case ProductsFailure() when failure != null:
return failure(_that.failure,_that.getFeaturedProductStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( UseCaseState<ProductsEntity> getFeaturedProductStatus)  initial,required TResult Function( UseCaseState<ProductsEntity> getFeaturedProductStatus)  loading,required TResult Function( ProductsEntity entity,  UseCaseState<ProductsEntity> getFeaturedProductStatus)  success,required TResult Function( Failure failure,  UseCaseState<ProductsEntity> getFeaturedProductStatus)  failure,}) {final _that = this;
switch (_that) {
case ProductsInitial():
return initial(_that.getFeaturedProductStatus);case ProductsLoading():
return loading(_that.getFeaturedProductStatus);case ProductsSuccess():
return success(_that.entity,_that.getFeaturedProductStatus);case ProductsFailure():
return failure(_that.failure,_that.getFeaturedProductStatus);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( UseCaseState<ProductsEntity> getFeaturedProductStatus)?  initial,TResult? Function( UseCaseState<ProductsEntity> getFeaturedProductStatus)?  loading,TResult? Function( ProductsEntity entity,  UseCaseState<ProductsEntity> getFeaturedProductStatus)?  success,TResult? Function( Failure failure,  UseCaseState<ProductsEntity> getFeaturedProductStatus)?  failure,}) {final _that = this;
switch (_that) {
case ProductsInitial() when initial != null:
return initial(_that.getFeaturedProductStatus);case ProductsLoading() when loading != null:
return loading(_that.getFeaturedProductStatus);case ProductsSuccess() when success != null:
return success(_that.entity,_that.getFeaturedProductStatus);case ProductsFailure() when failure != null:
return failure(_that.failure,_that.getFeaturedProductStatus);case _:
  return null;

}
}

}

/// @nodoc


class ProductsInitial implements ProductsState {
  const ProductsInitial({this.getFeaturedProductStatus = const UseCaseState<ProductsEntity>.initial()});
  

@override@JsonKey() final  UseCaseState<ProductsEntity> getFeaturedProductStatus;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsInitialCopyWith<ProductsInitial> get copyWith => _$ProductsInitialCopyWithImpl<ProductsInitial>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsInitial&&(identical(other.getFeaturedProductStatus, getFeaturedProductStatus) || other.getFeaturedProductStatus == getFeaturedProductStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,getFeaturedProductStatus);
}

@override
String toString() {
    return 'ProductsState.initial(getFeaturedProductStatus: $getFeaturedProductStatus)';
}


}

/// @nodoc
abstract mixin class $ProductsInitialCopyWith<$Res> implements $ProductsStateCopyWith<$Res> {
  factory $ProductsInitialCopyWith(ProductsInitial value, $Res Function(ProductsInitial) _then) = _$ProductsInitialCopyWithImpl;
@override @useResult
$Res call({
 UseCaseState<ProductsEntity> getFeaturedProductStatus
});


@override $UseCaseStateCopyWith<ProductsEntity, $Res> get getFeaturedProductStatus;

}
/// @nodoc
class _$ProductsInitialCopyWithImpl<$Res>
    implements $ProductsInitialCopyWith<$Res> {
  _$ProductsInitialCopyWithImpl(this._self, this._then);

  final ProductsInitial _self;
  final $Res Function(ProductsInitial) _then;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? getFeaturedProductStatus = null,}) {
  return _then(ProductsInitial(
getFeaturedProductStatus: null == getFeaturedProductStatus ? _self.getFeaturedProductStatus : getFeaturedProductStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<ProductsEntity>,
  ));
}

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<ProductsEntity, $Res> get getFeaturedProductStatus {
  
  return $UseCaseStateCopyWith<ProductsEntity, $Res>(_self.getFeaturedProductStatus, (value) {
    return _then(_self.copyWith(getFeaturedProductStatus: value));
  });
}
}

/// @nodoc


class ProductsLoading implements ProductsState {
  const ProductsLoading({this.getFeaturedProductStatus = const UseCaseState<ProductsEntity>.initial()});
  

@override@JsonKey() final  UseCaseState<ProductsEntity> getFeaturedProductStatus;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsLoadingCopyWith<ProductsLoading> get copyWith => _$ProductsLoadingCopyWithImpl<ProductsLoading>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsLoading&&(identical(other.getFeaturedProductStatus, getFeaturedProductStatus) || other.getFeaturedProductStatus == getFeaturedProductStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,getFeaturedProductStatus);
}

@override
String toString() {
    return 'ProductsState.loading(getFeaturedProductStatus: $getFeaturedProductStatus)';
}


}

/// @nodoc
abstract mixin class $ProductsLoadingCopyWith<$Res> implements $ProductsStateCopyWith<$Res> {
  factory $ProductsLoadingCopyWith(ProductsLoading value, $Res Function(ProductsLoading) _then) = _$ProductsLoadingCopyWithImpl;
@override @useResult
$Res call({
 UseCaseState<ProductsEntity> getFeaturedProductStatus
});


@override $UseCaseStateCopyWith<ProductsEntity, $Res> get getFeaturedProductStatus;

}
/// @nodoc
class _$ProductsLoadingCopyWithImpl<$Res>
    implements $ProductsLoadingCopyWith<$Res> {
  _$ProductsLoadingCopyWithImpl(this._self, this._then);

  final ProductsLoading _self;
  final $Res Function(ProductsLoading) _then;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? getFeaturedProductStatus = null,}) {
  return _then(ProductsLoading(
getFeaturedProductStatus: null == getFeaturedProductStatus ? _self.getFeaturedProductStatus : getFeaturedProductStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<ProductsEntity>,
  ));
}

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<ProductsEntity, $Res> get getFeaturedProductStatus {
  
  return $UseCaseStateCopyWith<ProductsEntity, $Res>(_self.getFeaturedProductStatus, (value) {
    return _then(_self.copyWith(getFeaturedProductStatus: value));
  });
}
}

/// @nodoc


class ProductsSuccess implements ProductsState {
  const ProductsSuccess(this.entity, {this.getFeaturedProductStatus = const UseCaseState<ProductsEntity>.initial()});
  

 final  ProductsEntity entity;
@override@JsonKey() final  UseCaseState<ProductsEntity> getFeaturedProductStatus;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsSuccessCopyWith<ProductsSuccess> get copyWith => _$ProductsSuccessCopyWithImpl<ProductsSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsSuccess&&(identical(other.entity, entity) || other.entity == entity)&&(identical(other.getFeaturedProductStatus, getFeaturedProductStatus) || other.getFeaturedProductStatus == getFeaturedProductStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,entity,getFeaturedProductStatus);
}

@override
String toString() {
    return 'ProductsState.success(entity: $entity, getFeaturedProductStatus: $getFeaturedProductStatus)';
}


}

/// @nodoc
abstract mixin class $ProductsSuccessCopyWith<$Res> implements $ProductsStateCopyWith<$Res> {
  factory $ProductsSuccessCopyWith(ProductsSuccess value, $Res Function(ProductsSuccess) _then) = _$ProductsSuccessCopyWithImpl;
@override @useResult
$Res call({
 ProductsEntity entity, UseCaseState<ProductsEntity> getFeaturedProductStatus
});


$ProductsEntityCopyWith<$Res> get entity;@override $UseCaseStateCopyWith<ProductsEntity, $Res> get getFeaturedProductStatus;

}
/// @nodoc
class _$ProductsSuccessCopyWithImpl<$Res>
    implements $ProductsSuccessCopyWith<$Res> {
  _$ProductsSuccessCopyWithImpl(this._self, this._then);

  final ProductsSuccess _self;
  final $Res Function(ProductsSuccess) _then;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entity = null,Object? getFeaturedProductStatus = null,}) {
  return _then(ProductsSuccess(
null == entity ? _self.entity : entity // ignore: cast_nullable_to_non_nullable
as ProductsEntity,getFeaturedProductStatus: null == getFeaturedProductStatus ? _self.getFeaturedProductStatus : getFeaturedProductStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<ProductsEntity>,
  ));
}

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductsEntityCopyWith<$Res> get entity {
  
  return $ProductsEntityCopyWith<$Res>(_self.entity, (value) {
    return _then(_self.copyWith(entity: value));
  });
}/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<ProductsEntity, $Res> get getFeaturedProductStatus {
  
  return $UseCaseStateCopyWith<ProductsEntity, $Res>(_self.getFeaturedProductStatus, (value) {
    return _then(_self.copyWith(getFeaturedProductStatus: value));
  });
}
}

/// @nodoc


class ProductsFailure implements ProductsState {
  const ProductsFailure(this.failure, {this.getFeaturedProductStatus = const UseCaseState<ProductsEntity>.initial()});
  

 final  Failure failure;
@override@JsonKey() final  UseCaseState<ProductsEntity> getFeaturedProductStatus;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsFailureCopyWith<ProductsFailure> get copyWith => _$ProductsFailureCopyWithImpl<ProductsFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsFailure&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.getFeaturedProductStatus, getFeaturedProductStatus) || other.getFeaturedProductStatus == getFeaturedProductStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,failure,getFeaturedProductStatus);
}

@override
String toString() {
    return 'ProductsState.failure(failure: $failure, getFeaturedProductStatus: $getFeaturedProductStatus)';
}


}

/// @nodoc
abstract mixin class $ProductsFailureCopyWith<$Res> implements $ProductsStateCopyWith<$Res> {
  factory $ProductsFailureCopyWith(ProductsFailure value, $Res Function(ProductsFailure) _then) = _$ProductsFailureCopyWithImpl;
@override @useResult
$Res call({
 Failure failure, UseCaseState<ProductsEntity> getFeaturedProductStatus
});


@override $UseCaseStateCopyWith<ProductsEntity, $Res> get getFeaturedProductStatus;

}
/// @nodoc
class _$ProductsFailureCopyWithImpl<$Res>
    implements $ProductsFailureCopyWith<$Res> {
  _$ProductsFailureCopyWithImpl(this._self, this._then);

  final ProductsFailure _self;
  final $Res Function(ProductsFailure) _then;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failure = null,Object? getFeaturedProductStatus = null,}) {
  return _then(ProductsFailure(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,getFeaturedProductStatus: null == getFeaturedProductStatus ? _self.getFeaturedProductStatus : getFeaturedProductStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<ProductsEntity>,
  ));
}

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCaseStateCopyWith<ProductsEntity, $Res> get getFeaturedProductStatus {
  
  return $UseCaseStateCopyWith<ProductsEntity, $Res>(_self.getFeaturedProductStatus, (value) {
    return _then(_self.copyWith(getFeaturedProductStatus: value));
  });
}
}

// dart format on
