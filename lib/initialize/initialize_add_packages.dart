import 'dart:io';

import 'package:cleany/utils/file_modifier.dart';
import 'package:cleany/utils/logger.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

Future<void> initializeAddPackages({bool updatePackages = true}) async {
  print('📦 Adding packages...');
  await Future.wait([
    addDependenciesEfficiently(corePackages, isDev: false),
    addDependenciesEfficiently(devPackages, isDev: true),
  ]);

  if (updatePackages) {
    Logger.info("Waiting ....");
    await FileModifier.runPubGet(showResult: false);
    // await FileModifier.runPubUpgrade(showResult: false);
    // await FileModifier.runPubOutdated(showResult: false);
  }
}

Future<void> addDependenciesEfficiently(
  List<Map<String, dynamic>> deps, {
  required bool isDev,
}) async {
  final file = File('pubspec.yaml');

  if (!file.existsSync()) {
    throw Exception("❌ pubspec.yaml not found");
  }

  final content = file.readAsStringSync();
  final yaml = loadYaml(content) as Map;
  final editor = YamlEditor(content);

  final section = isDev ? 'dev_dependencies' : 'dependencies';

  if (!yaml.containsKey(section)) {
    editor.update([section], {});
  } else {
    final value = yaml[section];
    if (value == null || value is! Map) {
      editor.update([section], {});
    }
  }

  final updatedYaml = loadYaml(editor.toString()) as Map;
  final existingSection = updatedYaml[section] as Map;

  for (final dep in deps) {
    final name = dep['name'] as String;
    final version = dep['version'] as String;
    if (!existingSection.containsKey(name)) {
      editor.update([section, name], version);
    }
  }

  String updatedContent = editor.toString();

  updatedContent = updatedContent.replaceAllMapped(
    RegExp('$section:\\s*\\{([^}]*)\\}'),
    (match) {
      final entries = match[1]!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .join('\n  ');
      return '$section:\n  $entries';
    },
  );

  file.writeAsStringSync(updatedContent);

  print("✅ Added ${deps.length} packages to $section");
}

//------------------------- packages dependencies ------------------------------

const List<Map<String, dynamic>> corePackages = [
  {"name": "cupertino_icons", "version": '^1.0.8'},
  {"name": "flutter_dotenv", "version": '^6.0.0'},
  {"name": "multiple_result", "version": '^5.2.0'},
  {"name": "flutter_bloc", "version": '^9.1.1'},
  {"name": "bloc", "version": '^9.1.0'},
  {"name": "dart_mappable", "version": '^4.6.1'},
  {"name": "dio", "version": '^5.9.0'},
  {"name": "retrofit", "version": '^4.9.1'},
  {"name": "easy_localization", "version": '^3.0.8'},
  {"name": "flutter_secure_storage", "version": '^9.2.4'},
  {"name": "sizer", "version": '^3.1.3'},
  {"name": "supabase_flutter", "version": '^2.10.3'},
  {"name": "get_storage", "version": '^2.1.1'},
  {"name": "get_it", "version": '^9.1.1'},
  {"name": "go_router", "version": '^17.0.0'},
  {"name": "injectable", "version": '^2.7.0'},
  {"name": "equatable", "version": '^2.0.7'},
  {"name": "package_info_plus", "version": '^9.0.0'},
  {"name": "device_info_plus", "version": '^12.3.0'},
];
//------------------------- packages dev_dependencies --------------------------

const List<Map<String, dynamic>> devPackages = [
  {"name": "flutter_lints", "version": '^6.0.0'},

  {"name": "build_runner", "version": '^2.10.4'},

  {"name": "dart_mappable_builder", "version": '^4.6.1'},

  {"name": "retrofit_generator", "version": '^10.2.0'},

  {"name": "injectable_generator", "version": '^2.9.1'},
];
