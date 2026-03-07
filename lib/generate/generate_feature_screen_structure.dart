import 'dart:io';

import 'package:cleany/utils/file_modifier.dart';
import 'package:cleany/get_content/get_file_screen_feature_content.dart';
import 'package:cleany/utils/extension/extensions.dart';
import 'package:cleany/utils/logger.dart';
import 'package:path/path.dart' as path;

Future<void> generateFeatureScreenStructure(
  String featureName,
  String basePath,
) async {
  Logger.info("📂 Generating directory structure for '$featureName'...");

  try {
    final featurePath = path.join(
      Directory.current.path,
      basePath,
      featureName,
    );

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
      'presentation/pages': ['${featureName}_feature_screen.dart'],
      'presentation/widgets': ['${featureName}_widget.dart'],
      // Dependency Injection
      'di': ['${featureName}_di.dart'],
    };

    // 1. Create Directories and Files
    for (final entry in structure.entries) {
      final folderPath = path.join(featurePath, entry.key);
      await Directory(folderPath).create(recursive: true);

      for (final fileName in entry.value) {
        final filePath = path.join(folderPath, fileName);
        final content = getFileScreenFeatureContent(
          fileName: fileName,
          featureName: featureName,
        );
        await File(filePath).writeAsString(content);
      }
    }

    // 2. Setup Routing and Dependency Injection
    Logger.info("⚙️ Updating routing and dependency injection files...");
    final projectName = FileModifier.getProjectName();

    await FileModifier.addImports('lib/core/navigation/app_router.dart', [
      "import 'package:go_router/go_router.dart';",
      "import 'package:flutter/material.dart';",
      "import 'routers.dart';",
      "import 'package:get_it/get_it.dart';",
      "import 'package:flutter_bloc/flutter_bloc.dart';",
      "import 'package:$projectName/features/$featureName/presentation/pages/${featureName}_feature_screen.dart';",
      "import 'package:$projectName/features/$featureName/presentation/cubit/${featureName}_cubit.dart';",
    ]);

    // Extract formatted strings to avoid redundant processing
    final formattedRouteName = featureName
        .toLowerCase()
        .toCapitalizeSecondWord();
    final formattedClassName = featureName
        .toCapitalized()
        .toCapitalizeSecondWord();

    await FileModifier.addRoute(
      routesFilePath: 'lib/core/navigation/routers.dart',
      appRouterFilePath: 'lib/core/navigation/app_router.dart',
      routeName: formattedRouteName,
      routePath: '/$formattedRouteName',
      screenWidget: '${formattedClassName}FeatureScreen',
      cubit: '${formattedClassName}Cubit',
    );

    await FileModifier.updateMainDiFile(
      featureName: featureName,
      packageName: projectName,
    );

    // Note: Removed the duplicate runBuildRunner here since it's already handled by the orchestrator (initializeFeatureScreen)
  } catch (e) {
    // Log the error before rethrowing
    Logger.error('❌ Failed to create feature "$featureName": $e');
    // Rethrow instead of exit(1) to allow graceful handling by the parent function
    rethrow;
  }
}
