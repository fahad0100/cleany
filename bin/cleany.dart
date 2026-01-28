import 'dart:io';
import 'package:args/args.dart';
import 'package:cleany/utils/logger.dart';
import 'package:cleany/utils/extension/extensions.dart';
import 'package:cleany/utils/file_modifier.dart';
import 'package:cleany/print_help_method.dart';
import 'package:cleany/initialize/initialize_add_packages.dart';
import 'package:cleany/initialize/initialize_feature_screen.dart';
import 'package:cleany/initialize/initialize_feature_widget.dart';
import 'package:cleany/initialize/initialize_folders_core.dart';

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
      Logger.error("❌ You are NOT in the root of a Flutter project.");
      return;
    }
    //---------------------------------------------------------------------------------
    //---------------------------------------------------------------------------------
    //-------------------------create as widget----------------------------------------
    //---------------------------------------------------------------------------------
    //---------------------------------------------------------------------------------
    if (results.flag('feature_widgets') && results.rest.isNotEmpty) {
      String basePath = 'lib/features/sub';
      String featureName = results.rest[0].toLowerCase();
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
      String featureName = results.rest[0].toLowerCase();

      print(results.rest.length);
      if (results.rest.length > 1) {
        throw FormatException(
          "The name must be a single word or multiple words separated by underscores (_)",
        );
      }
      print(results.rest);
      Logger.success(
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
      Logger.warning('\n⚠️  WARNING: Destructive Operation');
      Logger.error('---------------------------------------------------');
      Logger.warning(
        'This action will permanently delete and rewrite the \n* core       | directory if it exists, \n* assets     | directory if it exists and \n* main.dart  | file content',
      );
      Logger.warning(
        'This command is intended for fresh project initialization only.',
      );
      Logger.warning(
        'Running this on an existing project will result in data loss.',
      );

      Logger.error('---------------------------------------------------');
      Logger.success('Are you sure you want to proceed? (y/N): ');
      final confirm = stdin.readLineSync();

      switch (confirm?.toLowerCase()) {
        case 'n':
          Logger.info(
            'Thank you for your diligence with the code. I hope you use me in your new project',
          );

          return;
        case 'y':
          await initializeFoldersCore();
          return;

        default:
          Logger.error(
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

    Logger.error(
      "Wrong.. Follow the format I provided. Don't change anything else\n\n  use: cleany -h     \n\nto know how use it",
    );

    return;
  } catch (error) {
    Logger.error("Wrong input.  \n\nuse: cleany -h     \n\nto know how use it");
  }
}
