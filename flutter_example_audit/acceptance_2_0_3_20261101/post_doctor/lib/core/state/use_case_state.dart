// Tracks each use case independently with typed loading, success, and failure states.
import 'package:freezed_annotation/freezed_annotation.dart';

import '../errors/failure.dart';
part 'use_case_state.freezed.dart';

/// Tracks each use case independently with typed loading, success, and failure states.
/// Tracks one operation independently of the feature's primary loading state.
@freezed
sealed class UseCaseState<T> with _$UseCaseState<T> {
  const factory UseCaseState.initial() = UseCaseInitial<T>;
  const factory UseCaseState.loading() = UseCaseLoading<T>;
  const factory UseCaseState.success(T value) = UseCaseSuccess<T>;
  const factory UseCaseState.failure(Failure failure) = UseCaseFailure<T>;
}
