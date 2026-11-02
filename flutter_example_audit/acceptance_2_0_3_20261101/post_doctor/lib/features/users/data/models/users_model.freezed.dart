// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'users_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UsersModel {

 int get id; String get email; String get username; UserNameModel get name; UserAddressModel get address; String get phone;
/// Create a copy of UsersModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsersModelCopyWith<UsersModel> get copyWith => _$UsersModelCopyWithImpl<UsersModel>(this as UsersModel, _$identity);

  /// Serializes this UsersModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UsersModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UsersModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.phone, _this.phone) || other.phone == _this.phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UsersModel;
  return Object.hash(runtimeType,_this.id,_this.email,_this.username,_this.name,_this.address,_this.phone);
}

@override
String toString() {
  final _this = this as UsersModel;
  return 'UsersModel(id: ${_this.id}, email: ${_this.email}, username: ${_this.username}, name: ${_this.name}, address: ${_this.address}, phone: ${_this.phone})';
}


}

/// @nodoc
abstract mixin class $UsersModelCopyWith<$Res>  {
  factory $UsersModelCopyWith(UsersModel value, $Res Function(UsersModel) _then) = _$UsersModelCopyWithImpl;
@useResult
$Res call({
 int id, String email, String username, UserNameModel name, UserAddressModel address, String phone
});


$UserNameModelCopyWith<$Res> get name;$UserAddressModelCopyWith<$Res> get address;

}
/// @nodoc
class _$UsersModelCopyWithImpl<$Res>
    implements $UsersModelCopyWith<$Res> {
  _$UsersModelCopyWithImpl(this._self, this._then);

  final UsersModel _self;
  final $Res Function(UsersModel) _then;

/// Create a copy of UsersModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? username = null,Object? name = null,Object? address = null,Object? phone = null,}) {
  return _then(UsersModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as UserNameModel,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as UserAddressModel,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of UsersModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserNameModelCopyWith<$Res> get name {
  
  return $UserNameModelCopyWith<$Res>(_self.name, (value) {
    return _then(_self.copyWith(name: value));
  });
}/// Create a copy of UsersModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserAddressModelCopyWith<$Res> get address {
  
  return $UserAddressModelCopyWith<$Res>(_self.address, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}


/// Adds pattern-matching-related methods to [UsersModel].
extension UsersModelPatterns on UsersModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UsersModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UsersModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UsersModel value)  $default,){
final _that = this;
switch (_that) {
case _UsersModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UsersModel value)?  $default,){
final _that = this;
switch (_that) {
case _UsersModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String email,  String username,  UserNameModel name,  UserAddressModel address,  String phone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UsersModel() when $default != null:
return $default(_that.id,_that.email,_that.username,_that.name,_that.address,_that.phone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String email,  String username,  UserNameModel name,  UserAddressModel address,  String phone)  $default,) {final _that = this;
switch (_that) {
case _UsersModel():
return $default(_that.id,_that.email,_that.username,_that.name,_that.address,_that.phone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String email,  String username,  UserNameModel name,  UserAddressModel address,  String phone)?  $default,) {final _that = this;
switch (_that) {
case _UsersModel() when $default != null:
return $default(_that.id,_that.email,_that.username,_that.name,_that.address,_that.phone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UsersModel implements UsersModel {
  const _UsersModel({required this.id, required this.email, required this.username, required this.name, required this.address, required this.phone});
  factory _UsersModel.fromJson(Map<String, dynamic> json) => _$UsersModelFromJson(json);

@override final  int id;
@override final  String email;
@override final  String username;
@override final  UserNameModel name;
@override final  UserAddressModel address;
@override final  String phone;

/// Create a copy of UsersModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UsersModelCopyWith<_UsersModel> get copyWith => __$UsersModelCopyWithImpl<_UsersModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UsersModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UsersModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.username, username) || other.username == username)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,email,username,name,address,phone);
}

@override
String toString() {
    return 'UsersModel(id: $id, email: $email, username: $username, name: $name, address: $address, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$UsersModelCopyWith<$Res> implements $UsersModelCopyWith<$Res> {
  factory _$UsersModelCopyWith(_UsersModel value, $Res Function(_UsersModel) _then) = __$UsersModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String email, String username, UserNameModel name, UserAddressModel address, String phone
});


@override $UserNameModelCopyWith<$Res> get name;@override $UserAddressModelCopyWith<$Res> get address;

}
/// @nodoc
class __$UsersModelCopyWithImpl<$Res>
    implements _$UsersModelCopyWith<$Res> {
  __$UsersModelCopyWithImpl(this._self, this._then);

  final _UsersModel _self;
  final $Res Function(_UsersModel) _then;

/// Create a copy of UsersModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? username = null,Object? name = null,Object? address = null,Object? phone = null,}) {
  return _then(_UsersModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as UserNameModel,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as UserAddressModel,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of UsersModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserNameModelCopyWith<$Res> get name {
  
  return $UserNameModelCopyWith<$Res>(_self.name, (value) {
    return _then(_self.copyWith(name: value));
  });
}/// Create a copy of UsersModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserAddressModelCopyWith<$Res> get address {
  
  return $UserAddressModelCopyWith<$Res>(_self.address, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}


/// @nodoc
mixin _$UserNameModel {

 String get firstname; String get lastname;
/// Create a copy of UserNameModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserNameModelCopyWith<UserNameModel> get copyWith => _$UserNameModelCopyWithImpl<UserNameModel>(this as UserNameModel, _$identity);

  /// Serializes this UserNameModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserNameModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserNameModel&&(identical(other.firstname, _this.firstname) || other.firstname == _this.firstname)&&(identical(other.lastname, _this.lastname) || other.lastname == _this.lastname));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserNameModel;
  return Object.hash(runtimeType,_this.firstname,_this.lastname);
}

@override
String toString() {
  final _this = this as UserNameModel;
  return 'UserNameModel(firstname: ${_this.firstname}, lastname: ${_this.lastname})';
}


}

/// @nodoc
abstract mixin class $UserNameModelCopyWith<$Res>  {
  factory $UserNameModelCopyWith(UserNameModel value, $Res Function(UserNameModel) _then) = _$UserNameModelCopyWithImpl;
@useResult
$Res call({
 String firstname, String lastname
});




}
/// @nodoc
class _$UserNameModelCopyWithImpl<$Res>
    implements $UserNameModelCopyWith<$Res> {
  _$UserNameModelCopyWithImpl(this._self, this._then);

  final UserNameModel _self;
  final $Res Function(UserNameModel) _then;

/// Create a copy of UserNameModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? firstname = null,Object? lastname = null,}) {
  return _then(UserNameModel(
firstname: null == firstname ? _self.firstname : firstname // ignore: cast_nullable_to_non_nullable
as String,lastname: null == lastname ? _self.lastname : lastname // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserNameModel].
extension UserNameModelPatterns on UserNameModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserNameModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserNameModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserNameModel value)  $default,){
final _that = this;
switch (_that) {
case _UserNameModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserNameModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserNameModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String firstname,  String lastname)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserNameModel() when $default != null:
return $default(_that.firstname,_that.lastname);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String firstname,  String lastname)  $default,) {final _that = this;
switch (_that) {
case _UserNameModel():
return $default(_that.firstname,_that.lastname);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String firstname,  String lastname)?  $default,) {final _that = this;
switch (_that) {
case _UserNameModel() when $default != null:
return $default(_that.firstname,_that.lastname);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserNameModel implements UserNameModel {
  const _UserNameModel({required this.firstname, required this.lastname});
  factory _UserNameModel.fromJson(Map<String, dynamic> json) => _$UserNameModelFromJson(json);

@override final  String firstname;
@override final  String lastname;

/// Create a copy of UserNameModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserNameModelCopyWith<_UserNameModel> get copyWith => __$UserNameModelCopyWithImpl<_UserNameModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserNameModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserNameModel&&(identical(other.firstname, firstname) || other.firstname == firstname)&&(identical(other.lastname, lastname) || other.lastname == lastname));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,firstname,lastname);
}

@override
String toString() {
    return 'UserNameModel(firstname: $firstname, lastname: $lastname)';
}


}

/// @nodoc
abstract mixin class _$UserNameModelCopyWith<$Res> implements $UserNameModelCopyWith<$Res> {
  factory _$UserNameModelCopyWith(_UserNameModel value, $Res Function(_UserNameModel) _then) = __$UserNameModelCopyWithImpl;
@override @useResult
$Res call({
 String firstname, String lastname
});




}
/// @nodoc
class __$UserNameModelCopyWithImpl<$Res>
    implements _$UserNameModelCopyWith<$Res> {
  __$UserNameModelCopyWithImpl(this._self, this._then);

  final _UserNameModel _self;
  final $Res Function(_UserNameModel) _then;

/// Create a copy of UserNameModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? firstname = null,Object? lastname = null,}) {
  return _then(_UserNameModel(
firstname: null == firstname ? _self.firstname : firstname // ignore: cast_nullable_to_non_nullable
as String,lastname: null == lastname ? _self.lastname : lastname // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UserAddressModel {

 String get city; String get street; String get zipcode;
/// Create a copy of UserAddressModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserAddressModelCopyWith<UserAddressModel> get copyWith => _$UserAddressModelCopyWithImpl<UserAddressModel>(this as UserAddressModel, _$identity);

  /// Serializes this UserAddressModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserAddressModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserAddressModel&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.street, _this.street) || other.street == _this.street)&&(identical(other.zipcode, _this.zipcode) || other.zipcode == _this.zipcode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserAddressModel;
  return Object.hash(runtimeType,_this.city,_this.street,_this.zipcode);
}

@override
String toString() {
  final _this = this as UserAddressModel;
  return 'UserAddressModel(city: ${_this.city}, street: ${_this.street}, zipcode: ${_this.zipcode})';
}


}

/// @nodoc
abstract mixin class $UserAddressModelCopyWith<$Res>  {
  factory $UserAddressModelCopyWith(UserAddressModel value, $Res Function(UserAddressModel) _then) = _$UserAddressModelCopyWithImpl;
@useResult
$Res call({
 String city, String street, String zipcode
});




}
/// @nodoc
class _$UserAddressModelCopyWithImpl<$Res>
    implements $UserAddressModelCopyWith<$Res> {
  _$UserAddressModelCopyWithImpl(this._self, this._then);

  final UserAddressModel _self;
  final $Res Function(UserAddressModel) _then;

/// Create a copy of UserAddressModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? city = null,Object? street = null,Object? zipcode = null,}) {
  return _then(UserAddressModel(
city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,zipcode: null == zipcode ? _self.zipcode : zipcode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserAddressModel].
extension UserAddressModelPatterns on UserAddressModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserAddressModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserAddressModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserAddressModel value)  $default,){
final _that = this;
switch (_that) {
case _UserAddressModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserAddressModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserAddressModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String city,  String street,  String zipcode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserAddressModel() when $default != null:
return $default(_that.city,_that.street,_that.zipcode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String city,  String street,  String zipcode)  $default,) {final _that = this;
switch (_that) {
case _UserAddressModel():
return $default(_that.city,_that.street,_that.zipcode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String city,  String street,  String zipcode)?  $default,) {final _that = this;
switch (_that) {
case _UserAddressModel() when $default != null:
return $default(_that.city,_that.street,_that.zipcode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserAddressModel implements UserAddressModel {
  const _UserAddressModel({required this.city, required this.street, required this.zipcode});
  factory _UserAddressModel.fromJson(Map<String, dynamic> json) => _$UserAddressModelFromJson(json);

@override final  String city;
@override final  String street;
@override final  String zipcode;

/// Create a copy of UserAddressModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserAddressModelCopyWith<_UserAddressModel> get copyWith => __$UserAddressModelCopyWithImpl<_UserAddressModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserAddressModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserAddressModel&&(identical(other.city, city) || other.city == city)&&(identical(other.street, street) || other.street == street)&&(identical(other.zipcode, zipcode) || other.zipcode == zipcode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,city,street,zipcode);
}

@override
String toString() {
    return 'UserAddressModel(city: $city, street: $street, zipcode: $zipcode)';
}


}

/// @nodoc
abstract mixin class _$UserAddressModelCopyWith<$Res> implements $UserAddressModelCopyWith<$Res> {
  factory _$UserAddressModelCopyWith(_UserAddressModel value, $Res Function(_UserAddressModel) _then) = __$UserAddressModelCopyWithImpl;
@override @useResult
$Res call({
 String city, String street, String zipcode
});




}
/// @nodoc
class __$UserAddressModelCopyWithImpl<$Res>
    implements _$UserAddressModelCopyWith<$Res> {
  __$UserAddressModelCopyWithImpl(this._self, this._then);

  final _UserAddressModel _self;
  final $Res Function(_UserAddressModel) _then;

/// Create a copy of UserAddressModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? city = null,Object? street = null,Object? zipcode = null,}) {
  return _then(_UserAddressModel(
city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,zipcode: null == zipcode ? _self.zipcode : zipcode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
