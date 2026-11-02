// Builds a reusable widget and renders its optional presentation state.
// Cleany component layout: flat. Widget lives at the component root.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/quantity_stepper_cubit.dart';
import 'cubit/quantity_stepper_state.dart';

/// Builds a reusable widget and renders its optional presentation state.
class QuantityStepperWidget extends StatelessWidget {
  const QuantityStepperWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final _ = context.read<QuantityStepperCubit>();
    return BlocBuilder<QuantityStepperCubit, QuantityStepperState>(
      builder: (context, state) => switch (state) {
        QuantityStepperInitial() => const SizedBox.shrink(),
        QuantityStepperUpdated(:final value) => Text('$value'),
      },
    );
  }
}
