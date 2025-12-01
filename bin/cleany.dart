import 'dart:io';
import 'package:args/args.dart';
import 'package:cleany/utils/extension/extensions.dart';
import 'package:cleany/utils/file_modifier.dart';
import 'package:cleany/generate/generate_core_base.dart';
import 'package:cleany/print_help_method.dart';
import 'package:cleany/get_content/content/ar-AR_json.dart';
import 'package:cleany/get_content/content/en-US_json.dart';
import 'package:cleany/get_content/content/main_content.dart';
import 'package:cleany/initialize/initialize_add_packages.dart';
import 'package:cleany/initialize/initialize_feature_screen.dart';
import 'package:cleany/initialize/initialize_feature_widget.dart';
import 'package:cleany/initialize/initialize_folders_core.dart';

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

    //---------------------------------------------------------------------------------
    //---------------------------------------------------------------------------------

    final results = parser.parse(arguments);

    if (results.arguments.length == 1 && results.flag('help')) {
      printHelp(parser);
      return;
    }
    if (!(await FileModifier.isFlutterProjectRoot())) {
      Log.error("❌ You are NOT in the root of a Flutter project.");
      return;
    }
    //---------------------------------------------------------------------------------
    //---------------------------------------------------------------------------------
    //-------------------------create as widget----------------------------------------
    //---------------------------------------------------------------------------------
    //---------------------------------------------------------------------------------
    if (results.flag('feature_widgets') && results.rest.isNotEmpty) {
      String basePath = 'lib/features/sub';
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
        await initializeFeatureWidget(
          featureName: featureName,
          basePath: basePath,
        );
        return;
      }
    }
    //---------------------------------------------------------------------------------
    //---------------------------------------------------------------------------------
    //-------------------------create as screen----------------------------------------
    //---------------------------------------------------------------------------------
    //---------------------------------------------------------------------------------
    if (results.rest.length == 1 &&
        results.arguments.length == 2 &&
        results.flag('feature_screen')) {
      String basePath = 'lib/features';
      String featureName = results.rest[0];
      print(results.rest.length);
      if (results.rest.length > 1) {
        throw FormatException(
          "The name must be a single word or multiple words separated by underscores (_)",
        );
      }
      print(results.rest);
      Log.success(
        "** Creating feature $featureName as a screen** \n    path: $basePath/${featureName.toCapitalizeSecondWord()}",
      );

      await initializeFeatureScreen(
        featureName: featureName,
        basePath: basePath,
      );

      return;
    }

    //---------------------------------------------------------------------------------
    //---------------------------------------------------------------------------------
    //-------------------------create core folder--------------------------------------
    //---------------------------------------------------------------------------------
    //---------------------------------------------------------------------------------
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
            await generateCoreBase();
            await FileModifier.setupEnvFile();
            await FileModifier.createFolder('assets/icons/');
            await FileModifier.createFolder('assets/images/');
            await FileModifier.addAssetToPubspec('.env');
            await FileModifier.addAssetToPubspec('assets/translations/');
            await FileModifier.addAssetToPubspec('assets/images/');
            await FileModifier.addAssetToPubspec('assets/icons/');
            await initializeAddPackages();
          } on FormatException catch (error) {
            Log.error(error.message);
          } catch (error) {
            Log.error(error.toString());
          }
          await initializeFoldersCore();

          return;

        default:
          Log.error(
            "Warning: Invalid input will wipe out your progress. Please pay close attention and ensure your input is accurate.",
          );
          return;
      }
    }
    //---------------------------------------------------------------------------------
    //---------------------------------------------------------------------------------
    //-------------------------create dependence---------------------------------------
    //---------------------------------------------------------------------------------
    //---------------------------------------------------------------------------------
    if (results.arguments.length == 1 && results.flag('add_dependence')) {
      print("\n\n\n\n** start add core dependence **\n\n\n\n");
      await initializeAddPackages();

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
}
