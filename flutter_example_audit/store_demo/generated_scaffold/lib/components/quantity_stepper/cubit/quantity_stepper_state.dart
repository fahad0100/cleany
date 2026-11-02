// Defines immutable presentation states for the generated Cubit or Bloc.
import 'package:freezed_annotation/freezed_annotation.dart';

part 'quantity_stepper_state.freezed.dart';

/// Defines immutable presentation states for the generated Cubit or Bloc.
@freezed
sealed class QuantityStepperState with _$QuantityStepperState {
  const factory QuantityStepperState.initial() = QuantityStepperInitial;
  const factory QuantityStepperState.updated(int value) =
      QuantityStepperUpdated;
}
