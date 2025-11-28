import 'dart:io';
import 'package:args/args.dart';
import 'package:cleany/base_methods/extension/extensions.dart';
import 'package:cleany/base_methods/extension/file_modifier.dart';
import 'package:cleany/base_methods/folders/create_base_folder_structure.dart';
import 'package:cleany/base_methods/print_help_method.dart';
import 'package:cleany/content/ar-AR_json.dart';
import 'package:cleany/content/en-US_json.dart';
import 'package:cleany/content/main_content.dart';
import 'package:cleany/methods/add_packages_init.dart';
import 'package:cleany/methods/create_feature_screen_init.dart';
import 'package:cleany/methods/create_folders_core_init.dart';

class Log {
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String cyan = '\x1B[36m';

  static void success(String msg) {
    print("$_green $msg$_reset");
  }

  static void error(String msg) {
    print("$_red✖ $msg$_reset");
  }

  static void warning(String msg) {
    print("$_yellow⚠ $msg$_reset");
  }

  static void info(String msg) {
    print("$cyanℹ $msg$_reset");
  }
}

void main(List<String> arguments) async {
  try {
    final parser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help')
      ..addFlag(
        'core_folders',
        abbr: 'c',
        negatable: false,
        help: 'Generate core folders',
      )
      ..addFlag(
        'feature_screen',
        abbr: 's',
        negatable: false,
        help: 'feature as screen',
      )
      ..addFlag(
        'feature_widgets',
        abbr: 'w',
        negatable: false,
        help: 'feature as widgets',
      )
      ..addFlag(
        'path',
        abbr: 'p',
        negatable: false,
        help: 'add custom path for only feature widget',
      )
      ..addFlag(
        'add_dependence',
        abbr: 'a',
        negatable: false,
        help: 'add core dependence',
      );

    //---------
    //---------

    final results = parser.parse(arguments);

    if (results.arguments.length == 1 && results.flag('help')) {
      printHelp(parser);
      return;
    }

    //---------
    //---------
    //-------------------------create as widget----------------------------------------

    if (results.flag('feature_widgets') && results.rest.isNotEmpty) {
      String basePath = 'lib/features/sub_features';
      String featureName = results.rest[0];
      bool startCreateMethod = false;
      switch (results.arguments.length) {
        case 2:
          print("with without path");
          startCreateMethod = true;
          break;
        case > 2 && <= 4:
          if (results.flag('path') && results.rest.length == 2) {
            basePath = results.rest[1];
            startCreateMethod = true;
            break;
          }
      }
      if (startCreateMethod) {
        Log.success(
          "** Creating feature $featureName as a widget ** \n    path: $basePath/${featureName.toCapitalizeSecondWord()}",
        );

        return;
      }
    }
    //-------------------------create as screen----------------------------------------
    if (results.rest.length == 1 &&
        results.arguments.length == 2 &&
        results.flag('feature_screen')) {
      String basePath = 'lib/features';
      String featureName = results.rest[0];
      Log.success(
        "** Creating feature $featureName as a screen** \n    path: $basePath/${featureName.toCapitalizeSecondWord()}",
      );

      await createFeatureScreenInit(featureName: "Ddd", basePath: basePath);

      return;
    }

    //-------------------------create core folder----------------------------------------
    if (results.arguments.length == 1 && results.flag('core_folders')) {
      Log.warning('\n⚠️  WARNING: Destructive Operation');
      Log.error('---------------------------------------------------');
      Log.warning(
        'This action will permanently delete and rewrite the \n* core       | directory if it exists, \n* assets     | directory if it exists and \n* main.dart  | file content',
      );
      Log.warning(
        'This command is intended for fresh project initialization only.',
      );
      Log.warning(
        'Running this on an existing project will result in data loss.',
      );

      Log.error('---------------------------------------------------');
      Log.success('Are you sure you want to proceed? (y/N): ');
      final confirm = stdin.readLineSync();

      switch (confirm?.toLowerCase()) {
        case 'n':
          Log.info(
            'Thank you for your diligence with the code. I hope you use me in your new project',
          );

          return;
        case 'y':
          try {
            await FileModifier.replaceFileContent(
              filePath: 'lib/main.dart',
              newContent: mainContent(),
            );
            await FileModifier.replaceFileContent(
              filePath: 'assets/translations/ar-AR.json',
              newContent: arJsonContent(),
              createIfNotExists: true,
            );
            await FileModifier.replaceFileContent(
              filePath: 'assets/translations/en-US.json',
              newContent: enJsonContent(),
              createIfNotExists: true,
            );
            await createBaseFolder();
            await FileModifier.setupEnvFile();
            await FileModifier.createFolder('assets/icons/');
            await FileModifier.createFolder('assets/images/');
            await FileModifier.addAssetToPubspec('.env');
            await FileModifier.addAssetToPubspec('assets/translations/');
            await FileModifier.addAssetToPubspec('assets/images/');
            await FileModifier.addAssetToPubspec('assets/icons/');
            await addPackagesInit();
          } on FormatException catch (error) {
            Log.error(error.message);
          } catch (error) {
            Log.error(error.toString());
          }
          await createFoldersCoreInit();

          return;

        default:
          Log.error(
            "Warning: Invalid input will wipe out your progress. Please pay close attention and ensure your input is accurate.",
          );
          return;
      }
    }

    //-------------------------create core----------------------------------------
    if (results.arguments.length == 1 && results.flag('add_dependence')) {
      print("\n\n\n\n** start add core dependence **\n\n\n\n");
      await addPackagesInit();

      return;
    }

    //-------------------------help----------------------------------------
    // printHelp(parser);

    Log.error(
      "Wrong.. Follow the format I provided. Don't change anything else\n\n  use: cleany -h     \n\nto know how use it",
    );

    return;
  } catch (error) {
    Log.error("Wrong input.  \n\nuse: cleany -h     \n\nto know how use it");
  }

  //-------------------------as screen----------------------------------------

  //-------------------------as screen----------------------------------------

  //     return;
  //     if (results.arguments.length == 1 &&
  //         !results.arguments.first.contains('-')) {
  //       final appRouter = await FileModifier.checkFileExistenceAsync(
  //         filePath: 'lib/core/navigation/app_router.dart',
  //       );
  //       final routers = await FileModifier.checkFileExistenceAsync(
  //         filePath: 'lib/core/navigation/routers.dart',
  //       );
  //       if (appRouter == false || routers == false) {
  //         print(
  //           "Can't create features with out class (app_router.dart && routers.dart) in lib/core/navigation",
  //         );
  //         return;
  //       }
  //       final featureName = arguments.first.toLowerCase();
  //       print("Start create $featureName features ");

  //       await createFeatureFolderStructure(featureName, basePath);
  //       final buildRunner = await Process.run('dart', [
  //         'run',
  //         'build_runner',
  //         'build',
  //       ]);
  //       print(buildRunner.stdout);

  //       return;
  //     }
  //     if (results.arguments.length > 1 &&
  //         !results.arguments.first.contains('-')) {
  //       printHelp(parser);
  //       return;
  //     }

  //     //---------
  //     //---------

  //     if (results['core_folders']) {
  //       final currentPath = path.join(Directory.current.path, 'lib/core');

  //       final x = await FileModifier.checkFolderExistenceAsync(
  //         folderPath: currentPath,
  //       );
  //       print(x);
  //       if (x) {
  //         print("can't create core folder if folder core is exist");
  //       } else {
  //         print('📦 Adding packages in batch...');
  //         await Future.wait([
  //           _addPackagesBatch(corePackages, isDev: false),
  //           _addPackagesBatch(devPackages, isDev: true),
  //         ]);

  //         final outdated = await Process.run('flutter', ['pub', 'outdated']);
  //         print(outdated.stdout);
  //         final upgrade = await Process.run('flutter', ['pub', 'upgrade']);
  //         print(upgrade.stdout);
  //         print('📦 Create packages in batch...');
  //         await createBaseFolder();
  //         await FileModifier.addImports('lib/main.dart', [
  //           "import 'core/di/configure_dependencies.dart';",
  //           "import 'package:flutter/material.dart';",
  //           "import 'core/navigation/app_router.dart';",
  //           "import 'package:flutter_bloc/flutter_bloc.dart';",
  //           "import 'core/theme/cubit/theme_cubit.dart';",
  //           "import 'core/theme/app_theme.dart';",
  //           "import 'package:get_it/get_it.dart';",
  //           "import 'package:sizer/sizer.dart';",
  //           "import 'core/setup.dart';",
  //         ]);
  //         await FileModifier.addLineInsideFunction('lib/main.dart', 'main', '''
  //   WidgetsFlutterBinding.ensureInitialized();\n
  //   await setup();\n
  //   await configureDependencies();\n
  // ''', atStart: true);
  //         await FileModifier.replaceLine(
  //           'lib/main.dart',
  //           RegExp(r'void\s+main\s*\(\s*\)\s*{'),
  //           'void main() async {',
  //         );
  //         await FileModifier.replaceMaterialApp('lib/main.dart', '''
  // MultiBlocProvider(
  //       providers: [BlocProvider<ThemeCubit>(create: (context) => GetIt.I.get())],
  //       child: BlocBuilder<ThemeCubit, ThemeState>(
  //         builder: (context, themeState) {
  //           return Sizer(
  //             builder: (context, orientation, screenType) {
  //               return MaterialApp.router(
  //                 routerConfig: AppRouter.router,
  //                 themeMode: themeState.themeMode,
  //                 theme: AppTheme.lightTheme,
  //                 darkTheme: AppTheme.darkTheme,
  //               );
  //             },
  //           );
  //         },
  //       ),
  //     );
  // ''');
  //         await FileModifier.setupEnvFile();
  //         final buildRunner = await Process.run('dart', [
  //           'run',
  //           'build_runner',
  //           'build',
  //         ]);
  //         print(buildRunner.stdout);
  //       }
  //     }

  //     //---------
  //     //---------

  //     if (results['add_dependence']) {
  //       print('📦 Adding packages in batch...');
  //       await Future.wait([
  //         _addPackagesBatch(corePackages, isDev: false),
  //         _addPackagesBatch(devPackages, isDev: true),
  //       ]);

  //       final outdated = await Process.run('flutter', ['pub', 'outdated']);
  //       print(outdated.stdout);
  //       final upgrade = await Process.run('flutter', ['pub', 'upgrade']);
  //       print(upgrade.stdout);
  //       final buildRunner = await Process.run('dart', [
  //         'run',
  //         'build_runner',
  //         'build',
  //       ]);
  //       print(buildRunner.stdout);
  //     }
  //   } catch (e) {
  //     print('❌ error: $e');
  //     // printHelp(parser);
  //     exit(1);
}

