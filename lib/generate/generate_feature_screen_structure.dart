import 'dart:io';

import 'package:cleany/utils/file_modifier.dart';
import 'package:cleany/get_content/get_file_screen_feature_content.dart';
import 'package:cleany/utils/extension/extensions.dart';
import 'package:path/path.dart' as path;

Future<void> generateFeatureScreenStructure(
  String featureName,
  String basePath,
) async {
  try {
    final featurePath = path.join(
      Directory.current.path,
      basePath,
      featureName,
    );

    final structure = {
      //Date
      'data/datasources': [
        '${featureName}_remote_data_source.dart',
        '${featureName}_local_data_source.dart',
      ],
      'data/models': ['${featureName}_model.dart'],
      'data/repositories': ['${featureName}_repository_data.dart'],
      //Domain
      'domain/entities': ['${featureName}_entity.dart'],
      'domain/repositories': ['${featureName}_repository_domain.dart'],
      'domain/use_cases': ['${featureName}_use_case.dart'],
      //Presentation
      'presentation/cubit': [
        '${featureName}_cubit.dart',
        '${featureName}_state.dart',
      ],
      'presentation/pages': ['${featureName}_feature_screen.dart'],
      'presentation/widgets': ['${featureName}_widget.dart'],
    };

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
        // dart run build_runner build
      }
    }
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

    await FileModifier.addRoute(
      routesFilePath: 'lib/core/navigation/routers.dart',
      appRouterFilePath: 'lib/core/navigation/app_router.dart',
      routeName: featureName.toLowerCase().toCapitalizeSecondWord(),
      routePath: '/${featureName.toLowerCase().toCapitalizeSecondWord()}',
      screenWidget:
          '${featureName.toCapitalized().toCapitalizeSecondWord()}FeatureScreen',
      cubit: '${featureName.toCapitalized().toCapitalizeSecondWord()}Cubit',
    );

    print('✅ Feature "$featureName" has been created successfully! 🎉');
    print('📁 Path: $featurePath\n');
  } catch (e) {
    print('❌ Failed to create Feature: $e');
    exit(1);
  }
}
