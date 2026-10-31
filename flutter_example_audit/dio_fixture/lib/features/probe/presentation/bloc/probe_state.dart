// Defines immutable presentation states for the generated Cubit or Bloc.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:test_cleany_dio/features/probe/domain/entities/probe_entity.dart';
import 'package:test_cleany_dio/core/errors/failure.dart';
part 'probe_state.freezed.dart';

/// Defines immutable presentation states for the generated Cubit or Bloc.
@freezed
sealed class ProbeState with _$ProbeState {
  const factory ProbeState.initial() = ProbeInitial;
  const factory ProbeState.loading() = ProbeLoading;
  const factory ProbeState.success(ProbeEntity entity) = ProbeSuccess;
  const factory ProbeState.failure(Failure failure) = ProbeFailure;
}