//---------
//==========
//---------

Future<void> _addPackagesBatch(
  List<String> packages, {
  required bool isDev,
}) async {
  try {
    final command = 'flutter';
    final args = isDev
        ? ['pub', 'add', '--dev', ...packages]
        : ['pub', 'add', ...packages];

    print('📦 Adding ${packages.length} packages in batch...');

    final result = await Process.run(command, args);

    if (result.exitCode == 0) {
      print('✅ Successfully added/updated all packages!');
      print(result.stdout);
    } else {
      print('❌ Failed to add packages: ${result.stderr}');
    }
  } catch (e) {
    print('⚠️ Error: $e');
  }
}

// bool _isPubspecExist() {
//   return File('pubspec.yaml').existsSync();
// }

const List<String> corePackages = [
  'get_it',
  'logger',
  'bloc',
  'retrofit',
  'flutter_dotenv',
  'injectable',
  'supabase_flutter',
  'cached_network_image',
  'flutter_bloc',
  'equatable',
  'dartz',
  'dio',
  'go_router',
  'get_storage',
  'intl',
  'dart_mappable',
  'hydrated_bloc',
  'uuid',
  'image_picker',
  'flutter_svg',
  'connectivity_plus',
  'permission_handler',
  'url_launcher',
  'flutter_secure_storage',
  'path_provider',
  'package_info_plus',
  'share_plus',
  'lottie',
  'gap',
  'shimmer',
  'sizer',
];

