// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'users_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UsersEntity {

 int get id; String get username; String get email; String get firstName; String get lastName; String get phone; String get city; String get street; String get zipcode;
/// Create a copy of UsersEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsersEntityCopyWith<UsersEntity> get copyWith => _$UsersEntityCopyWithImpl<UsersEntity>(this as UsersEntity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UsersEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UsersEntity&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.street, _this.street) || other.street == _this.street)&&(identical(other.zipcode, _this.zipcode) || other.zipcode == _this.zipcode));
}


@override
int get hashCode {
  final _this = this as UsersEntity;
  return Object.hash(runtimeType,_this.id,_this.username,_this.email,_this.firstName,_this.lastName,_this.phone,_this.city,_this.street,_this.zipcode);
}

@override
String toString() {
  final _this = this as UsersEntity;
  return 'UsersEntity(id: ${_this.id}, username: ${_this.username}, email: ${_this.email}, firstName: ${_this.firstName}, lastName: ${_this.lastName}, phone: ${_this.phone}, city: ${_this.city}, street: ${_this.street}, zipcode: ${_this.zipcode})';
}


}

/// @nodoc
abstract mixin class $UsersEntityCopyWith<$Res>  {
  factory $UsersEntityCopyWith(UsersEntity value, $Res Function(UsersEntity) _then) = _$UsersEntityCopyWithImpl;
@useResult
$Res call({
 int id, String username, String email, String firstName, String lastName, String phone, String city, String street, String zipcode
});




}
/// @nodoc
class _$UsersEntityCopyWithImpl<$Res>
    implements $UsersEntityCopyWith<$Res> {
  _$UsersEntityCopyWithImpl(this._self, this._then);

  final UsersEntity _self;
  final $Res Function(UsersEntity) _then;

/// Create a copy of UsersEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? email = null,Object? firstName = null,Object? lastName = null,Object? phone = null,Object? city = null,Object? street = null,Object? zipcode = null,}) {
  return _then(UsersEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,zipcode: null == zipcode ? _self.zipcode : zipcode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UsersEntity].
extension UsersEntityPatterns on UsersEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UsersEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UsersEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UsersEntity value)  $default,){
final _that = this;
switch (_that) {
case _UsersEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UsersEntity value)?  $default,){
final _that = this;
switch (_that) {
case _UsersEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String username,  String email,  String firstName,  String lastName,  String phone,  String city,  String street,  String zipcode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UsersEntity() when $default != null:
return $default(_that.id,_that.username,_that.email,_that.firstName,_that.lastName,_that.phone,_that.city,_that.street,_that.zipcode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String username,  String email,  String firstName,  String lastName,  String phone,  String city,  String street,  String zipcode)  $default,) {final _that = this;
switch (_that) {
case _UsersEntity():
return $default(_that.id,_that.username,_that.email,_that.firstName,_that.lastName,_that.phone,_that.city,_that.street,_that.zipcode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String username,  String email,  String firstName,  String lastName,  String phone,  String city,  String street,  String zipcode)?  $default,) {final _that = this;
switch (_that) {
case _UsersEntity() when $default != null:
return $default(_that.id,_that.username,_that.email,_that.firstName,_that.lastName,_that.phone,_that.city,_that.street,_that.zipcode);case _:
  return null;

}
}

}

/// @nodoc


class _UsersEntity implements UsersEntity {
  const _UsersEntity({required this.id, required this.username, required this.email, required this.firstName, required this.lastName, required this.phone, required this.city, required this.street, required this.zipcode});
  

@override final  int id;
@override final  String username;
@override final  String email;
@override final  String firstName;
@override final  String lastName;
@override final  String phone;
@override final  String city;
@override final  String street;
@override final  String zipcode;

/// Create a copy of UsersEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UsersEntityCopyWith<_UsersEntity> get copyWith => __$UsersEntityCopyWithImpl<_UsersEntity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UsersEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.city, city) || other.city == city)&&(identical(other.street, street) || other.street == street)&&(identical(other.zipcode, zipcode) || other.zipcode == zipcode));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,username,email,firstName,lastName,phone,city,street,zipcode);
}

@override
String toString() {
    return 'UsersEntity(id: $id, username: $username, email: $email, firstName: $firstName, lastName: $lastName, phone: $phone, city: $city, street: $street, zipcode: $zipcode)';
}


}

/// @nodoc
abstract mixin class _$UsersEntityCopyWith<$Res> implements $UsersEntityCopyWith<$Res> {
  factory _$UsersEntityCopyWith(_UsersEntity value, $Res Function(_UsersEntity) _then) = __$UsersEntityCopyWithImpl;
@override @useResult
$Res call({
 int id, String username, String email, String firstName, String lastName, String phone, String city, String street, String zipcode
});




}
/// @nodoc
class __$UsersEntityCopyWithImpl<$Res>
    implements _$UsersEntityCopyWith<$Res> {
  __$UsersEntityCopyWithImpl(this._self, this._then);

  final _UsersEntity _self;
  final $Res Function(_UsersEntity) _then;

/// Create a copy of UsersEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? email = null,Object? firstName = null,Object? lastName = null,Object? phone = null,Object? city = null,Object? street = null,Object? zipcode = null,}) {
  return _then(_UsersEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,zipcode: null == zipcode ? _self.zipcode : zipcode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
