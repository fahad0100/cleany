import 'dart:io';

import 'package:cleany/get_content/content/ar_json_content.dart';
import 'package:cleany/get_content/content/en_json_content.dart';
import 'package:cleany/utils/logger.dart';
import 'package:cleany/utils/file_modifier.dart';
import 'package:cleany/generate/generate_core_base.dart';
import 'package:cleany/get_content/content/main_content.dart';
import 'package:cleany/initialize/initialize_add_packages.dart';
import 'package:path/path.dart' as path;

Future<void> initializeFoldersCore() async {
  final currentPath = path.join(Directory.current.path, 'lib/core');

  // 1. Check if core folder already exists
  final coreExists = await FileModifier.checkFolderExistenceAsync(
    folderPath: currentPath,
  );

  // Early exit to avoid deep nesting
  if (coreExists) {
    Logger.error("❌ Cannot create core folder: 'lib/core' already exists.");
    return;
  }

  try {
    Logger.info("🔄 Recreating pubspec.yaml...");
    await FileModifier.recreatePubspec();

    Logger.info("📂 Generating folders, files, and adding packages...");
    // 2. Run independent tasks concurrently for better performance
    await Future.wait([
      generateCoreBase(),
      initializeAddPackages(updatePackages: false),
      FileModifier.replaceFileContent(
        filePath: 'lib/main.dart',
        newContent: mainContent(),
      ),
      FileModifier.setupEnvFile(),
      FileModifier.replaceFileContent(
        filePath: 'assets/translations/ar.json',
        newContent: arJsonContent(),
        createIfNotExists: true,
      ),
      FileModifier.replaceFileContent(
        filePath: 'assets/translations/en.json',
        newContent: enJsonContent(),
        createIfNotExists: true,
      ),
      FileModifier.createFolder('assets/icons/'),
      FileModifier.createFolder('assets/images/'),
    ]);

    // 3. Add assets to pubspec sequentially to avoid file write race conditions
    Logger.info("⚙️ Updating pubspec.yaml assets...");
    await FileModifier.addAssetToPubspec('.env');
    await FileModifier.addAssetToPubspec('assets/translations/');
    await FileModifier.addAssetToPubspec('assets/images/');
    await FileModifier.addAssetToPubspec('assets/icons/');

    // 4. Run CLI commands
    Logger.info("⏳ Running pub get...");
    await FileModifier.runPubGet(showResult: false);
    Logger.success("✅ Pub get completed.");

    // Fixed: Calling runBuildRunner instead of runPubUpgrade to match the logs
    Logger.info("⏳ Running Build Runner...");
    await FileModifier.runBuildRunner(showResult: false);
    Logger.success("✅ Build Runner completed.\n");

    // 5. Print success summary cleanly
    Logger.warning(
      "--------------------------------------------------------------",
    );
    Logger.success("✨ Core initialization completed successfully:");
    Logger.success("  *- Core folder created");
    Logger.success("  *- Main file updated");
    Logger.success(
      "  *- Assets (icons, images, translations) created and linked",
    );
    Logger.success("  *- Pubspec.yaml updated with packages and assets");
    Logger.warning(
      "--------------------------------------------------------------",
    );
  } catch (error) {
    // Log the error before rethrowing so the user knows exactly what failed
    Logger.error("❌ An error occurred during initialization: $error");
    rethrow;
  }
}
