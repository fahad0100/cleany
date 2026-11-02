// Defines the API data model and its generated JSON serialization.
// Freezed forwards JSON annotations to the generated properties.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
part 'users_model.freezed.dart';
part 'users_model.g.dart';

/// Defines the API data model and its generated JSON serialization.
@freezed
abstract class UsersModel with _$UsersModel {
  const factory UsersModel({required String id}) = _UsersModel;
  factory UsersModel.fromJson(Map<String, dynamic> json) =>
      _$UsersModelFromJson(json);
}