const List<String> devPackages = [
  'build_runner',
  'dart_mappable_builder',
  'retrofit_generator',
  'injectable_generator',
];








/*


  cached_network_image: ^3.4.1
  flutter_svg: ^2.2.3
  image_picker: ^1.2.1
  gap: ^3.0.1
  # connectivity_plus: ^7.0.0
  flutter_dotenv: ^6.0.0
  flutter_bloc: ^9.1.1
  bloc: ^9.1.0
  dart_mappable: ^4.6.1
  dio: ^5.9.0
  retrofit: ^4.9.1
  easy_localization: ^3.0.8
  flutter_secure_storage: ^9.2.4
  get_storage: ^2.1.1
  get_it: ^9.1.0
  go_router: ^17.0.0
  injectable: ^2.6.0
  equatable: ^2.0.7
  intl: ^0.20.2
  lottie: ^3.3.2
  package_info_plus: ^9.0.0
  path_provider: ^2.1.5
  permission_handler: ^12.0.1
  share_plus: ^12.0.1
  shimmer: ^3.0.0
  sizer: ^3.1.3
  supabase_flutter: ^2.10.3
  url_launcher: ^6.3.2
  uuid: ^4.5.2



  //---

  dev:
  flutter_lints: ^6.0.0
  build_runner: ^2.10.4
  dart_mappable_builder: ^4.6.1
  retrofit_generator: ^10.2.0
  injectable_generator: ^2.9.1

- .env
    - assets/translations/
    - assets/images/
    - assets/icons/





translations:
ar-AR.json
en-US.json
{
   "data":"Dataen"
}


env:
url_supabase=<XXXXX>
key_supabase=<XXXXX>
*/