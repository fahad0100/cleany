import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'operation.dart';
import 'project.dart';

/// Captured exit status and bounded output from an external command.
class CommandResult {
  /// Creates a result from an exit code, stdout, and stderr.
  const CommandResult(this.exitCode, this.output, this.error);

  /// Process status; zero denotes success.
  final int exitCode;

  /// Retained standard output.
  final String output;

  /// Retained standard error.
  final String error;

  /// Whether the process completed successfully.
  bool get succeeded => exitCode == 0;

  /// Throws [GenerationException] with command diagnostics on failure.
  void requireSuccess(String command) {
    if (!succeeded) {
      throw GenerationException(
        '$command failed ($exitCode):\n$error\n$output',
      );
    }
  }
}

/// Injectable command boundary used by transactions and deterministic tests.
typedef CommandExecutor = Future<CommandResult> Function(
  String executable,
  List<String> arguments,
  String workingDirectory,
);

/// Executes a command with the default deadline and bounded output capture.
Future<CommandResult> executeCommand(
  String executable,
  List<String> arguments,
  String workingDirectory,
) => executeManagedCommand(
  executable,
  arguments,
  workingDirectory,
  OperationContext(),
);

/// Injectable OS process-tree command boundary for shutdown diagnostics.
typedef ProcessTreeCommand = Future<ProcessResult> Function(
  String executable,
  List<String> arguments,
);

/// Bounded logs, a deadline, cancellation, and child-tree termination.
Future<CommandResult> executeManagedCommand(
  String executable,
  List<String> arguments,
  String workingDirectory,
  OperationContext context, {
  ProcessTreeCommand? processTreeCommand,
}) async {
  context.cancellation.check();
  final label = '$executable ${arguments.join(' ')}';
  final clock = Stopwatch()..start();
  context.report('command', command: label);
  final process = await Process.start(
    Platform.isWindows && executable == 'flutter' ? 'flutter.bat' : executable,
    arguments,
    workingDirectory: workingDirectory,
    runInShell: Platform.isWindows,
  );
  final output = <String>[];
  final errors = <String>[];
  void append(List<String> target, String line) {
    target.add(line.length > 4096 ? line.substring(line.length - 4096) : line);
    if (target.length > 150) target.removeAt(0);
  }

  final stdoutDone = _capture(process.stdout, (line) => append(output, line));
  final stderrDone = _capture(process.stderr, (line) => append(errors, line));
  final pulse = Timer.periodic(
    const Duration(seconds: 5),
    (_) => context.report(
      'command',
      command: label,
      detail: '${clock.elapsed.inSeconds}s',
    ),
  );
  var interrupted = false;
  Future<void> terminate() async {
    interrupted = true;
    var children = <int>[];
    try {
      if (Platform.isWindows) {
        final result =
            await (processTreeCommand ??
                    ((exe, args) => Process.run(exe, args)))('taskkill', [
                  '/PID',
                  '${process.pid}',
                  '/T',
                  '/F',
                ])
                .timeout(const Duration(seconds: 2));
        if (result.exitCode != 0) {
          context.warn('taskkill failed; terminating the command directly.');
        }
      } else {
        children = await _descendants(
          process.pid,
          processTreeCommand,
        ).timeout(const Duration(seconds: 2));
      }
    } on Object catch (error) {
      context.warn(
        'Process tree inspection failed; terminating the command directly: $error',
      );
    } finally {
      for (final child in children.reversed) {
        Process.killPid(child, ProcessSignal.sigterm);
      }
      process.kill();
      if (!Platform.isWindows) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        for (final child in children.reversed) {
          Process.killPid(child, ProcessSignal.sigkill);
        }
        process.kill(ProcessSignal.sigkill);
      }
    }
  }

  final deadline = Completer<String>();
  final deadlineTimer = Timer(
    context.timeout,
    () => deadline.complete('timeout'),
  );
  final reason = await Future.any<String>([
    process.exitCode.then((_) => 'exit'),
    context.cancellation.whenCancelled.then((_) => 'cancel'),
    deadline.future,
  ]);
  try {
    if (reason != 'exit') await terminate();
    final code = await process.exitCode.timeout(
      const Duration(seconds: 5),
      onTimeout: () => -1,
    );
    await Future.wait([stdoutDone, stderrDone])
        .timeout(const Duration(seconds: 5), onTimeout: () => []);
    if (reason == 'cancel') throw const OperationCancelled();
    if (reason == 'timeout') {
      throw GenerationException(
        '$label exceeded ${context.timeout.inSeconds}s. No project changes were applied.',
      );
    }
    context.report(
      'command',
      command: label,
      detail:
          '${clock.elapsed.inMilliseconds}ms${code == 0 ? '' : ' · exit $code'}',
      completed: code == 0,
    );
    return CommandResult(code, output.join('\n'), errors.join('\n'));
  } finally {
    pulse.cancel();
    deadlineTimer.cancel();
    if (!interrupted && context.cancellation.isCancelled) process.kill();
  }
}

/// Bound partial lines as well as complete lines (some tools never emit LF).
Future<void> _capture(
  Stream<List<int>> stream,
  void Function(String) append,
) async {
  var pending = '';
  await for (final chunk in stream.transform(
    const Utf8Decoder(allowMalformed: true),
  )) {
    final lines = chunk.split('\n');
    for (var i = 0; i < lines.length; i++) {
      pending += lines[i];
      if (pending.length > 4096) {
        pending = pending.substring(pending.length - 4096);
      }
      if (i < lines.length - 1) {
        append(pending);
        pending = '';
      }
    }
  }
  if (pending.isNotEmpty) append(pending);
}

Future<List<int>> _descendants(int parent, ProcessTreeCommand? command) async {
  final result = await (command ?? ((exe, args) => Process.run(exe, args)))(
    'ps',
    ['-eo', 'pid=,ppid='],
  );
  result.exitCode == 0 ||
      (throw ProcessException(
        'ps',
        const [],
        '${result.stderr}',
        result.exitCode,
      ));
  final children = <int, List<int>>{};
  for (final line in '${result.stdout}'.split('\n')) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length != 2) continue;
    final pid = int.tryParse(parts[0]);
    final ppid = int.tryParse(parts[1]);
    if (pid != null && ppid != null) {
      children.putIfAbsent(ppid, () => []).add(pid);
    }
  }
  final descendants = <int>[];
  void visit(int process) {
    for (final child in children[process] ?? <int>[]) {
      descendants.add(child);
      visit(child);
    }
  }

  visit(parent);
  return descendants;
}
