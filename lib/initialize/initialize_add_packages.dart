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

Future<void> addDependenciesEfficiently(
  List<String> deps, {
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

  // 1) إذا القسم غير موجود → أنشئه كـ Map {}
  if (!yaml.containsKey(section)) {
    editor.update([section], {});
  } else {
    // 2) إذا القسم موجود لكنه ليس Map → أجبره أن يكون Map {}
    final value = yaml[section];
    if (value == null || value is! Map) {
      editor.update([section], {});
    }
  }

  // تحديث الـ YAML بعد الإصلاح
  final updatedYaml = loadYaml(editor.toString()) as Map;
  final existingSection = updatedYaml[section] as Map;

  // 3) إضافة المكتبات داخل القسم
  for (final dep in deps) {
    if (!existingSection.containsKey(dep)) {
      editor.update([section, dep], 'any');
    }
  }

  file.writeAsStringSync(editor.toString());

  print("✅ Added ${deps.length} packages to $section");
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
