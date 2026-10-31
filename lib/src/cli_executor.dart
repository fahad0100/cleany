import 'dart:convert';
import 'dart:io';

import 'command_runner.dart';
import 'maintenance.dart';
import 'operation.dart';
import 'project.dart';
import 'transaction.dart';

/// Executes approved menu operations independently of terminal presentation.
class CliExecutor {
  CliExecutor(this.project, this.commands);
  final Project project;
  final CommandExecutor commands;

  Future<OperationResult> apply(
    GenerationPlan plan, {
    required bool checks,
    required bool build,
    required ProgressListener onProgress,
  }) async {
    final stamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    final logPath = '.cleany/logs/operation_${stamp}_$pid.jsonl';
    final context = OperationContext(
      timeout: ProjectMaintenance(project).commandTimeout(),
    );
    void observe(OperationEvent event) {
      try {
        onProgress(event);
      } on Object catch (error) {
        context.warn('Progress display failed: $error');
      }
      try {
        final log = File(project.file(logPath));
        log.parent.createSync(recursive: true);
        log.writeAsStringSync(
          '${jsonEncode({'stage': event.stage, 'seconds': event.elapsed.inSeconds, 'command': event.command, 'detail': event.detail, 'completed': event.completed})}\n',
          mode: FileMode.append,
        );
      } on Object catch (error) {
        context.warn('Operation log could not be written: $error');
      }
    }

    // Share cancellation and diagnostics between the command runner and observer.
    final monitored = OperationContext(
      timeout: context.timeout,
      cancellation: context.cancellation,
      onProgress: observe,
    );
    final interrupts = monitored.watchInterrupts();
    try {
      final result = await GenerationTransaction(
        project,
        executor: commands,
        context: monitored,
      ).apply(plan, install: checks, build: checks && build, analyze: checks);
      final warnings = [...result.warnings, ...context.warnings];
      return OperationResult(
        warnings.isEmpty ? result.status : OperationStatus.appliedWithWarnings,
        warnings,
      );
    } finally {
      await interrupts?.cancel();
    }
  }

  Future<OperationResult> recover() =>
      GenerationTransaction(project, executor: commands).recover();
  Future<int> cleanCache() => ProjectMaintenance(project).cleanCache();
}
