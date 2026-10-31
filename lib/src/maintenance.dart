import 'dart:convert';
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'dependencies.dart';
import 'project.dart';
import 'project_lock.dart';
import 'registry.dart';
import 'specification.dart';
import 'templates/core_templates.dart';
import 'templates/documentation.dart';
import 'transaction.dart';
import 'workspace.dart';

/// Maintenance never clears the global Flutter/pub cache or recovery backups.
class ProjectMaintenance {
  /// Creates project-local maintenance operations for [project].
  ProjectMaintenance(this.project);

  /// Project whose Cleany metadata and managed sources are maintained.
  final Project project;

  /// Removes marked abandoned staging folders, preserving journals and backups.
  Future<int> cleanCache() async {
    final lock = await ProjectLock.acquire(project);
    try {
      var count = 0;
      final directory = Directory(project.file('.cleany/cache'));
      if (!directory.existsSync()) return 0;
      for (final entry
          in directory.listSync(followLinks: false).whereType<Directory>()) {
        final marker = File(p.join(entry.path, '.cleany-stage'));
        if (marker.existsSync() && marker.readAsStringSync() == project.root) {
          await entry.delete(recursive: true);
          count++;
        }
      }
      return count;
    } finally {
      await lock.release();
    }
  }

  /// Archive current managed folders and replace the architecture with a fresh
  /// fixed template. Unrelated directories, assets, and dependencies survive.
  GenerationPlan reset() {
    final registry = FeatureRegistry(project).read(strict: false);
    final projectFiles = (registry['project_files'] as List)
        .cast<Map<String, dynamic>>();
    if (!projectFiles.any(
      (record) => (record['path'] as String).startsWith('lib/core/'),
    )) {
      throw const GenerationException(
        'Run Project doctor first to establish ownership of this legacy architecture.',
      );
    }
    final package = project.validate();
    final provider = ApiProvider.values.byName(
      registry['api_provider'] as String,
    );
    final id = registry['app_id'] as String? ?? project.detectAppId();
    final fresh = coreTemplates(package, provider, id);
    final roots = <String>{
      'lib/app',
      'lib/core',
      for (final entry in registry['features'] as List) entry['path'] as String,
    };
    final plan = GenerationPlan(project);
    final stamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    final backup = '.cleany/backups/reset_$stamp';
    final paths = <String>{
      registryPath,
      for (final record in projectFiles) record['path'] as String,
      for (final entry in registry['features'] as List)
        for (final record in entry['files'] as List? ?? [])
          record['path'] as String,
    };
    for (final root in roots) {
      final directory = Directory(project.file(root));
      if (!directory.existsSync()) continue;
      plan.directoriesToRemove.add(root);
      for (final entry in directory.listSync(
        recursive: true,
        followLinks: false,
      )) {
        final relative = p
            .relative(entry.path, from: project.root)
            .split(p.separator)
            .join('/');
        project.file(relative);
        if (entry is Directory) plan.directoriesToRemove.add(relative);
        if (entry is File) paths.add(relative);
      }
    }
    for (final path in paths) {
      final file = File(project.file(path));
      if (!file.existsSync()) continue;
      plan.writeBytes(
        '$backup/$path',
        file.readAsBytesSync(),
        createOnly: true,
      );
      // Existing manifest/analysis/entrypoint modifications remain user-owned.
      if (StagedWorkspace.nativePlatforms.contains(p.posix.split(path).first) ||
          path == 'pubspec.yaml' ||
          path == 'analysis_options.yaml' ||
          path == 'lib/main.dart' ||
          path == '.gitignore') {
        continue;
      }
      plan.delete(path);
    }
    final formatter = DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    );
    final owned = <Object>[
      for (final record in projectFiles)
        if (StagedWorkspace.nativePlatforms.contains(
          p.posix.split(record['path'] as String).first,
        ))
          record,
    ];
    for (final entry in fresh.entries) {
      final content = entry.key.endsWith('.dart')
          ? formatter.format(documentGeneratedDart(entry.key, entry.value))
          : entry.value;
      plan.write(entry.key, content);
      owned.add(artifactRecord(entry.key, utf8.encode(content), '@project'));
    }
    // Preserve dependencies added by the user; add only missing template needs.
    final original = loadYaml(project.read('pubspec.yaml')) as YamlMap;
    final editor = YamlEditor(project.read('pubspec.yaml'));
    for (final group in packageRequirements(provider).entries) {
      if (original[group.key] == null) {
        editor.update([group.key], <String, Object>{});
      }
      for (final dependency in group.value.entries) {
        if (original[group.key] is Map &&
            original[group.key][dependency.key] != null) {
          continue;
        }
        editor.update([group.key, dependency.key], dependency.value);
      }
    }
    plan.write('pubspec.yaml', editor.toString());
    plan.write(
      registryPath,
      prettyJson({
        'version': registryVersion,
        'template_version': templateVersion,
        'api_provider': provider.name,
        'app_id': id,
        'project_files': owned,
        'features': <Object>[],
        'last_reset_backup': backup,
      }),
    );
    plan.write(
      '$backup/README.txt',
      'Archived before resetting Cleany. Restore selected files manually after reviewing their imports and dependencies.\n',
    );
    return plan;
  }

  /// Reads a valid local command timeout, falling back to five minutes.
  Duration commandTimeout() {
    final file = File(project.file('.cleany/settings.json'));
    if (!file.existsSync()) return const Duration(minutes: 5);
    try {
      final value = (jsonDecode(
        file.readAsStringSync(),
      ) as Map)['command_timeout_seconds'];
      if (value is int && value >= 5 && value <= 3600) {
        return Duration(seconds: value);
      }
    } on Object {
      /* Invalid preferences never block recovery. */
    }
    return const Duration(minutes: 5);
  }
}

/// Platform changes use the same staged validation and rollback as Dart sources.
GenerationPlan planPlatformFlavors(Project project, Set<String> platforms) {
  if (platforms.isEmpty ||
      !platforms.every({'android', 'ios', 'macos'}.contains)) {
    throw const GenerationException('Choose Android, iOS, or macOS.');
  }
  final file = File(project.file('flavorizr.yaml'));
  if (!file.existsSync()) {
    throw const GenerationException(
      'Initialize the flavor configuration first.',
    );
  }
  for (final platform in platforms) {
    if (!Directory(project.file(platform)).existsSync()) {
      throw GenerationException('Platform directory is missing: $platform');
    }
  }
  final yaml = loadYaml(file.readAsStringSync()) as YamlMap;
  final editor = YamlEditor(file.readAsStringSync());
  final instructions = (yaml['instructions'] as List)
      .cast<String>()
      .where((instruction) => platforms.contains(instruction.split(':').first))
      .toList();
  for (final platform in platforms) {
    if (!instructions.any((item) => item.startsWith('$platform:'))) {
      throw GenerationException(
        'No $platform processors are configured in flavorizr.yaml. Use Project doctor or update its platform configuration.',
      );
    }
  }
  editor.update(['instructions'], instructions);
  for (final entry in (yaml['flavors'] as YamlMap).entries) {
    for (final platform in ['android', 'ios', 'macos']) {
      if (!platforms.contains(platform) &&
          (entry.value as Map).containsKey(platform)) {
        editor.remove(['flavors', entry.key, platform]);
      }
    }
  }
  return GenerationPlan(project)
    ..platformRoots.addAll(platforms)
    ..stageOverrides['flavorizr.yaml'] = editor.toString()
    ..commands.add(
      const PlannedCommand('dart', ['run', 'flutter_flavorizr', '--force']),
    );
}
