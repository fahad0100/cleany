import 'dart:io';

import 'package:cleany/get_content/get_file_widget_feature_content.dart';
import 'package:cleany/utils/file_modifier.dart';
import 'package:cleany/utils/logger.dart';
import 'package:path/path.dart' as path;

Future<void> generateFeatureWidgetStructure({
  required String featureName,
  required String targetRelativePath,
  String? ownFeaturesName,
}) async {
  Logger.info("📂 Generating directory structure for widget '$featureName'...");

  try {
    final featurePath = path.join(Directory.current.path, targetRelativePath);

    // Explicitly defining the Map type for Type Safety
    final Map<String, List<String>> structure = {
      // Data Layer
      'data/datasources': ['${featureName}_remote_data_source.dart'],
      'data/models': ['${featureName}_model.dart'],
      'data/repositories': ['${featureName}_repository_data.dart'],
      // Domain Layer
      'domain/entities': ['${featureName}_entity.dart'],
      'domain/repositories': ['${featureName}_repository_domain.dart'],
      'domain/use_cases': ['${featureName}_use_case.dart'],
      // Presentation Layer
      'presentation/cubit': [
        '${featureName}_cubit.dart',
        '${featureName}_state.dart',
      ],
      'presentation/pages': ['${featureName}_feature_widget.dart'],
      // Dependency Injection
      if (ownFeaturesName == null) 'di': ['${featureName}_di.dart'],
    };

    // 1. Create Directories and Files
    for (final entry in structure.entries) {
      final folderPath = path.join(featurePath, entry.key);

      await Directory(folderPath).create(recursive: true);

      for (final fileName in entry.value) {
        final filePath = path.join(folderPath, fileName);

        final content = getFileWidgetFeatureContent(
          fileName: fileName,
          featureName: featureName,
          ownFeaturesName: ownFeaturesName,
        );

        await File(filePath).writeAsString(content);
      }
    }

    // 2. Setup Dependency Injection
    Logger.info("⚙️ Updating dependency injection file...");
    final projectName = FileModifier.getProjectName();
    if (ownFeaturesName == null) {
      await FileModifier.updateMainDiFile(
        featureName: featureName,
        packageName: projectName,
        ownFeaturesName: ownFeaturesName,
        isSub: true,
      );
    }

    Logger.success(
      '✅ Feature "$featureName" structure generated successfully!',
    );
    Logger.success('📁 Path: $targetRelativePath\n');
  } catch (e) {
    // Log the error before rethrowing
    Logger.error('❌ Failed to create widget feature "$featureName": $e');
    // Rethrow instead of exit(1) to allow graceful handling by the parent function
    rethrow;
  }
}
