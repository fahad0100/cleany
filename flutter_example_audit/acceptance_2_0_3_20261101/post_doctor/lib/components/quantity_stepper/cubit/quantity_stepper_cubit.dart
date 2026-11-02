import 'package:flutter_bloc/flutter_bloc.dart';

import 'quantity_stepper_state.dart';

/// Local quantity state is owned/disposed by the component's BlocProvider.
class QuantityStepperCubit extends Cubit<QuantityStepperState> {
  QuantityStepperCubit() : super(const QuantityStepperState.updated(1));
  void update(int value) {
    if (!isClosed) {
      emit(QuantityStepperState.updated(value.clamp(1, 99).toInt()));
    }
  }
}
