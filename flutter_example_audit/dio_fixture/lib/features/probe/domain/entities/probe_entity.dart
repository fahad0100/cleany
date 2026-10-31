// Defines immutable business data consumed by use cases and presentation.
import 'package:freezed_annotation/freezed_annotation.dart';
part 'probe_entity.freezed.dart';

/// Defines immutable business data consumed by use cases and presentation.
@freezed
abstract class ProbeEntity with _$ProbeEntity {
  const factory ProbeEntity({required String id}) = _ProbeEntity;
}
