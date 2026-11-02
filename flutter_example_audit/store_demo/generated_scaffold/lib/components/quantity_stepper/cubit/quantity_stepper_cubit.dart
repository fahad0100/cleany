// Runs presentation actions and emits the corresponding immutable states.
import 'package:flutter_bloc/flutter_bloc.dart';

import 'quantity_stepper_state.dart';

/// Runs presentation actions and emits the corresponding immutable states.
class QuantityStepperCubit extends Cubit<QuantityStepperState> {
  QuantityStepperCubit() : super(const QuantityStepperState.initial());

  void update(int value) {
    if (!isClosed) emit(QuantityStepperState.updated(value));
  }
}
