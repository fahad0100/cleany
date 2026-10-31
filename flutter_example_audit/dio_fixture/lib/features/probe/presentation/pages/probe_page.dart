// Builds the feature page and renders loading, entity success, and failure states.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/probe_bloc.dart';
import '../bloc/probe_state.dart';

/// Builds the feature page and renders loading, entity success, and failure states.
class ProbePage extends StatelessWidget {
  const ProbePage({super.key});
  @override
  Widget build(BuildContext context) {
    final _ = context.read<ProbeBloc>();
    return Scaffold(
      appBar: AppBar(title: const Text('Probe')),
      body: BlocBuilder<ProbeBloc, ProbeState>(
        builder: (context, state) => switch (state) {
          ProbeInitial() => const SizedBox.shrink(),
          ProbeLoading() => const Center(child: CircularProgressIndicator()),
          ProbeSuccess(:final entity) => Center(
            child: Text(entity.id.toString()),
          ),
          ProbeFailure(:final failure) => Center(child: Text(failure.message)),
        },
      ),
    );
  }
}
