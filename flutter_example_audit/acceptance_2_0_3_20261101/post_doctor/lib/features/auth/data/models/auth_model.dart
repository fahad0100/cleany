// The API's JSON shape; conversion to Domain belongs to the repository.
import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_model.freezed.dart';
part 'auth_model.g.dart';

@Freezed(toStringOverride: false)
abstract class AuthModel with _$AuthModel {
  const factory AuthModel({required String token}) = _AuthModel;
  factory AuthModel.fromJson(Map<String, dynamic> json) =>
      _$AuthModelFromJson(json);
}
