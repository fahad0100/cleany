import 'dart:io';

import 'package:cleany/utils/file_modifier.dart';
import 'package:cleany/generate/generate_feature_screen_structure.dart';
import 'package:cleany/utils/logger.dart';

Future<void> initializeFeatureScreen({
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

  await generateFeatureScreenStructure(featureName, basePath ?? 'lib/features');

  Logger.info("Waiting run Build Runner ....");
  await FileModifier.runBuildRunner(showResult: false);
  Logger.success("Build Runner success....\n");
  print("create done");
}
