import 'dart:io';

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
  print(x);
  if (x) {
    print("can't create core folder if folder core is exist");
  } else {
    await Future.wait([initializeAddPackages(), generateCoreBase()]);
    // await FileModifier.addImports('lib/main.dart', [
    //   "import 'core/di/configure_dependencies.dart';",
    //   "import 'package:flutter/material.dart';",
    //   "import 'core/navigation/app_router.dart';",
    //   "import 'package:flutter_bloc/flutter_bloc.dart';",
    //   "import 'core/theme/cubit/theme_cubit.dart';",
    //   "import 'core/theme/app_theme.dart';",
    //   "import 'package:get_it/get_it.dart';",
    //   "import 'package:sizer/sizer.dart';",
    //   "import 'core/setup.dart';",
    // ]);
    // await FileModifier.addLineInsideFunction('lib/main.dart', 'main', '''
    //   WidgetsFlutterBinding.ensureInitialized();\n
    //   await setup();\n
    //   await configureDependencies();\n
    // ''', atStart: true);
    // await FileModifier.replaceLine(
    //   'lib/main.dart',
    //   RegExp(r'void\s+main\s*\(\s*\)\s*{'),
    //   'void main() async {',
    // );
    await FileModifier.replaceMaterialApp('lib/main.dart', mainContent());
    await FileModifier.setupEnvFile();
    final buildRunner = await Process.run('dart', [
      'run',
      'build_runner',
      'build',
    ]);
    print(buildRunner.stdout);
  }
}
