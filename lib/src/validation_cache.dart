import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'operation.dart';
import 'project.dart';

/// Keeps compiler/builder state at a stable path, refreshing project sources.
/// Every operation copies current inputs and reruns builders and analysis.
class ValidationCache {
  ValidationCache(this.project, this.identity);
  final Project project;
  final String identity;
  static const relativeRoot = '.cleany/cache/validation';
  static const markerName = '.cleany-validation-cache';
  Directory get directory => Directory(project.file(relativeRoot));

  static Map<String, dynamic>? metadata(Directory directory) {
    try {
      final marker = File(p.join(directory.path, markerName));
      if (FileSystemEntity.typeSync(marker.path, followLinks: false) !=
          FileSystemEntityType.file) {
        return null;
      }
      return jsonDecode(marker.readAsStringSync()) as Map<String, dynamic>;
    } on Object {
      return null;
    }
  }

  Future<Directory?> prepare(OperationContext context) async {
    final target = directory;
    final old = metadata(target);
    if (target.existsSync()) {
      if (old?['project'] != project.root || old?['version'] != 1) {
        context.warn(
          'Unrecognized validation cache was preserved; using a fresh workspace.',
        );
        return null;
      }
      // A crash or failed validation leaves an active marker: discard its
      // metadata rather than trusting potentially incomplete build state.
      if (old?['identity'] != identity || old?['ready'] != true) {
        await target.delete(recursive: true);
      }
    }
    target.createSync(recursive: true);
    _mark(ready: false);
    // Current sources replace all previous inputs; only tool metadata is warm.
    await _removeSources();
    context.report(
      'staging',
      detail: old?['identity'] == identity && old?['ready'] == true
          ? 'reusing validated compiler cache'
          : 'fresh compiler cache',
    );
    return target;
  }

  Future<void> _removeSources() async {
    for (final entity in directory.listSync(followLinks: false)) {
      if (p.basename(entity.path) == markerName) continue;
      if (p.basename(entity.path) == '.dart_tool' && entity is Directory) {
        continue;
      }
      await entity.delete(recursive: entity is Directory);
    }
  }

  void _mark({required bool ready}) {
    File(project.file('$relativeRoot/$markerName')).writeAsStringSync(
      jsonEncode({
        'version': 1,
        'project': project.root,
        'identity': identity,
        'ready': ready,
      }),
      flush: true,
    );
  }

  Future<void> dispose({required bool validated}) async {
    if (!directory.existsSync()) return;
    if (!validated) {
      await directory.delete(recursive: true);
      return;
    }
    await _removeSources();
    _mark(ready: true);
  }
}
