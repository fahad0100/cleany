// Defines the events that trigger operations in the generated Bloc.
import 'package:freezed_annotation/freezed_annotation.dart';

part 'probe_event.freezed.dart';

/// Defines the events that trigger operations in the generated Bloc.
@freezed
sealed class ProbeEvent with _$ProbeEvent {
  const factory ProbeEvent.requested() = ProbeRequested;
}
