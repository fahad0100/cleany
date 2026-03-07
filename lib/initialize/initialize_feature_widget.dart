import 'dart:io';

import 'package:cleany/generate/generate_feature_widget_structure.dart';
import 'package:cleany/utils/file_modifier.dart';
import 'package:cleany/utils/logger.dart';

Future<void> initializeFeatureWidget({
  required String featureName,
  String? ownFeaturesName,
}) async {
  Logger.info("🚀 Starting to create '$featureName' widget feature...");

  // 1. Define variables and paths
  final bool hasParent = ownFeaturesName != null && ownFeaturesName.isNotEmpty;
  final String parentPath = 'lib/features/$ownFeaturesName';
  final String targetRelativePath = hasParent
      ? '$parentPath/sub/$featureName'
      : 'lib/features/sub/$featureName';

  // 2. Check parent feature existence (if -f flag is used)
  if (hasParent) {
    if (!Directory(parentPath).existsSync()) {
      Logger.error(
        "❌ The parent feature '$ownFeaturesName' does not exist.\n"
        "When using '-f' for a custom parent feature, please ensure it exists in 'lib/features/' before adding a sub-feature.",
      );
      return;
    }
  }

  // 3. Comprehensive check: Search for the feature name in all potential locations to prevent conflicts
  final existingPath = _findExistingFeaturePath(featureName);
  if (existingPath != null) {
    Logger.error(
      "❌ Conflict Detected: The feature '$featureName' already exists at:\n"
      "📁 $existingPath\n"
      "Please choose a different name to avoid import conflicts.",
    );
    return;
  }

  try {
    // 4. Call the generation function and pass the correct path
    await generateFeatureWidgetStructure(
      featureName: featureName,
      targetRelativePath: targetRelativePath,
      ownFeaturesName: ownFeaturesName,
    );

    // 5. Run build_runner
    Logger.info("⏳ Running build_runner...");
    await FileModifier.runBuildRunner(showResult: false);
    Logger.success("✅ build_runner completed successfully.\n");

    // 6. Print detailed success message
    Logger.warning(
      "--------------------------------------------------------------",
    );
    Logger.success("✨ Widget Feature '$featureName' created successfully");
    Logger.success("📁 Location: $targetRelativePath");
    Logger.warning(
      "--------------------------------------------------------------",
    );
  } catch (e) {
    Logger.error("❌ Failed to create widget feature '$featureName': $e");
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
