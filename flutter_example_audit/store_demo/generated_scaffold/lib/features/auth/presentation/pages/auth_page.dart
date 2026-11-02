// Builds the feature page and renders loading, entity success, and failure states.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Builds the feature page and renders loading, entity success, and failure states.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});
  @override
  Widget build(BuildContext context) {
    final _ = context.read<AuthCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Auth')),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) => switch (state) {
          AuthInitial() => const SizedBox.shrink(),
          AuthLoading() => const Center(child: CircularProgressIndicator()),
          AuthSuccess(:final entity) => Center(
            child: Text(entity.id.toString()),
          ),
          AuthFailure(:final failure) => Center(child: Text(failure.message)),
        },
      ),
    );
  }
}
