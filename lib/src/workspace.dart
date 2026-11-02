import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'operation.dart';
import 'project.dart';
import 'validation_cache.dart';

class FileFingerprint {
  const FileFingerprint(this.digest, this.length, this.mode);
  final String digest;
  final int length;
  final int mode;
  @override
  bool operator ==(Object other) =>
      other is FileFingerprint &&
      digest == other.digest &&
      length == other.length &&
      mode == other.mode;
  @override
  int get hashCode => Object.hash(digest, length, mode);
}

Future<FileFingerprint> fingerprint(File file) async {
  final before = file.statSync();
  final digest = await sha256.bind(file.openRead()).first;
  final after = file.statSync();
  if (before.size != after.size || before.modified != after.modified) {
    throw GenerationException('File changed while reading: ${file.path}');
  }
  return FileFingerprint('$digest', after.size, after.mode);
}

String digestBytes(List<int> bytes) => '${sha256.convert(bytes)}';
String relativePath(String root, String path) =>
    p.relative(path, from: root).split(p.separator).join('/');

/// Stages only Dart inputs, declared assets/configuration, and selected platforms.
/// Contents are copied by the filesystem and hashed as streams, not held in RAM.
class StagedWorkspace {
  StagedWorkspace(
    this.project,
    this.context, {
    Set<String>? platforms,
    String? cacheIdentity,
  }) : platforms = platforms ?? {},
       _cache = cacheIdentity == null
           ? null
           : ValidationCache(project, cacheIdentity);
  ValidationCache? _cache;
  final Project project;
  final OperationContext context;
  final Set<String> platforms;
  Directory? _directory;
  Directory get directory =>
      _directory ?? (throw StateError('Workspace not created.'));
  late final Set<String> inputRoots;
  static const outputRoots = {
    'lib',
    'test',
    'integration_test',
    'assets',
    'config',
  };
  static const nativePlatforms = {
    'android',
    'ios',
    'macos',
    'linux',
    'windows',
    'web',
  };
  static const ignoredNames = {
    '.git',
    '.dart_tool',
    '.gradle',
    '.symlinks',
    'Pods',
    'build',
    'ephemeral',
    'node_modules',
    'DerivedData',
    '.DS_Store',
  };

  Future<Map<String, FileFingerprint>> create() async {
    final cache = Directory(project.file('.cleany/cache'))
      ..createSync(recursive: true);
    _directory = await _cache?.prepare(context);
    if (_directory == null) {
      _cache = null;
      _directory = await cache.createTemp('stage_');
      File(p.join(directory.path, '.cleany-stage'))
          .writeAsStringSync(project.root);
    }
    inputRoots = {
      'lib',
      'test',
      'integration_test',
      'config',
      'tool',
      ...platforms,
    };
    final yaml = loadYaml(project.read('pubspec.yaml'));
    if (yaml is YamlMap && yaml['flutter'] is YamlMap) {
      final flutter = yaml['flutter'] as YamlMap;
      void asset(Object? path) {
        if (path is! String) return;
        final normalized = p.posix.normalize(
          path.replaceAll(RegExp(r'/$'), ''),
        );
        project.file(normalized);
        // Secrets must never be shipped as assets or copied into a workspace.
        if (p.posix.basename(normalized).startsWith('.env') ||
            RegExp(r'\.(jks|keystore|p12|p8|pem)$').hasMatch(normalized)) {
          throw GenerationException(
            'Sensitive asset is unsupported: $path. Remove credentials from bundled assets.',
          );
        }
        inputRoots.add(normalized);
      }

      for (final entry in flutter['assets'] as List? ?? []) {
        asset(entry is Map ? entry['path'] : entry);
      }
      for (final family in flutter['fonts'] as List? ?? []) {
        for (final font in (family as Map)['fonts'] as List? ?? []) {
          asset((font as Map)['asset']);
        }
      }
    }
    _includeReferencedConfiguration();
    final baseline = await snapshot(project.root);
    for (final path in baseline.keys) {
      context.cancellation.check();
      final destination = File(p.join(directory.path, path));
      destination.parent.createSync(recursive: true);
      await File(project.file(path)).copy(destination.path);
      final copied = await fingerprint(destination);
      if (copied.digest != baseline[path]!.digest ||
          copied.length != baseline[path]!.length ||
          (!Platform.isWindows && copied.mode != baseline[path]!.mode)) {
        throw GenerationException('Input changed while staging: $path');
      }
    }
    context.report('staging', detail: '${baseline.length} inputs copied');
    return baseline;
  }

