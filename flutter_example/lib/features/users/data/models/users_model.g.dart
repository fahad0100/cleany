// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UsersModel _$UsersModelFromJson(Map<String, dynamic> json) => _UsersModel(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  username: json['username'] as String,
  name: UserNameModel.fromJson(json['name'] as Map<String, dynamic>),
  address: UserAddressModel.fromJson(json['address'] as Map<String, dynamic>),
  phone: json['phone'] as String,
);

Map<String, dynamic> _$UsersModelToJson(_UsersModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'name': instance.name,
      'address': instance.address,
      'phone': instance.phone,
    };

_UserNameModel _$UserNameModelFromJson(Map<String, dynamic> json) =>
    _UserNameModel(
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
    );

Map<String, dynamic> _$UserNameModelToJson(_UserNameModel instance) =>
    <String, dynamic>{
      'firstname': instance.firstname,
      'lastname': instance.lastname,
    };

_UserAddressModel _$UserAddressModelFromJson(Map<String, dynamic> json) =>
    _UserAddressModel(
      city: json['city'] as String,
      street: json['street'] as String,
      zipcode: json['zipcode'] as String,
    );

Map<String, dynamic> _$UserAddressModelToJson(_UserAddressModel instance) =>
    <String, dynamic>{
      'city': instance.city,
      'street': instance.street,
      'zipcode': instance.zipcode,
    };
