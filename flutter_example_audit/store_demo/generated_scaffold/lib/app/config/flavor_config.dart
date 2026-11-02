// Defines and validates public application environment configuration.
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

import 'app_environment.dart';

/// Defines and validates public application environment configuration.
class FlavorConfig {
  const FlavorConfig(this.environment, this.apiBaseUrl);
  final AppEnvironment environment;
  final String apiBaseUrl;
  String get label => environment.name;
  bool get isProduction => environment == AppEnvironment.prod;

  static Future<FlavorConfig> load(AppEnvironment environment) async {
    final content = await rootBundle.loadString(
      'config/flavors/${environment.name}.yaml',
    );
    final yaml = loadYaml(content);
    if (yaml is! YamlMap ||
        yaml['environment'] != environment.name ||
        yaml['api_base_url'] is! String) {
      throw StateError('Invalid public flavor configuration.');
    }
    return FlavorConfig(environment, yaml['api_base_url'] as String);
  }
}
