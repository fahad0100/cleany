import 'dart:io';

import 'package:cleany/base_methods/extension/file_modifier.dart';
import 'package:cleany/base_methods/folders/create_feature_screen_folder_structure.dart';

Future<void> createFeatureScreenInit({
  required String featureName,
  String? basePath,
}) async {
  final core = await FileModifier.checkFolderExistenceAsync(
    folderPath: 'lib/core',
  );
  if (!core) {
    print("Sorry.. \nCan't create features without core folder path in lib/");
  }
  //--------------------------------------------------------------------------------
  final diFile = await FileModifier.checkFileExistenceAsync(
    filePath: 'lib/core/di/configure_dependencies.dart',
  );
  if (!diFile) {
    print(
      "Sorry.. \nCan't create features without configure_dependencies file path in lib/core/di/configure_dependencies.dart",
    );
  }
  //--------------------------------------------------------------------------------
  final appRouter = await FileModifier.checkFileExistenceAsync(
    filePath: 'lib/core/navigation/app_router.dart',
  );
  if (!appRouter) {
    print(
      "Sorry.. \nCan't create features without app_router file path in lib/core/navigation/app_router.dart",
    );
  }
  //--------------------------------------------------------------------------------

  final routers = await FileModifier.checkFileExistenceAsync(
    filePath: 'lib/core/navigation/routers.dart',
  );
  if (!routers) {
    print(
      "Sorry.. \nCan't create features without routers file path in lib/core/navigation/routers.dart",
    );
  }
  //--------------------------------------------------------------------------------

  print("Start create $featureName features ");

  await createFeatureScreenFolderStructure(
    featureName,
    basePath ?? 'lib/features',
  );
  await Process.run('dart', ['run', 'build_runner', 'build']);
  print("create done");
}
