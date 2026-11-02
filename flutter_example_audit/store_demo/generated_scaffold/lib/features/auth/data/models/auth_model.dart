// Defines the API data model and its generated JSON serialization.
// Freezed forwards JSON annotations to the generated properties.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_model.freezed.dart';
part 'auth_model.g.dart';

/// Defines the API data model and its generated JSON serialization.
@freezed
abstract class AuthModel with _$AuthModel {
  const factory AuthModel({required String id}) = _AuthModel;
  factory AuthModel.fromJson(Map<String, dynamic> json) =>
      _$AuthModelFromJson(json);
}
