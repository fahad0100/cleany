import 'dart:io';

import 'package:cleany/get_content/content/ar-AR_json.dart';
import 'package:cleany/get_content/content/en-US_json.dart';
import 'package:cleany/utils/file_modifier.dart';
import 'package:cleany/generate/generate_core_base.dart';
import 'package:cleany/get_content/content/main_content.dart';
import 'package:cleany/initialize/initialize_add_packages.dart';
import 'package:path/path.dart' as path;

Future<void> initializeFoldersCore() async {
  final currentPath = path.join(Directory.current.path, 'lib/core');

  final x = await FileModifier.checkFolderExistenceAsync(
    folderPath: currentPath,
  );

  if (x) {
    print("can't create core folder if folder core is exist");
  } else {
    try {
      await FileModifier.recreatePubspec();

      await Future.wait([
        generateCoreBase(),
        initializeAddPackages(),
        FileModifier.replaceFileContent(
          filePath: 'lib/main.dart',
          newContent: mainContent(),
        ),
        FileModifier.setupEnvFile(),
        FileModifier.replaceFileContent(
          filePath: 'assets/translations/ar-AR.json',
          newContent: arJsonContent(),
          createIfNotExists: true,
        ),
        FileModifier.replaceFileContent(
          filePath: 'assets/translations/en-US.json',
          newContent: enJsonContent(),
          createIfNotExists: true,
        ),
        FileModifier.createFolder('assets/icons/'),
        FileModifier.createFolder('assets/images/'),
        FileModifier.addAssetToPubspec('.env'),
        FileModifier.addAssetToPubspec('assets/translations/'),
        FileModifier.addAssetToPubspec('assets/images/'),
        FileModifier.addAssetToPubspec('assets/icons/'),
      ]);
    } on FormatException catch (_) {
      rethrow;
    } catch (error) {
      rethrow;
    }
    await initializeFoldersCore();
    final buildRunner = await Process.run('dart', [
      'run',
      'build_runner',
      'build',
    ]);
    print(buildRunner.stdout);
  }
}
