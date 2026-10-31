import 'dart:convert';
import 'dart:io';

import 'project.dart';

/// OS locks are released by the kernel after a crash; metadata is not the lock.
class ProjectLock {
  ProjectLock._(this.project, this.handle);

  /// Project protected by this operating-system lock.
  final Project project;

  /// Open lock-file handle; release through [release] rather than closing it.
  final RandomAccessFile handle;
  static final _active = <String>{};

  /// Acquires a nonblocking kernel lock and reclaims dead legacy PID metadata.
  static Future<ProjectLock> acquire(Project project) async {
    if (!_active.add(project.root)) {
      throw const GenerationException(
        'Another Cleany operation is running in this project.',
      );
    }
    RandomAccessFile? handle;
    try {
      final guard = File(project.file('.cleany/operation.lock'));
      guard.parent.createSync(recursive: true);
      handle = await guard.open(mode: FileMode.append);
      await handle.lock(FileLock.exclusive);
      // Compatibility: only refuse old PID locks when that process is alive.
      final legacy = File(project.file('.cleany/lock'));
      if (legacy.existsSync()) {
        final text = legacy.readAsStringSync().trim();
        final legacyPid = int.tryParse(text);
        if (legacyPid != null && await _isAlive(legacyPid)) {
          throw const GenerationException(
            'A legacy Cleany process is still running. Close it before continuing.',
          );
        }
      }
      legacy.writeAsStringSync(
        jsonEncode({
          'pid': pid,
          'started_at': DateTime.now().toUtc().toIso8601String(),
        }),
        flush: true,
      );
      return ProjectLock._(project, handle);
    } catch (error) {
      if (handle != null) await handle.close();
      _active.remove(project.root);
      if (error is GenerationException) rethrow;
      throw const GenerationException(
        'Another process holds the project lock. Retry after that operation completes.',
      );
    }
  }

  static Future<bool> _isAlive(int processId) async {
    if (processId <= 0) return false;
    if (Platform.isWindows) {
      final result = await Process.run('tasklist', [
        '/FI',
        'PID eq $processId',
        '/FO',
        'CSV',
        '/NH',
      ]);
      return '${result.stdout}'.contains('"$processId"');
    }
    final result = await Process.run('kill', ['-0', '$processId']);
    return result.exitCode == 0;
  }

  /// Removes informational metadata and releases the kernel lock handle.
  Future<void> release() async {
    try {
      final metadata = File(project.file('.cleany/lock'));
      if (metadata.existsSync()) await metadata.delete();
    } finally {
      try {
        await handle.unlock();
      } finally {
        await handle.close();
        _active.remove(project.root);
      }
    }
  }
}
