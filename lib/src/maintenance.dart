import 'dart:convert';
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'dependencies.dart';
import 'environment_config.dart';
import 'project.dart';
import 'project_lock.dart';
import 'registry.dart';
import 'run_configuration.dart';
import 'specification.dart';
import 'templates/core_templates.dart';
import 'templates/documentation.dart';
import 'transaction.dart';
import 'workspace.dart';
import 'validation_cache.dart';
import 'config_value_spec.dart';

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
        final validation = ValidationCache.metadata(entry);
        if ((marker.existsSync() &&
                marker.readAsStringSync() == project.root) ||
            (validation?['project'] == project.root &&
                validation?['version'] == 1)) {
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
    final configValues = registryConfigValues(registry);
    final fresh = coreTemplates(
      package,
      provider,
      id,
      configValues: configValues,
    );
    // Reset code, not a user's environment choices or DB key selection.
    for (final environment in ['dev', 'uat', 'prod']) {
      final path = 'config/flavors/$environment.yaml';
      final file = File(project.file(path));
      if (!file.existsSync()) continue;
      Object? old;
      try {
        old = loadYaml(file.readAsStringSync());
      } on YamlException {
        // The original is archived below; reset can recover malformed YAML.
      }
      if (old is Map && old['environment'] == environment) {
        final restored = YamlEditor(fresh[path]!);
        for (final key in [
          'api_base_url',
          'db_secret_key',
          ...configValues.map((value) => value.yamlKey),
        ]) {
          if (old[key] is String) restored.update([key], old[key]);
        }
        fresh[path] = restored.toString();
      }
    }
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
      // Existing manifest/analysis/entrypoint modifications remain user-owned.
      final preserve =
          StagedWorkspace.nativePlatforms.contains(p.posix.split(path).first) ||
          path == 'pubspec.yaml' ||
          path == 'analysis_options.yaml' ||
          path == 'lib/main.dart' ||
          path == launchConfigurationPath ||
          path == runningGuidePath ||
          path == '.gitignore';
      plan.archive(path, '$backup/$path', remove: !preserve);
    }
    final formatter = DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    );
    final owned = <Map<String, dynamic>>[
      for (final record in projectFiles)
        if (StagedWorkspace.nativePlatforms.contains(
              p.posix.split(record['path'] as String).first,
            ) ||
            {
              launchConfigurationPath,
              runningGuidePath,
              'lib/main.dart',
            }.contains(record['path']))
          record,
    ];
    for (final entry in fresh.entries) {
      final content = entry.key.endsWith('.dart')
          ? formatter.format(documentGeneratedDart(entry.key, entry.value))
          : entry.value;
      plan.write(entry.key, content);
      owned.add(
        Map<String, dynamic>.from(
          artifactRecord(entry.key, utf8.encode(content), '@project'),
        ),
      );
    }
    planRunConfiguration(project, plan);
    recordRunConfigurationOwnership(plan, owned);
    // Preserve dependencies added by the user; add only missing template needs.
    plan.write(
      'pubspec.yaml',
      configurePubspec(project.read('pubspec.yaml'), provider),
    );
    plan.write(
      registryPath,
      prettyJson({
        'version': registryVersion,
        'template_version': templateVersion,
        'api_provider': provider.name,
        'app_config_values': configValues
            .map((value) => value.toJson())
            .toList(),
        'local_storage': true,
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
  if (yaml['instructions'] is! List || yaml['flavors'] is! Map) {
    throw const GenerationException(
      'flavorizr.yaml requires instructions and flavors mappings.',
    );
  }
  for (final environment in ['dev', 'uat', 'prod']) {
    final flavor = (yaml['flavors'] as Map)[environment];
    if (flavor is! Map ||
        flavor['app'] is! Map ||
        (flavor['app'] as Map)['name'] is! String) {
      throw GenerationException(
        'Complete the $environment app name in flavorizr.yaml before configuring platforms.',
      );
    }
    for (final platform in platforms) {
      final settings = flavor[platform];
      final id = settings is Map
          ? settings[platform == 'android' ? 'applicationId' : 'bundleId']
          : null;
      if (id is! String || !isValidAppId(id)) {
        throw GenerationException(
          'Complete the $environment/$platform application identifier in flavorizr.yaml.',
        );
      }
    }
    final configPath = 'config/flavors/$environment.yaml';
    if (!File(project.file(configPath)).existsSync()) {
      throw GenerationException(
        'Missing $configPath. Run Project doctor first.',
      );
    }
    validatePublicFlavor(project.read(configPath), environment, configPath);
  }
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
    for (final platform in platforms.intersection({'ios', 'macos'})) {
      final settings = (entry.value as Map)[platform] as Map;
      final buildSettings = settings['buildSettings'];
      if (settings['icon'] == null &&
          (buildSettings is! Map ||
              !buildSettings.containsKey(
                'ASSETCATALOG_COMPILER_APPICON_NAME',
              )) &&
          Directory(
            project.file('$platform/Runner/Assets.xcassets/AppIcon.appiconset'),
          ).existsSync()) {
        if (buildSettings == null) {
          editor.update([
            'flavors',
            entry.key,
            platform,
            'buildSettings',
          ], <String, Object>{});
        }
        // Flavorizr otherwise references AppIcon-dev/uat/prod without creating
        // those catalogs when asset processors are intentionally excluded.
        // Preserve explicit custom icons and reuse the project's real default.
        editor.update([
          'flavors',
          entry.key,
          platform,
          'buildSettings',
          'ASSETCATALOG_COMPILER_APPICON_NAME',
        ], 'AppIcon');
      }
    }
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
