import 'dart:io';

import 'package:cleany/utils/file_modifier.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

Future<void> initializeAddPackages({bool updatePackages = true}) async {
  print('📦 Adding packages...');
  await Future.wait([
    addDependenciesEfficiently(corePackages, isDev: false),
    addDependenciesEfficiently(devPackages, isDev: true),
  ]);

  if (updatePackages) {
    await FileModifier.runPubGet(showResult: false);
    await FileModifier.runPubUpgrade(showResult: false);
    await FileModifier.runPubOutdated(showResult: false);
    await FileModifier.runBuildRunner(showResult: false);
  }
}

//-------------------------method add packages ---------------------------------------

Future<void> _addPackagesBatch(
  List<String> packages, {
  required bool isDev,
}) async {
  try {
    final flutter = FileModifier.resolveExecutable("flutter");

    final args = ['pub', 'add', if (isDev) '--dev', ...packages];

    print(
      '📦 Adding ${packages.length} packages in ${isDev ? "dev_dependencies" : "dependencies"}...',
    );

    final result = await Process.run(flutter, args);

    if (result.exitCode == 0) {
      print('✅ Successfully added/updated all packages!');
      print(result.stdout);
    } else {
      print('❌ Failed to add packages: ${result.stderr}');
    }
  } catch (e) {
    print('⚠️ Error: $e');
  }
}

Future<void> addDependenciesEfficiently(
  List<String> deps, {
  required bool isDev,
}) async {
  final file = File('pubspec.yaml');
  final content = file.readAsStringSync();
  final editor = YamlEditor(content);
  final section = isDev ? 'dev_dependencies' : 'dependencies';

  final current = (loadYaml(content) as Map)[section] ?? {};

  for (final dep in deps) {
    editor.update([section, dep], 'any');
  }

  file.writeAsStringSync(editor.toString());
}

//------------------------- packages dependencies ------------------------------

const List<String> corePackages = [
  "flutter_dotenv",
  "multiple_result",
  "flutter_bloc",
  "bloc",
  "dart_mappable",
  "dio",
  "retrofit",
  "easy_localization",
  "flutter_secure_storage",
  "sizer",
  "supabase_flutter",
  "get_storage",
  "get_it",
  "go_router",
  "injectable",
  "equatable",
  "package_info_plus",
  "device_info_plus",
];
//------------------------- packages dev_dependencies --------------------------

const List<String> devPackages = [
  "flutter_lints",
  "build_runner",
  "dart_mappable_builder",
  "retrofit_generator",
  "injectable_generator",
];
