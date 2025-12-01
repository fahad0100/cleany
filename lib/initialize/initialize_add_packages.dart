import 'dart:io';

Future<void> initializeAddPackages() async {
  print('📦 Adding packages in batch...');
  await Future.wait([
    _addPackagesBatch(corePackages, isDev: false),
    _addPackagesBatch(devPackages, isDev: true),
  ]);

  final outdated = await Process.run('flutter', ['pub', 'outdated']);
  final upgrade = await Process.run('flutter', ['pub', 'upgrade']);
  final buildRunner = await Process.run('dart', [
    'run',
    'build_runner',
    'build',
  ]);
  print(outdated.stdout);
  print(upgrade.stdout);
  print(buildRunner.stdout);
}

//-------------------------method add packages ---------------------------------------

Future<void> _addPackagesBatch(
  List<String> packages, {
  required bool isDev,
}) async {
  try {
    final command = 'flutter';
    final args = isDev
        ? ['pub', 'add', '--dev', ...packages]
        : ['pub', 'add', ...packages];

    print('📦 Adding ${packages.length} packages in batch...');

    final result = await Process.run(command, args);

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
