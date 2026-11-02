import '../project.dart';
import 'app_templates.dart';
import 'network_templates.dart';
import 'localization_templates.dart';
import 'use_case_templates.dart';
import 'theme_templates.dart';
import 'storage_templates.dart';
import '../config_value_spec.dart';

Map<String, String> coreTemplates(
  String package,
  ApiProvider provider,
  String appId, {
  bool includeUseCaseState = true,
  List<AppConfigValueSpec> configValues = const [],
  bool includeLocalStorage = true,
}) {
  final files = <String, String>{
    ...appTemplates(
      configValues: configValues,
      includeLocalStorage: includeLocalStorage,
    ),
    ...networkTemplates(),
    ...localizationTemplates(),
    ...themeTemplates(),
    if (includeLocalStorage) ...storageTemplates(),
    if (includeUseCaseState) useCaseStatePath: useCaseStateTemplate(),
    'lib/app/config/flavor_config.dart': r'''
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import 'app_environment.dart';

class FlavorConfig {
  const FlavorConfig(this.environment, this.apiBaseUrl, {this.values = const {}});
  final AppEnvironment environment;
  final String apiBaseUrl;
  final Map<String, Object?> values;
  String get label => environment.name;
  bool get isProduction => environment == AppEnvironment.prod;

  static Future<FlavorConfig> load(AppEnvironment environment) async {
    final content = await rootBundle.loadString('config/flavors/${environment.name}.yaml');
    final yaml = loadYaml(content);
    if (yaml is! YamlMap || yaml['environment'] != environment.name ||
        yaml['api_base_url'] is! String) {
      throw StateError('Invalid public flavor configuration.');
    }
    return FlavorConfig(environment, yaml['api_base_url'] as String,
      values: Map<String, Object?>.unmodifiable(Map<String, Object?>.from(yaml)));
  }
}
''',
    'lib/core/widgets/loading_widget.dart': '''
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}
''',
    'assets/images/.gitkeep': '',
    'assets/icons/.gitkeep': '',
    'test/.gitkeep': '',
    'integration_test/.gitkeep': '',
  };
  for (final folder in ['localization', 'constants', 'utils']) {
    files['lib/core/$folder/.gitkeep'] = '';
  }
  if (provider == ApiProvider.retrofit) {
    files['lib/core/network/retrofit/.gitkeep'] = '';
  }
  for (final environment in ['dev', 'uat', 'prod']) {
    files['lib/main_$environment.dart'] =
        '''
import 'app/bootstrap.dart';
import 'app/config/app_environment.dart';

Future<void> main() => bootstrap(AppEnvironment.$environment);
''';
    files['config/flavors/$environment.yaml'] =
        '''
# Public configuration only. Never commit encryption key material here.
# Change this public scaffold password before release; auto selects a vault key.
environment: $environment
api_base_url: ""
db_secret_key: "pass_key_storage"
${configValues.map((value) => '${value.yamlKey}: ""').join('\n')}
''';
  }
  files['flavorizr.yaml'] =
      '''
# Only platform processors: preserve Cleany's app and entrypoints.
instructions:
  - android:flavorizrGradle
  - android:buildGradle
  - android:androidManifest
  - ios:xcconfig
  - ios:buildTargets
  - ios:schema
  - ios:plist
  - macos:xcconfig
  - macos:configs
  - macos:buildTargets
  - macos:schema
  - macos:plist
flavors:
  dev:
    app:
      name: "$package Dev"
    android:
      applicationId: "$appId.dev"
    ios:
      bundleId: "$appId.dev"
    macos:
      bundleId: "$appId.dev"
  uat:
    app:
      name: "$package UAT"
    android:
      applicationId: "$appId.uat"
    ios:
      bundleId: "$appId.uat"
    macos:
      bundleId: "$appId.uat"
  prod:
    app:
      name: "$package"
    android:
      applicationId: "$appId"
    ios:
      bundleId: "$appId"
    macos:
      bundleId: "$appId"
''';
  return files;
}
