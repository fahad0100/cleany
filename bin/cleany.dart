import 'dart:io';
import 'package:args/args.dart';
import 'package:cleany/base_methods/extension/file_modifier.dart';
import 'package:cleany/base_methods/folders/create_base_folder_structure.dart';
import 'package:cleany/base_methods/folders/create_feature_folder_structure.dart';
import 'package:cleany/base_methods/print_help_method.dart';
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help')
    ..addFlag(
      'core_folders',
      abbr: 'c',
      negatable: false,
      help: 'Generate core folders',
    )
    ..addFlag(
      'add_dependence',
      abbr: 'd',
      negatable: false,
      help: 'add core dependence',
    );

  //---------
  //---------

  try {
    final results = parser.parse(arguments);
    final basePath = 'lib/features';
    if (results['help'] || arguments.isEmpty) {
      printHelp(parser);
      return;
    }

    //---------
    //---------

    if (results.arguments.length == 1 &&
        !results.arguments.first.contains('-')) {
      final appRouter = await FileModifier.checkFileExistenceAsync(
        filePath: 'lib/core/navigation/app_router.dart',
      );
      final routers = await FileModifier.checkFileExistenceAsync(
        filePath: 'lib/core/navigation/routers.dart',
      );
      if (appRouter == false || routers == false) {
        print(
          "Can't create features with out class (app_router.dart && routers.dart) in lib/core/navigation",
        );
        return;
      }
      final featureName = arguments.first.toLowerCase();
      print("Start create $featureName features ");

      await createFeatureFolderStructure(featureName, basePath);
      final buildRunner = await Process.run('dart', [
        'run',
        'build_runner',
        'build',
      ]);
      print(buildRunner.stdout);

      return;
    }
    if (results.arguments.length > 1 &&
        !results.arguments.first.contains('-')) {
      printHelp(parser);
      return;
    }

    //---------
    //---------

    if (results['core_folders']) {
      final currentPath = path.join(Directory.current.path, 'lib/core');

      final x = await FileModifier.checkFolderExistenceAsync(
        folderPath: currentPath,
      );
      print(x);
      if (x) {
        print("can't create core folder if folder core is exist");
      } else {
        print('📦 Adding packages in batch...');
        await Future.wait([
          _addPackagesBatch(corePackages, isDev: false),
          _addPackagesBatch(devPackages, isDev: true),
        ]);

        final outdated = await Process.run('flutter', ['pub', 'outdated']);
        print(outdated.stdout);
        final upgrade = await Process.run('flutter', ['pub', 'upgrade']);
        print(upgrade.stdout);
        print('📦 Create packages in batch...');
        await createBaseFolder();
        await FileModifier.addImports('lib/main.dart', [
          "import 'core/di/configure_dependencies.dart';",
          "import 'package:flutter/material.dart';",
          "import 'core/navigation/app_router.dart';",
          "import 'package:flutter_bloc/flutter_bloc.dart';",
          "import 'core/theme/cubit/theme_cubit.dart';",
          "import 'core/theme/app_theme.dart';",
          "import 'package:get_it/get_it.dart';",
          "import 'package:sizer/sizer.dart';",
        ]);
        await FileModifier.addLineInsideFunction('lib/main.dart', 'main', '''
  WidgetsFlutterBinding.ensureInitialized();\n
  await setup();\n
  await configureDependencies();\n
''', atStart: true);
        await FileModifier.replaceLine(
          'lib/main.dart',
          RegExp(r'void\s+main\s*\(\s*\)\s*{'),
          'void main() async {',
        );
        await FileModifier.replaceMaterialApp('lib/main.dart', '''
MultiBlocProvider(
      providers: [BlocProvider<ThemeCubit>(create: (context) => GetIt.I.get())],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return Sizer(
            builder: (context, orientation, screenType) {
              return MaterialApp.router(
                routerConfig: AppRouter.router,
                themeMode: themeState.themeMode,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
              );
            },
          );
        },
      ),
    );
''');
        await FileModifier.setupEnvFile();
        final buildRunner = await Process.run('dart', [
          'run',
          'build_runner',
          'build',
        ]);
        print(buildRunner.stdout);
      }
    }

    //---------
    //---------

    if (results['add_dependence']) {
      print('📦 Adding packages in batch...');
      await Future.wait([
        _addPackagesBatch(corePackages, isDev: false),
        _addPackagesBatch(devPackages, isDev: true),
      ]);

      final outdated = await Process.run('flutter', ['pub', 'outdated']);
      print(outdated.stdout);
      final upgrade = await Process.run('flutter', ['pub', 'upgrade']);
      print(upgrade.stdout);
      final buildRunner = await Process.run('dart', [
        'run',
        'build_runner',
        'build',
      ]);
      print(buildRunner.stdout);
    }
  } catch (e) {
    print('❌ error: $e');
    // printHelp(parser);
    exit(1);
  }
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
