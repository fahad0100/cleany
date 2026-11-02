import 'project.dart';
import 'specification.dart';

/// Metadata contains names only. Environment values stay in flavor YAML files.
class AppConfigValueSpec {
  /// Validates an UPPER_SNAKE_CASE key and its corresponding Dart field name.
  ///
  /// Built-in configuration members, including isDebug, are reserved.
  AppConfigValueSpec(this.key) {
    if (!RegExp(r'^[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)*$').hasMatch(key) ||
        key.length > 80) {
      throw const GenerationException(
        'Use an UPPER_SNAKE_CASE key, starting with a letter (max 80).',
      );
    }
    FieldSpec(field, 'string');
    if ({
      'environment',
      'apiBaseUrl',
      'dbSecretKey',
      'isDebug',
      'fromEnvironment',
      'hashCode',
      'runtimeType',
      'toString',
      'noSuchMethod',
    }.contains(field)) {
      throw const GenerationException(
        'This key belongs to built-in AppConfig configuration.',
      );
    }
  }

  /// Exact case-sensitive name used by String.fromEnvironment.
  final String key;

  /// Matching lower_snake_case property in each flavor YAML file.
  String get yamlKey => key.toLowerCase();

  /// Matching lowerCamelCase String property in the generated AppConfig.
  String get field => camelCase(yamlKey);

  /// Serializes names only; environment values are never registry metadata.
  Map<String, Object> toJson() => {'key': key};
}

/// Reads validated configuration names from a registry, rejecting duplicates.
List<AppConfigValueSpec> registryConfigValues(Map registry) {
  final specs = <AppConfigValueSpec>[];
  final names = <String>{};
  for (final raw in registry['app_config_values'] as List? ?? []) {
    final spec = AppConfigValueSpec((raw as Map)['key'] as String);
    if (!names.add(spec.field)) {
      throw const GenerationException(
        'Duplicate AppConfig field in the registry.',
      );
    }
    specs.add(spec);
  }
  return specs;
}
