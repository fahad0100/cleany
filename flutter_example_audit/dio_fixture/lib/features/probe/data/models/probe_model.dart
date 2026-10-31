// Defines the API data model and its generated JSON serialization.
// Freezed forwards JSON annotations to the generated properties.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
part 'probe_model.freezed.dart';
part 'probe_model.g.dart';

/// Defines the API data model and its generated JSON serialization.
@freezed
abstract class ProbeModel with _$ProbeModel {
  const factory ProbeModel({required String id}) = _ProbeModel;
  factory ProbeModel.fromJson(Map<String, dynamic> json) =>
      _$ProbeModelFromJson(json);
}
