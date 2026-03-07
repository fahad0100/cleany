import 'dart:io';
import 'package:cleany/utils/logger.dart';

// We no longer need yaml_edit or yaml packages because Dart handles the process natively

Future<void> initializeAddPackages({bool updatePackages = true}) async {
  Logger.info('📦 Adding packages (resolving latest compatible versions)...');

  // Important Note: These must be executed sequentially, not with Future.wait.
  // Running two 'pub add' commands simultaneously will cause a File Lock error.
  await addDependenciesEfficiently(corePackages, isDev: false);
  await addDependenciesEfficiently(devPackages, isDev: true);

  // The 'pub add' command automatically runs 'pub get', so running it again might be optional.
  // However, it is kept here for finalization and safety if 'updatePackages' is true.
  if (updatePackages) {
    Logger.info("⏳ Finalizing and running pub get...");
    final result = await Process.run('dart', ['pub', 'get'], runInShell: true);

    if (result.exitCode != 0) {
      Logger.warning("⚠️ Warning during pub get:\n${result.stderr}");
    } else {
      Logger.success("✅ Packages finalized successfully.");
    }
  }
}

Future<void> addDependenciesEfficiently(
  List<String> packages, {
  required bool isDev,
}) async {
  if (packages.isEmpty) return;

  final sectionName = isDev ? 'dev_dependencies' : 'dependencies';

  final args = ['pub', 'add'];
  if (isDev) {
    args.add('--dev');
  }
  args.addAll(packages);

  Logger.info(
    "⚙️ Resolving and adding ${packages.length} packages to $sectionName...",
  );

  // Adding runInShell: true is the key to perfect Windows OS support
  final result = await Process.run('dart', args, runInShell: true);

  if (result.exitCode == 0) {
    Logger.success("✅ Successfully added packages to $sectionName");
  } else {
    throw Exception(
      "❌ Failed to add packages to $sectionName:\n${result.stderr}",
    );
  }
}

//------------------------- packages dependencies ------------------------------
// Converted to List of Strings since we don't need to specify versions (gets latest)
const List<String> corePackages = [
  "cupertino_icons",
  "flutter_dotenv",
  "multiple_result",
  "flutter_bloc",
  "bloc",
  "dart_mappable",
  "dio",
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
  "loading_animation_widget",
  "uuid",
];

//------------------------- packages dev_dependencies --------------------------
const List<String> devPackages = [
  "flutter_lints",
  "build_runner",
  "dart_mappable_builder",
  "injectable_generator",
];
