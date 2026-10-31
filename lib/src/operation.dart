import 'dart:async';
import 'dart:io';

import 'project.dart';

/// Signals a cooperative cancellation request that permits safe rollback.
class OperationCancelled extends GenerationException {
  /// Creates the standard cancellation diagnostic.
  const OperationCancelled()
    : super('Operation cancelled; safe rollback has been requested.');
}

/// A one-way cancellation signal shared by commands and transaction stages.
class CancellationToken {
  /// Creates a fresh token with no cancellation request.
  CancellationToken();

  final _cancelled = Completer<void>();

  /// Whether cancellation has been requested.
  bool get isCancelled => _cancelled.isCompleted;

  /// Completes once cancellation is requested.
  Future<void> get whenCancelled => _cancelled.future;

  /// Requests cancellation; repeated calls have no effect.
  void cancel() {
    if (!isCancelled) _cancelled.complete();
  }

  /// Throws [OperationCancelled] after a cancellation request.
  void check() {
    if (isCancelled) throw const OperationCancelled();
  }
}

/// A stage or command progress update with operation-relative elapsed time.
class OperationEvent {
  /// Captures a stage update; [completed] marks successful completion.
  const OperationEvent(
    this.stage,
    this.elapsed, {
    this.command,
    this.detail,
    this.completed = false,
  });

  /// Stable stage label, such as staging, command, applying, or completed.
  final String stage;

  /// Total elapsed time since the operation context was created.
  final Duration elapsed;

  /// Current command label, when this event describes a process.
  final String? command;

  /// Optional stage count, command duration, or exit status.
  final String? detail;

  /// Whether this event indicates successful completion.
  final bool completed;
}

/// Receives synchronous progress events from an operation.
typedef ProgressListener = void Function(OperationEvent event);

/// Coordinates progress, per-command deadlines, and cooperative cancellation.
class OperationContext {
  /// Starts an operation clock, with a five-minute default command timeout.
  OperationContext({
    CancellationToken? cancellation,
    this.onProgress,
    this.timeout = const Duration(minutes: 5),
  }) : cancellation = cancellation ?? CancellationToken();

  /// Shared cancellation signal checked before operations and durable writes.
  final CancellationToken cancellation;

  /// Optional observer; it should complete quickly and avoid throwing.
  final ProgressListener? onProgress;

  /// Maximum execution time allowed for each external command.
  final Duration timeout;

  /// Monotonic clock used to timestamp progress events.
  final Stopwatch watch = Stopwatch()..start();

  /// Emits a progress update to the configured observer.
  void report(
    String stage, {
    String? command,
    String? detail,
    bool completed = false,
  }) {
    onProgress?.call(
      OperationEvent(
        stage,
        watch.elapsed,
        command: command,
        detail: detail,
        completed: completed,
      ),
    );
  }

  /// Watches Ctrl+C; cancel the returned subscription after the operation.
  StreamSubscription<ProcessSignal>? watchInterrupts() {
    return ProcessSignal.sigint.watch().listen((_) => cancellation.cancel());
  }
}
