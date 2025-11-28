import 'package:cleany/base_methods/extension/file_modifier.dart';

Future<void> createFeatureScreenInit({
  required String featureName,
  String? basePath,
}) async {
  final appRouter = await FileModifier.checkFileExistenceAsync(
    filePath: 'lib/core/navigation/app_router.dart',
  );
  final routers = await FileModifier.checkFileExistenceAsync(
    filePath: 'lib/core/navigation/routers.dart',
  );
  final core = await FileModifier.checkFolderExistenceAsync(
    folderPath: 'lib/core',
  );

  if (!appRouter || !routers) {
    print(
      "Sorry.. \nCan't create features without class (app_router.dart && routers.dart) in lib/core/navigation",
    );
    return;
  }
  if (!core) {
    print("Can't create features with out create core folder");
    return;
  }

  // print("Start create $featureName features ");

  // await createFeatureFolderStructure(featureName, basePath ?? 'lib/features');
  // final buildRunner = await Process.run('dart', [
  //   'run',
  //   'build_runner',
  //   'build',
  // ]);
  // print(buildRunner.stdout);
}
