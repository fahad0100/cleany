// Builds the feature page and renders loading, entity success, and failure states.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';

/// Builds the feature page and renders loading, entity success, and failure states.
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final _ = context.read<ProductsCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) => switch (state) {
          ProductsInitial() => const SizedBox.shrink(),
          ProductsLoading() => const Center(child: CircularProgressIndicator()),
          ProductsSuccess(:final entity) => Center(
            child: Text(entity.id.toString()),
          ),
          ProductsFailure(:final failure) => Center(
            child: Text(failure.message),
          ),
        },
      ),
    );
  }
}
