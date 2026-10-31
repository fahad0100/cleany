// Runs presentation actions and emits the corresponding immutable states.
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_cleany_dio/features/probe/domain/usecases/get_probe.dart';

import 'probe_state.dart';
import 'probe_event.dart';

/// Runs presentation actions and emits the corresponding immutable states.
class ProbeBloc extends Bloc<ProbeEvent, ProbeState> {
  final GetProbe _getProbe;
  ProbeBloc(this._getProbe) : super(const ProbeState.initial()) {
    on<ProbeRequested>(_onRequested);
  }

  Future<void> _onRequested(
    ProbeRequested event,
    Emitter<ProbeState> emit,
  ) async {
    if (state is ProbeLoading) return;
    emit(const ProbeState.loading());
    final result = await _getProbe();
    if (emit.isDone) return;
    result.when(
      (entity) => emit(ProbeState.success(entity)),
      (failure) => emit(ProbeState.failure(failure)),
    );
  }
}
