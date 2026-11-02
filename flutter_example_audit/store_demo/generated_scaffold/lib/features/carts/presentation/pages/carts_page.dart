// Builds the feature page and renders loading, entity success, and failure states.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/carts_bloc.dart';
import '../bloc/carts_state.dart';

/// Builds the feature page and renders loading, entity success, and failure states.
class CartsPage extends StatelessWidget {
  const CartsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final _ = context.read<CartsBloc>();
    return Scaffold(
      appBar: AppBar(title: const Text('Carts')),
      body: BlocBuilder<CartsBloc, CartsState>(
        builder: (context, state) => switch (state) {
          CartsInitial() => const SizedBox.shrink(),
          CartsLoading() => const Center(child: CircularProgressIndicator()),
          CartsSuccess(:final entity) => Center(
            child: Text(entity.id.toString()),
          ),
          CartsFailure(:final failure) => Center(child: Text(failure.message)),
        },
      ),
    );
  }
}
