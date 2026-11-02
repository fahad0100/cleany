// The API's JSON shape; conversion to Domain belongs to the repository.
import 'package:freezed_annotation/freezed_annotation.dart';
part 'users_model.freezed.dart';
part 'users_model.g.dart';

@freezed
abstract class UsersModel with _$UsersModel {
  const factory UsersModel({
    required int id,
    required String email,
    required String username,
    required UserNameModel name,
    required UserAddressModel address,
    required String phone,
  }) = _UsersModel;
  factory UsersModel.fromJson(Map<String, dynamic> json) =>
      _$UsersModelFromJson(json);
}

@freezed
abstract class UserNameModel with _$UserNameModel {
  const factory UserNameModel({
    required String firstname,
    required String lastname,
  }) = _UserNameModel;
  factory UserNameModel.fromJson(Map<String, dynamic> json) =>
      _$UserNameModelFromJson(json);
}

@freezed
abstract class UserAddressModel with _$UserAddressModel {
  const factory UserAddressModel({
    required String city,
    required String street,
    required String zipcode,
  }) = _UserAddressModel;
  factory UserAddressModel.fromJson(Map<String, dynamic> json) =>
      _$UserAddressModelFromJson(json);
}
