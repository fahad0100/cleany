import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/quantity_stepper_cubit.dart';
import 'cubit/quantity_stepper_state.dart';

/// Flat component widget; state imports are siblings, not ../widgets paths.
class QuantityStepperWidget extends StatelessWidget {
  const QuantityStepperWidget({super.key, this.onChanged});
  final ValueChanged<int>? onChanged;
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<QuantityStepperCubit, QuantityStepperState>(
        listener: (_, state) {
          if (state case QuantityStepperUpdated(:final value)) {
            onChanged?.call(value);
          }
        },
        builder: (context, state) {
          final value = switch (state) {
            QuantityStepperInitial() => 1,
            QuantityStepperUpdated(:final value) => value,
          };
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary
                  .withValues(alpha: .06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: const Key('quantity-minus'),
                  onPressed: value > 1
                      ? () => context.read<QuantityStepperCubit>().update(
                          value - 1,
                        )
                      : null,
                  icon: const Icon(Icons.remove, size: 20),
                ),
                Text(
                  '$value',
                  key: const Key('quantity-value'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  key: const Key('quantity-plus'),
                  onPressed: () =>
                      context.read<QuantityStepperCubit>().update(value + 1),
                  icon: const Icon(Icons.add, size: 20),
                ),
              ],
            ),
          );
        },
      );
}
