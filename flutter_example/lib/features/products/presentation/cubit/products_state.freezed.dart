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

 UseCaseState<ProductsEntity> get getFeaturedProductStatus; String get query; String? get category; bool get priceAscending;
/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsStateCopyWith<ProductsState> get copyWith => _$ProductsStateCopyWithImpl<ProductsState>(this as ProductsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProductsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsState&&(identical(other.getFeaturedProductStatus, _this.getFeaturedProductStatus) || other.getFeaturedProductStatus == _this.getFeaturedProductStatus)&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.priceAscending, _this.priceAscending) || other.priceAscending == _this.priceAscending));
}


@override
int get hashCode {
  final _this = this as ProductsState;
  return Object.hash(runtimeType,_this.getFeaturedProductStatus,_this.query,_this.category,_this.priceAscending);
}

@override
String toString() {
  final _this = this as ProductsState;
  return 'ProductsState(getFeaturedProductStatus: ${_this.getFeaturedProductStatus}, query: ${_this.query}, category: ${_this.category}, priceAscending: ${_this.priceAscending})';
}


}

/// @nodoc
abstract mixin class $ProductsStateCopyWith<$Res>  {
  factory $ProductsStateCopyWith(ProductsState value, $Res Function(ProductsState) _then) = _$ProductsStateCopyWithImpl;
@useResult
$Res call({
 UseCaseState<ProductsEntity> getFeaturedProductStatus, String query, String? category, bool priceAscending
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
@pragma('vm:prefer-inline') @override $Res call({Object? getFeaturedProductStatus = null,Object? query = null,Object? category = freezed,Object? priceAscending = null,}) {
  return _then(_self.copyWith(
getFeaturedProductStatus: null == getFeaturedProductStatus ? _self.getFeaturedProductStatus : getFeaturedProductStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<ProductsEntity>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,priceAscending: null == priceAscending ? _self.priceAscending : priceAscending // ignore: cast_nullable_to_non_nullable
as bool,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( UseCaseState<ProductsEntity> getFeaturedProductStatus,  String query,  String? category,  bool priceAscending)?  initial,TResult Function( UseCaseState<ProductsEntity> getFeaturedProductStatus,  String query,  String? category,  bool priceAscending)?  loading,TResult Function( List<ProductsEntity> products,  UseCaseState<ProductsEntity> getFeaturedProductStatus,  String query,  String? category,  bool priceAscending)?  success,TResult Function( Failure failure,  UseCaseState<ProductsEntity> getFeaturedProductStatus,  String query,  String? category,  bool priceAscending)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProductsInitial() when initial != null:
return initial(_that.getFeaturedProductStatus,_that.query,_that.category,_that.priceAscending);case ProductsLoading() when loading != null:
return loading(_that.getFeaturedProductStatus,_that.query,_that.category,_that.priceAscending);case ProductsSuccess() when success != null:
return success(_that.products,_that.getFeaturedProductStatus,_that.query,_that.category,_that.priceAscending);case ProductsFailure() when failure != null:
return failure(_that.failure,_that.getFeaturedProductStatus,_that.query,_that.category,_that.priceAscending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( UseCaseState<ProductsEntity> getFeaturedProductStatus,  String query,  String? category,  bool priceAscending)  initial,required TResult Function( UseCaseState<ProductsEntity> getFeaturedProductStatus,  String query,  String? category,  bool priceAscending)  loading,required TResult Function( List<ProductsEntity> products,  UseCaseState<ProductsEntity> getFeaturedProductStatus,  String query,  String? category,  bool priceAscending)  success,required TResult Function( Failure failure,  UseCaseState<ProductsEntity> getFeaturedProductStatus,  String query,  String? category,  bool priceAscending)  failure,}) {final _that = this;
switch (_that) {
case ProductsInitial():
return initial(_that.getFeaturedProductStatus,_that.query,_that.category,_that.priceAscending);case ProductsLoading():
return loading(_that.getFeaturedProductStatus,_that.query,_that.category,_that.priceAscending);case ProductsSuccess():
return success(_that.products,_that.getFeaturedProductStatus,_that.query,_that.category,_that.priceAscending);case ProductsFailure():
return failure(_that.failure,_that.getFeaturedProductStatus,_that.query,_that.category,_that.priceAscending);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( UseCaseState<ProductsEntity> getFeaturedProductStatus,  String query,  String? category,  bool priceAscending)?  initial,TResult? Function( UseCaseState<ProductsEntity> getFeaturedProductStatus,  String query,  String? category,  bool priceAscending)?  loading,TResult? Function( List<ProductsEntity> products,  UseCaseState<ProductsEntity> getFeaturedProductStatus,  String query,  String? category,  bool priceAscending)?  success,TResult? Function( Failure failure,  UseCaseState<ProductsEntity> getFeaturedProductStatus,  String query,  String? category,  bool priceAscending)?  failure,}) {final _that = this;
switch (_that) {
case ProductsInitial() when initial != null:
return initial(_that.getFeaturedProductStatus,_that.query,_that.category,_that.priceAscending);case ProductsLoading() when loading != null:
return loading(_that.getFeaturedProductStatus,_that.query,_that.category,_that.priceAscending);case ProductsSuccess() when success != null:
return success(_that.products,_that.getFeaturedProductStatus,_that.query,_that.category,_that.priceAscending);case ProductsFailure() when failure != null:
return failure(_that.failure,_that.getFeaturedProductStatus,_that.query,_that.category,_that.priceAscending);case _:
  return null;

}
}

}

/// @nodoc


class ProductsInitial implements ProductsState {
  const ProductsInitial({this.getFeaturedProductStatus = const UseCaseState<ProductsEntity>.initial(), this.query = '', this.category, this.priceAscending = false});
  

@override@JsonKey() final  UseCaseState<ProductsEntity> getFeaturedProductStatus;
@override@JsonKey() final  String query;
@override final  String? category;
@override@JsonKey() final  bool priceAscending;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsInitialCopyWith<ProductsInitial> get copyWith => _$ProductsInitialCopyWithImpl<ProductsInitial>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsInitial&&(identical(other.getFeaturedProductStatus, getFeaturedProductStatus) || other.getFeaturedProductStatus == getFeaturedProductStatus)&&(identical(other.query, query) || other.query == query)&&(identical(other.category, category) || other.category == category)&&(identical(other.priceAscending, priceAscending) || other.priceAscending == priceAscending));
}


@override
int get hashCode {
    return Object.hash(runtimeType,getFeaturedProductStatus,query,category,priceAscending);
}

@override
String toString() {
    return 'ProductsState.initial(getFeaturedProductStatus: $getFeaturedProductStatus, query: $query, category: $category, priceAscending: $priceAscending)';
}


}

/// @nodoc
abstract mixin class $ProductsInitialCopyWith<$Res> implements $ProductsStateCopyWith<$Res> {
  factory $ProductsInitialCopyWith(ProductsInitial value, $Res Function(ProductsInitial) _then) = _$ProductsInitialCopyWithImpl;
@override @useResult
$Res call({
 UseCaseState<ProductsEntity> getFeaturedProductStatus, String query, String? category, bool priceAscending
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
@override @pragma('vm:prefer-inline') $Res call({Object? getFeaturedProductStatus = null,Object? query = null,Object? category = freezed,Object? priceAscending = null,}) {
  return _then(ProductsInitial(
getFeaturedProductStatus: null == getFeaturedProductStatus ? _self.getFeaturedProductStatus : getFeaturedProductStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<ProductsEntity>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,priceAscending: null == priceAscending ? _self.priceAscending : priceAscending // ignore: cast_nullable_to_non_nullable
as bool,
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
  const ProductsLoading({this.getFeaturedProductStatus = const UseCaseState<ProductsEntity>.initial(), this.query = '', this.category, this.priceAscending = false});
  

@override@JsonKey() final  UseCaseState<ProductsEntity> getFeaturedProductStatus;
@override@JsonKey() final  String query;
@override final  String? category;
@override@JsonKey() final  bool priceAscending;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsLoadingCopyWith<ProductsLoading> get copyWith => _$ProductsLoadingCopyWithImpl<ProductsLoading>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsLoading&&(identical(other.getFeaturedProductStatus, getFeaturedProductStatus) || other.getFeaturedProductStatus == getFeaturedProductStatus)&&(identical(other.query, query) || other.query == query)&&(identical(other.category, category) || other.category == category)&&(identical(other.priceAscending, priceAscending) || other.priceAscending == priceAscending));
}


@override
int get hashCode {
    return Object.hash(runtimeType,getFeaturedProductStatus,query,category,priceAscending);
}

@override
String toString() {
    return 'ProductsState.loading(getFeaturedProductStatus: $getFeaturedProductStatus, query: $query, category: $category, priceAscending: $priceAscending)';
}


}

/// @nodoc
abstract mixin class $ProductsLoadingCopyWith<$Res> implements $ProductsStateCopyWith<$Res> {
  factory $ProductsLoadingCopyWith(ProductsLoading value, $Res Function(ProductsLoading) _then) = _$ProductsLoadingCopyWithImpl;
@override @useResult
$Res call({
 UseCaseState<ProductsEntity> getFeaturedProductStatus, String query, String? category, bool priceAscending
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
@override @pragma('vm:prefer-inline') $Res call({Object? getFeaturedProductStatus = null,Object? query = null,Object? category = freezed,Object? priceAscending = null,}) {
  return _then(ProductsLoading(
getFeaturedProductStatus: null == getFeaturedProductStatus ? _self.getFeaturedProductStatus : getFeaturedProductStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<ProductsEntity>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,priceAscending: null == priceAscending ? _self.priceAscending : priceAscending // ignore: cast_nullable_to_non_nullable
as bool,
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
  const ProductsSuccess( List<ProductsEntity> products, {this.getFeaturedProductStatus = const UseCaseState<ProductsEntity>.initial(), this.query = '', this.category, this.priceAscending = false}): _products = products;
  

 final  List<ProductsEntity> _products;
 List<ProductsEntity> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

@override@JsonKey() final  UseCaseState<ProductsEntity> getFeaturedProductStatus;
@override@JsonKey() final  String query;
@override final  String? category;
@override@JsonKey() final  bool priceAscending;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsSuccessCopyWith<ProductsSuccess> get copyWith => _$ProductsSuccessCopyWithImpl<ProductsSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsSuccess&&const DeepCollectionEquality().equals(other.products, _products)&&(identical(other.getFeaturedProductStatus, getFeaturedProductStatus) || other.getFeaturedProductStatus == getFeaturedProductStatus)&&(identical(other.query, query) || other.query == query)&&(identical(other.category, category) || other.category == category)&&(identical(other.priceAscending, priceAscending) || other.priceAscending == priceAscending));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_products),getFeaturedProductStatus,query,category,priceAscending);
}

@override
String toString() {
    return 'ProductsState.success(products: $products, getFeaturedProductStatus: $getFeaturedProductStatus, query: $query, category: $category, priceAscending: $priceAscending)';
}


}

/// @nodoc
abstract mixin class $ProductsSuccessCopyWith<$Res> implements $ProductsStateCopyWith<$Res> {
  factory $ProductsSuccessCopyWith(ProductsSuccess value, $Res Function(ProductsSuccess) _then) = _$ProductsSuccessCopyWithImpl;
@override @useResult
$Res call({
 List<ProductsEntity> products, UseCaseState<ProductsEntity> getFeaturedProductStatus, String query, String? category, bool priceAscending
});


@override $UseCaseStateCopyWith<ProductsEntity, $Res> get getFeaturedProductStatus;

}
/// @nodoc
class _$ProductsSuccessCopyWithImpl<$Res>
    implements $ProductsSuccessCopyWith<$Res> {
  _$ProductsSuccessCopyWithImpl(this._self, this._then);

  final ProductsSuccess _self;
  final $Res Function(ProductsSuccess) _then;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? products = null,Object? getFeaturedProductStatus = null,Object? query = null,Object? category = freezed,Object? priceAscending = null,}) {
  return _then(ProductsSuccess(
null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<ProductsEntity>,getFeaturedProductStatus: null == getFeaturedProductStatus ? _self.getFeaturedProductStatus : getFeaturedProductStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<ProductsEntity>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,priceAscending: null == priceAscending ? _self.priceAscending : priceAscending // ignore: cast_nullable_to_non_nullable
as bool,
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


class ProductsFailure implements ProductsState {
  const ProductsFailure(this.failure, {this.getFeaturedProductStatus = const UseCaseState<ProductsEntity>.initial(), this.query = '', this.category, this.priceAscending = false});
  

 final  Failure failure;
@override@JsonKey() final  UseCaseState<ProductsEntity> getFeaturedProductStatus;
@override@JsonKey() final  String query;
@override final  String? category;
@override@JsonKey() final  bool priceAscending;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsFailureCopyWith<ProductsFailure> get copyWith => _$ProductsFailureCopyWithImpl<ProductsFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsFailure&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.getFeaturedProductStatus, getFeaturedProductStatus) || other.getFeaturedProductStatus == getFeaturedProductStatus)&&(identical(other.query, query) || other.query == query)&&(identical(other.category, category) || other.category == category)&&(identical(other.priceAscending, priceAscending) || other.priceAscending == priceAscending));
}


@override
int get hashCode {
    return Object.hash(runtimeType,failure,getFeaturedProductStatus,query,category,priceAscending);
}

@override
String toString() {
    return 'ProductsState.failure(failure: $failure, getFeaturedProductStatus: $getFeaturedProductStatus, query: $query, category: $category, priceAscending: $priceAscending)';
}


}

/// @nodoc
abstract mixin class $ProductsFailureCopyWith<$Res> implements $ProductsStateCopyWith<$Res> {
  factory $ProductsFailureCopyWith(ProductsFailure value, $Res Function(ProductsFailure) _then) = _$ProductsFailureCopyWithImpl;
@override @useResult
$Res call({
 Failure failure, UseCaseState<ProductsEntity> getFeaturedProductStatus, String query, String? category, bool priceAscending
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
@override @pragma('vm:prefer-inline') $Res call({Object? failure = null,Object? getFeaturedProductStatus = null,Object? query = null,Object? category = freezed,Object? priceAscending = null,}) {
  return _then(ProductsFailure(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,getFeaturedProductStatus: null == getFeaturedProductStatus ? _self.getFeaturedProductStatus : getFeaturedProductStatus // ignore: cast_nullable_to_non_nullable
as UseCaseState<ProductsEntity>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,priceAscending: null == priceAscending ? _self.priceAscending : priceAscending // ignore: cast_nullable_to_non_nullable
as bool,
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
