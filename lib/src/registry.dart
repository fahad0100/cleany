import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'project.dart';
import 'specification.dart';

/// Project-relative path of the versioned feature/component ownership registry.
const registryPath = '.cleany/features.json';
String prettyJson(Object value) =>
    '${const JsonEncoder.withIndent('  ').convert(value)}\n';
String contentDigest(List<int> bytes) => '${sha256.convert(bytes)}';
String artifactKind(String path) =>
    path.endsWith('.g.dart') ||
        path.endsWith('.freezed.dart') ||
        path.contains('/localization/generated/')
    ? 'generated'
    : path.contains('/models/')
    ? 'model'
    : path.contains('/entities/')
    ? 'entity'
    : path.contains('/retrofit/')
    ? 'api'
    : path.endsWith('.dart')
    ? 'source'
    : 'configuration';
Map<String, Object?> artifactRecord(
  String path,
  List<int> bytes,
  String owner, {
  String origin = 'template',
}) => {
  'path': path,
  'owner': owner,
  'kind': artifactKind(path),
  'sha256': contentDigest(bytes),
  'origin': origin,
};

/// Versioned ownership is authoritative for files outside an entry's directory.
class FeatureRegistry {
  FeatureRegistry(this.project);
  final Project project;
  Map<String, dynamic> read({bool strict = true}) {
    if (!File(project.file(registryPath)).existsSync()) {
      throw const GenerationException(
        'The registry is missing. Initialize the project or use Project doctor to rebuild it.',
      );
    }
    try {
      final data =
          jsonDecode(project.read(registryPath)) as Map<String, dynamic>;
      if (![1, registryVersion].contains(data['version']) ||
          data['features'] is! List ||
          !ApiProvider.values.any((p) => p.name == data['api_provider'])) {
        throw const FormatException();
      }
      final names = <String>{};
      final paths = <String>{};
      for (final raw in data['features'] as List) {
        final record = raw as Map<String, dynamic>;
        validateName(record['name'] as String);
        final path = record['path'] as String;
        project.file(path);
        if (!p.posix.isWithin('lib', path) ||
            p.posix.normalize(path) != path ||
            p.posix.basename(path) != record['name'] ||
            !names.add(pascalCase(record['name'] as String)) ||
            !paths.add(path) ||
            !GenerationKind.values.any((k) => k.name == record['kind']) ||
            !StateManagement.values.any((s) => s.name == record['state']) ||
            (record['kind'] == 'feature' && record['state'] == 'none')) {
          throw const FormatException();
        }
        if (strict && !Directory(project.file(path)).existsSync()) {
          throw GenerationException(
            'Missing entry directory: $path. Use Project doctor to repair the registry.',
          );
        }
        if (record.containsKey('component_layout') &&
            (record['kind'] != 'component' ||
                !{'flat', 'widgets'}.contains(record['component_layout']))) {
          throw const FormatException('Invalid component layout.');
        }
        final owned = record['files'] as List? ?? [];
        for (final file in owned) {
          final target = file['path'] as String;
          project.file(target);
          if (file['owner'] != record['name'] ||
              !p.posix.isWithin('lib', target)) {
            throw const FormatException();
          }
          final allowedApi =
              record['kind'] == 'feature' &&
              data['api_provider'] == 'retrofit' &&
              {
                'lib/core/network/retrofit/${record['name']}_api.dart',
                'lib/core/network/retrofit/${record['name']}_api.g.dart',
              }.contains(target);
          if (!p.posix.isWithin(path, target) && !allowedApi) {
            throw const FormatException();
          }
        }
        final operations = entryUseCases(record);
        final operationNames = <String>{};
        if (record['kind'] != 'feature' && operations.isNotEmpty) {
          throw const FormatException(
            'Components cannot own feature use cases.',
          );
        }
        for (final operation in operations) {
          if (!operationNames.add(operation.type)) {
            throw const FormatException('Duplicate use case.');
          }
        }
        final member = camelCase(record['name'] as String);
        final type = pascalCase(record['name'] as String);
        final integrationPaths = {
          'lib/app/di/injection.dart': {
            'DI.${type}Api',
            'DI.${type}RemoteDataSource',
            'DI.${type}Repository',
            'DI.Get$type',
            'DI.${type}Cubit',
            'DI.${type}Bloc',
            for (final operation in operations) ...[
              'DI.${operation.type}',
              if (!operation.usesFeatureRepository)
                'DI.${operation.repository}',
            ],
          },
          'lib/app/composition/feature_pages.dart': {'FeaturePages.$member'},
          'lib/app/router/route_names.dart': {'RouteNames.$member'},
          'lib/app/router/app_router.dart': {'Router.$member'},
        };
        for (final raw in record['integrations'] as List? ?? []) {
          final node = raw as Map;
          if (node['owner'] != record['name'] ||
              integrationPaths[node['path']]?.contains(node['node']) != true ||
              node['sha256'] is! String ||
              !RegExp(r'^[a-f0-9]{64}$').hasMatch(node['sha256'] as String)) {
            throw const FormatException('Invalid integration ownership');
          }
        }
        record['files'] ??= <Object>[];
        record['template_version'] ??= 'legacy';
      }
      data['version'] = registryVersion;
      data['template_version'] ??= 'legacy';
      data['project_files'] ??= <Object>[];
      final projectPaths = <String>{};
      for (final raw in data['project_files'] as List) {
        final record = raw as Map;
        final path = record['path'] as String;
        project.file(path);
        final allowed =
            p.posix.isWithin('lib/app', path) ||
            p.posix.isWithin('lib/core', path) ||
            p.posix.isWithin('config/flavors', path) ||
            p.posix.isWithin('assets/translations', path) ||
            {
              'android',
              'ios',
              'macos',
              'windows',
              'linux',
              'web',
            }.any((root) => p.posix.isWithin(root, path)) ||
            {
              '.vscode/launch.json',
              'CLEANY_RUN.md',
              'lib/main.dart',
              'lib/main_dev.dart',
              'lib/main_uat.dart',
              'lib/main_prod.dart',
              'assets/images/.gitkeep',
              'assets/icons/.gitkeep',
              'test/.gitkeep',
              'integration_test/.gitkeep',
              'pubspec.yaml',
              'analysis_options.yaml',
              'flavorizr.yaml',
              'l10n.yaml',
              '.gitignore',
            }.contains(path);
        if (!allowed ||
            p.posix.normalize(path) != path ||
            record['owner'] != '@project' ||
            !projectPaths.add(path)) {
          throw const FormatException('Invalid project ownership');
        }
      }
      return data;
    } on GenerationException {
      rethrow;
    } on Object {
      throw const GenerationException(
        'Invalid registry. Project doctor can inspect folders and propose a repaired registry.',
      );
    }
  }
}
