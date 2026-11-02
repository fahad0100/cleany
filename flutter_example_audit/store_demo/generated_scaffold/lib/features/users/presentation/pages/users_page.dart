// Builds the feature page and renders loading, entity success, and failure states.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/users_cubit.dart';
import '../cubit/users_state.dart';

/// Builds the feature page and renders loading, entity success, and failure states.
class UsersPage extends StatelessWidget {
  const UsersPage({super.key});
  @override
  Widget build(BuildContext context) {
    final _ = context.read<UsersCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: BlocBuilder<UsersCubit, UsersState>(
        builder: (context, state) => switch (state) {
          UsersInitial() => const SizedBox.shrink(),
          UsersLoading() => const Center(child: CircularProgressIndicator()),
          UsersSuccess(:final entity) => Center(
            child: Text(entity.id.toString()),
          ),
          UsersFailure(:final failure) => Center(child: Text(failure.message)),
        },
      ),
    );
  }
}
