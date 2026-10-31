import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'project.dart';

Map<String, Map<String, Object>> packageRequirements(ApiProvider provider) => {
  'dependencies': {
    'flutter_localizations': {'sdk': 'flutter'},
    'intl': 'any',
    'flutter_bloc': '^9.1.1',
    'get_it': '^9.2.1',
    'go_router': '^18.0.0',
    'multiple_result': '^5.3.0',
    'dio': '^5.11.0',
    'freezed_annotation': '^3.1.0',
    'json_annotation': '^4.12.0',
    'yaml': '^3.1.3',
    if (provider == ApiProvider.retrofit) 'retrofit': '^4.10.0',
  },
  'dev_dependencies': {
    'build_runner': '^2.15.1',
    'freezed': '^4.0.3',
    'json_serializable': '^6.14.1',
    'flutter_flavorizr': '^2.6.0',
    'flutter_lints': '^6.0.0',
    if (provider == ApiProvider.retrofit) 'retrofit_generator': '^10.3.2',
  },
};

/// Applies the same runtime manifest policy for init, repair, and reset.
/// Existing custom dependencies, asset maps, fonts, and comments are retained.
String configurePubspec(
  String source,
  ApiProvider provider, {
  bool repairConstraints = false,
  void Function(String message)? onRepair,
}) {
  final original = loadYaml(source) as YamlMap;
  final editor = YamlEditor(source);
  for (final section in packageRequirements(provider).entries) {
    if (original[section.key] != null && original[section.key] is! Map) {
      throw GenerationException('Expected a mapping for ${section.key}.');
    }
    if (original[section.key] == null) {
      editor.update([section.key], <String, Object>{});
    }
    for (final dependency in section.value.entries) {
      final current = (original[section.key] as Map?)?[dependency.key];
      if (current == null &&
          section.key == 'dependencies' &&
          (original['dev_dependencies'] as Map?)?.containsKey(dependency.key) ==
              true) {
        throw GenerationException(
          'Move ${dependency.key} from dev_dependencies to dependencies.',
        );
      }
      if (current == null &&
          section.key == 'dev_dependencies' &&
          (original['dependencies'] as Map?)?.containsKey(dependency.key) ==
              true) {
        continue;
      }
      var replace = current == null;
      Object replacement = dependency.value;
      if (repairConstraints && dependency.value is Map) {
        replace =
            current is! Map ||
            current['sdk'] != (dependency.value as Map)['sdk'];
      } else if (repairConstraints &&
          current is String &&
          dependency.value is String) {
        try {
          final declared = VersionConstraint.parse(current);
          final supported = declared.intersect(
            VersionConstraint.parse(dependency.value as String),
          );
          replace = supported.isEmpty || supported != declared;
          if (!supported.isEmpty) replacement = supported.toString();
        } on FormatException {
          throw GenerationException(
            'Invalid dependency constraint for ${dependency.key}: $current',
          );
        }
      }
      if (replace) {
        editor.update([section.key, dependency.key], replacement);
        onRepair?.call('Set ${dependency.key} to $replacement.');
      }
    }
  }
  final flutter = original['flutter'];
  if (flutter != null && flutter is! Map) {
    throw const GenerationException('Expected a flutter mapping.');
  }
  if (flutter == null) editor.update(['flutter'], <String, Object>{});
  editor.update(['flutter', 'generate'], true);
  final existing = (flutter as Map?)?['assets'];
  if (existing != null && existing is! List) {
    throw const GenerationException('Expected a flutter assets list.');
  }
  final assets = <Object?>[...?existing as List?];
  for (final path in [
    'assets/images/',
    'assets/icons/',
    'assets/translations/',
    'config/flavors/',
  ]) {
    if (!assets.any(
      (entry) => (entry is Map ? entry['path'] : entry) == path,
    )) {
      assets.add(path);
    }
  }
  editor.update(['flutter', 'assets'], assets);
  return editor.toString();
}
