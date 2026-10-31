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

  /// Nonfatal monitoring and cleanup diagnostics, independent of application.
  final List<String> warnings = [];

  /// Records a bounded diagnostic without interrupting durable work.
  void warn(String message) {
    if (warnings.length < 50 && !warnings.contains(message)) {
      warnings.add(message);
    }
  }

  /// Emits an update; observers cannot change the outcome of an operation.
  void report(
    String stage, {
    String? command,
    String? detail,
    bool completed = false,
  }) {
    try {
      onProgress?.call(
        OperationEvent(
          stage,
          watch.elapsed,
          command: command,
          detail: detail,
          completed: completed,
        ),
      );
    } on Object catch (error) {
      warn('Progress observer failed: $error');
    }
  }

  /// Watches Ctrl+C; cancel the returned subscription after the operation.
  StreamSubscription<ProcessSignal>? watchInterrupts() {
    return ProcessSignal.sigint.watch().listen((_) => cancellation.cancel());
  }
}

/// Durable outcome, separate from progress delivery and temporary-file cleanup.
enum OperationStatus {
  applied,
  appliedWithWarnings,
  rolledBack,
  recoveryRequired,
}

/// Reports whether application succeeded and any nonfatal diagnostics.
class OperationResult {
  /// Creates an immutable outcome.
  OperationResult(this.status, [Iterable<String> warnings = const []])
    : warnings = List.unmodifiable(warnings);

  /// State of the durable project files.
  final OperationStatus status;

  /// Monitoring or cleanup diagnostics that did not undo a successful commit.
  final List<String> warnings;
}

/// An operation failure with an explicit rollback/recovery outcome.
class OperationFailure extends GenerationException {
  /// Preserves the original diagnostic and its durable outcome.
  OperationFailure(super.message, this.result);

  /// State to present alongside the failure.
  final OperationResult result;
}
