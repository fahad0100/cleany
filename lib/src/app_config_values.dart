import 'dart:convert';

import 'package:dart_style/dart_style.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'app_config_editor.dart';
import 'config_value_spec.dart';
import 'project.dart';
import 'registry.dart';
import 'transaction.dart';

/// App configuration changes share the normal review, validation and rollback.
class AppConfigValues {
  /// Prepares configuration edits for an initialized Flutter [project].
  AppConfigValues(this.project);

  /// Workspace whose existing configuration and registry are preserved.
  final Project project;

  /// Validates an unused public key and supported files without writing changes.
  ///
  /// Throws [GenerationException] for reserved/duplicate keys or unsupported
  /// configuration structures before collecting environment values.
  AppConfigValueSpec validateNewKey(String key) {
    final spec = AppConfigValueSpec(key);
    final registry = FeatureRegistry(project).read();
    if (registryConfigValues(registry)
        .any((value) => value.field == spec.field)) {
      throw GenerationException('AppConfig already contains ${spec.key}.');
    }
    // Preflight custom constructor/factory shapes before asking for values.
    final source = project.read(appConfigPath);
    if (configEnvironmentKeys(source).contains(spec.key)) {
      throw GenerationException('AppConfig already reads ${spec.key}.');
    }
    addAppConfigField(source, spec);
    for (final environment in ['dev', 'uat', 'prod']) {
      final path = 'config/flavors/$environment.yaml';
      final yaml = loadYaml(project.read(path));
      if (yaml is! Map ||
          yaml['environment'] != environment ||
          yaml.containsKey(spec.yamlKey)) {
        throw GenerationException(
          'Invalid flavor file or existing key in $path.',
        );
      }
    }
    return spec;
  }

  /// Plans a typed field, YAML values and registry metadata as one operation.
  ///
  /// [values] must contain exactly dev, uat and prod String entries. Values stay
  /// in flavor YAML; the registry stores only key names. Apply the returned plan
  /// through [GenerationTransaction] to validate it and retain rollback support.
  GenerationPlan add({
    required String key,
    required Map<String, String> values,
  }) {
    project.validate();
    final spec = validateNewKey(key);
    if (values.length != 3 ||
        !values.keys.toSet().containsAll({'dev', 'uat', 'prod'})) {
      throw const GenerationException(
        'Provide exactly one String value for dev, uat and prod.',
      );
    }
    final plan = GenerationPlan(project);
    final formatter = DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    );
    plan.write(
      appConfigPath,
      formatter.format(addAppConfigField(project.read(appConfigPath), spec)),
    );
    for (final environment in ['dev', 'uat', 'prod']) {
      final path = 'config/flavors/$environment.yaml';
      final editor = YamlEditor(project.read(path))
        ..update([spec.yamlKey], values[environment]);
      plan.write(path, editor.toString());
    }
    planConfigValueInputs(plan);
    for (final path in [
      'lib/app/bootstrap.dart',
      'lib/app/config/flavor_config.dart',
    ]) {
      if (plan.files.containsKey(path)) {
        plan.write(path, formatter.format(plan.read(path)));
      }
    }
    final registry = FeatureRegistry(project).read();
    registry['app_config_values'] = [
      ...registryConfigValues(registry).map((value) => value.toJson()),
      spec.toJson(),
    ];
    final owned = registry['project_files'] as List;
    for (final entry in plan.files.entries) {
      owned.removeWhere((record) => record['path'] == entry.key);
      owned.add(
        artifactRecord(
          entry.key,
          entry.value.after!,
          '@project',
          origin: 'app_config',
        ),
      );
    }
    plan.write(
      registryPath,
      '${const JsonEncoder.withIndent('  ').convert(registry)}\n',
    );
    return plan;
  }
}
