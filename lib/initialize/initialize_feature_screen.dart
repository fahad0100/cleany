import 'dart:io';

import 'package:cleany/utils/file_modifier.dart';
import 'package:cleany/generate/generate_feature_screen_structure.dart';
import 'package:cleany/utils/logger.dart';

Future<void> initializeFeatureScreen({
  required String featureName,
  String? basePath,
}) async {
  Logger.info("🚀 Starting to create '$featureName' screen feature...");

  // 1. Verify required core structure exists
  final coreExists = await FileModifier.checkFolderExistenceAsync(
    folderPath: 'lib/core',
  );
  if (!coreExists) {
    Logger.error("❌ Cannot create feature: 'lib/core' folder is missing.");
    return; // Stop execution if core doesn't exist
  }

  final diFileExists = await FileModifier.checkFileExistenceAsync(
    filePath: 'lib/core/di/configure_dependencies.dart',
  );
  if (!diFileExists) {
    Logger.error(
      "❌ Cannot create feature: 'configure_dependencies.dart' is missing in 'lib/core/di/'.",
    );
    return; // Stop execution
  }

  final appRouterExists = await FileModifier.checkFileExistenceAsync(
    filePath: 'lib/core/navigation/app_router.dart',
  );
  if (!appRouterExists) {
    Logger.error(
      "❌ Cannot create feature: 'app_router.dart' is missing in 'lib/core/navigation/'.",
    );
    return; // Stop execution
  }

  final routersExists = await FileModifier.checkFileExistenceAsync(
    filePath: 'lib/core/navigation/routers.dart',
  );
  if (!routersExists) {
    Logger.error(
      "❌ Cannot create feature: 'routers.dart' is missing in 'lib/core/navigation/'.",
    );
    return; // Stop execution
  }

  // 2. Comprehensive check: Prevent feature name conflicts
  final existingPath = _findExistingFeaturePath(featureName);
  if (existingPath != null) {
    Logger.error(
      "❌ Conflict Detected: The feature '$featureName' already exists at:\n"
      "📁 $existingPath\n"
      "Please choose a different name to avoid import conflicts.",
    );
    return; // Stop execution to protect the project structure
  }

  try {
    // 3. Generate feature structure
    Logger.info("📂 Generating screen feature structure...");
    await generateFeatureScreenStructure(
      featureName,
      basePath ?? 'lib/features',
    );

    // 4. Run build_runner (Fixed to match the log)
    Logger.info("⏳ Running build_runner...");
    await FileModifier.runBuildRunner(showResult: false);
    Logger.success("✅ build_runner completed successfully.\n");

    // 5. Success summary
    Logger.warning(
      "--------------------------------------------------------------",
    );
    Logger.success("✨ Screen Feature '$featureName' created successfully");
    Logger.warning(
      "--------------------------------------------------------------",
    );
  } catch (e) {
    Logger.error("❌ Failed to create screen feature '$featureName': $e");
  }
}

/// Helper function to search for the feature in all potential paths
String? _findExistingFeaturePath(String featureName) {
  final baseDir = Directory('lib/features');

  // If the features directory doesn't exist at all, there's no conflict
  if (!baseDir.existsSync()) return null;

  // a. Check in the main directory (lib/features/featureName)
  final mainPath = 'lib/features/$featureName';
  if (Directory(mainPath).existsSync()) return mainPath;

  // b. Check in the general sub-directory (lib/features/sub/featureName)
  final generalSubPath = 'lib/features/sub/$featureName';
  if (Directory(generalSubPath).existsSync()) return generalSubPath;

  // c. Dynamic check inside the sub directories of any parent feature (lib/features/*/sub/featureName)
  for (var entity in baseDir.listSync(recursive: false)) {
    if (entity is Directory) {
      // Extract folder name safely supporting both Windows and Mac
      final folderName = entity.uri.pathSegments
          .where((e) => e.isNotEmpty)
          .last;

      // Skip the general 'sub' folder since we checked it in step (b)
      if (folderName != 'sub') {
        final customSubPath = 'lib/features/$folderName/sub/$featureName';
        if (Directory(customSubPath).existsSync()) return customSubPath;
      }
    }
  }

  // If not found anywhere, return null (name is available for use)
  return null;
}