  // Follow local YAML references recursively, retaining their relative layout.
  void _includeReferencedConfiguration() {
    final pending = <String>[
      'analysis_options.yaml',
      'build.yaml',
      'dart_test.yaml',
    ];
    final seen = <String>{};
    while (pending.isNotEmpty) {
      final relative = pending.removeLast();
      if (!seen.add(relative)) continue;
      final file = File(project.file(relative));
      if (!file.existsSync()) continue;
      void include(String value) {
        if (value.startsWith('package:') || value.contains(':')) return;
        final target = p.posix.normalize(
          p.posix.join(p.posix.dirname(relative), value),
        );
        project.file(target);
        if (!File(project.file(target)).existsSync()) {
          throw GenerationException(
            'Referenced configuration is missing: $target (from $relative).',
          );
        }
        inputRoots.add(target);
        pending.add(target);
      }

      if (relative.endsWith('.dart')) {
        final unit = parseString(
          content: file.readAsStringSync(),
          throwIfDiagnostics: false,
        ).unit;
        for (final directive in unit.directives) {
          if (directive is UriBasedDirective &&
              directive.uri.stringValue != null) {
            include(directive.uri.stringValue!);
          }
          if (directive is ImportDirective) {
            for (final config in directive.configurations) {
              if (config.uri.stringValue != null) {
                include(config.uri.stringValue!);
              }
            }
          }
          if (directive is ExportDirective) {
            for (final config in directive.configurations) {
              if (config.uri.stringValue != null) {
                include(config.uri.stringValue!);
              }
            }
          }
        }
        continue;
      }
      final yaml = loadYaml(file.readAsStringSync());
      void visit(Object? value, [String? key]) {
        if (value is Map) {
          for (final entry in value.entries) {
            visit(entry.value, '${entry.key}');
          }
        } else if (value is List) {
          for (final entry in value) {
            visit(entry, key);
          }
        } else if (value is String &&
            (key == 'include' ||
                key == 'includes' ||
                key == 'import' ||
                key == 'imports') &&
            !value.startsWith('package:') &&
            !value.contains('://')) {
          include(value);
        }
      }

      visit(yaml);
    }
  }

  static const rootFiles = {
    'pubspec.yaml',
    'pubspec.lock',
    'pubspec_overrides.yaml',
    'analysis_options.yaml',
    'build.yaml',
    'l10n.yaml',
    'dart_test.yaml',
    'flavorizr.yaml',
    '.metadata',
    '.vscode/launch.json',
    'CLEANY_RUN.md',
    'LOCAL_STORAGE.md',
    '.gitignore',
  };

  Future<Map<String, FileFingerprint>> snapshot(
    String root, {
    bool includeOutputs = false,
  }) async {
    final result = <String, FileFingerprint>{};
    final roots = {
      ...inputRoots,
      if (includeOutputs) ...outputRoots,
      ...platforms,
    };
    final visited = <String>{};
    Future<void> visit(FileSystemEntity entity) async {
      context.cancellation.check();
      final relative = relativePath(root, entity.path);
      if (!visited.add(relative)) return;
      if (ignoredNames.contains(p.basename(entity.path))) return;
      if (entity is Link) {
        throw GenerationException(
          'Symlinked inputs are unsupported: $relative',
        );
      }
      if (entity is Directory) {
        for (final child in entity.listSync(followLinks: false)) {
          await visit(child);
        }
      } else if (entity is File) {
        final name = p.basename(entity.path);
        if (name.startsWith('.env') ||
            RegExp(r'\.(jks|keystore|p12|p8|pem)$').hasMatch(name)) {
          if (nativePlatforms.contains(p.posix.split(relative).first)) return;
          throw GenerationException(
            'Sensitive file is inside staged inputs: $relative. Keep credentials outside bundled sources and assets.',
          );
        }
        result[relative] = await fingerprint(entity);
      }
    }

    for (final relative in {...rootFiles, ...roots}) {
      final path = p.join(root, relative);
      final type = FileSystemEntity.typeSync(path, followLinks: false);
      if (type == FileSystemEntityType.directory) {
        await visit(Directory(path));
      } else if (type == FileSystemEntityType.file) {
        await visit(File(path));
      } else if (type == FileSystemEntityType.link) {
        await visit(Link(path));
      }
    }
    return result;
  }

  /// Unexpected source outputs fail, rather than passing validation then vanishing.
  void rejectUnexpectedOutputs() {
    for (final entity in directory.listSync(followLinks: false)) {
      final name = p.basename(entity.path);
      if (name == '.vscode' && entity is Directory) {
        for (final child in entity.listSync(
          recursive: true,
          followLinks: false,
        )) {
          if (child is! File ||
              !rootFiles.contains(relativePath(directory.path, child.path))) {
            throw const GenerationException(
              'A builder produced an unsupported VS Code output.',
            );
          }
        }
        continue;
      }
      if (ignoredNames.contains(name) ||
          name == '.cleany' ||
          name == '.cleany-stage' ||
          name == ValidationCache.markerName ||
          name == '.flutter-plugins-dependencies' ||
          rootFiles.contains(name) ||
          inputRoots.any((root) => p.posix.split(root).first == name) ||
          outputRoots.contains(name) ||
          platforms.contains(name)) {
        continue;
      }
      throw GenerationException(
        'A builder produced an unsupported output: $name. Configure it inside lib, test, integration_test, assets, or config.',
      );
    }
  }

  static Future<int> cleanOrphans(Project project) async {
    final directory = Directory(project.file('.cleany/cache'));
    if (!directory.existsSync()) return 0;
    var removed = 0;
    for (final entry
        in directory.listSync(followLinks: false).whereType<Directory>()) {
      final marker = File(p.join(entry.path, '.cleany-stage'));
      if (marker.existsSync() && marker.readAsStringSync() == project.root) {
        await entry.delete(recursive: true);
        removed++;
      }
    }
    return removed;
  }

  Future<void> dispose({bool preserveCache = false}) async {
    if (_cache != null) {
      await _cache!.dispose(validated: preserveCache);
      return;
    }
    final created = _directory;
    if (created != null && created.existsSync()) {
      await created.delete(recursive: true);
    }
  }
}

/// Applies validated POSIX permissions with content; Windows uses its ACL policy.
void setFileMode(File file, int? mode) {
  if (Platform.isWindows || mode == null) return;
  final result = Process.runSync('chmod', [mode.toRadixString(8), file.path]);
  if (result.exitCode != 0) {
    throw GenerationException(
      'Cannot preserve permissions for ${file.path}: ${result.stderr}',
    );
  }
}
