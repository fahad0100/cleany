import 'dart:io';
import 'package:args/args.dart';
import 'package:cleany/utils/logger.dart';
import 'package:cleany/utils/file_modifier.dart';
import 'package:cleany/print_help_method.dart';
import 'package:cleany/initialize/initialize_feature_screen.dart';
import 'package:cleany/initialize/initialize_feature_widget.dart';
import 'package:cleany/initialize/initialize_folders_core.dart';

void main(List<String> arguments) async {
  try {
    final parser = ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Show help and usage information.',
      )
      ..addFlag(
        'core_folders',
        abbr: 'c',
        negatable: false,
        help: 'Generate the core folder structure.',
      )
      ..addFlag(
        'feature_screen',
        abbr: 's',
        negatable: false,
        help: 'Generate a new feature as a screen.',
      )
      ..addFlag(
        'feature_widgets',
        abbr: 'w',
        negatable: false,
        help: 'Generate a new feature as a widget.',
      )
      ..addFlag(
        'feature',
        abbr: 'f',
        negatable: false,
        help: 'Specify a parent feature for a sub-feature.',
      );

    final results = parser.parse(arguments);

    // 1. Help Command (Run if -h is passed or if no arguments are provided)
    if (results.flag('help') || arguments.isEmpty) {
      printHelp(parser);
      return;
    }

    // 2. Validate Flutter Environment
    if (!(await FileModifier.isFlutterProjectRoot())) {
      Logger.error("❌ You are NOT in the root directory of a Flutter project.");
      Logger.info(
        "Please navigate to your Flutter project root and try again.",
      );
      return;
    }

    // ---------------------------------------------------------------------------------
    // 3. Create Feature as Widget (-w)
    // ---------------------------------------------------------------------------------
    if (results.flag('feature_widgets') && results.rest.isNotEmpty) {
      final featureName = results.rest[0].toLowerCase();
      String? ownFeaturesName;

      // Check if the parent feature flag (-f) is used
      if (results.flag('feature')) {
        if (results.rest.length >= 2) {
          ownFeaturesName = results.rest[1].toLowerCase();
        } else {
          Logger.error(
            "❌ Missing parent feature name.\nUsage: cleany -w <sub_feature> -f <parent_feature>",
          );
          return;
        }
      }

      await initializeFeatureWidget(
        featureName: featureName,
        ownFeaturesName: ownFeaturesName,
      );
      return;
    }

    // ---------------------------------------------------------------------------------
    // 4. Create Feature as Screen (-s)
    // ---------------------------------------------------------------------------------
    if (results.flag('feature_screen') && results.rest.isNotEmpty) {
      if (results.rest.length > 1) {
        Logger.error(
          "❌ The feature name must be a single word or multiple words separated by underscores (_).",
        );
        return;
      }

      final featureName = results.rest[0].toLowerCase();
      const basePath = 'lib/features';

      Logger.info("✨ Creating feature '$featureName' as a screen...");
      Logger.info("📁 Target path: $basePath/$featureName");

      await initializeFeatureScreen(
        featureName: featureName,
        basePath: basePath,
      );
      return;
    }

    // ---------------------------------------------------------------------------------
    // 5. Create Core Folders (-c)
    // ---------------------------------------------------------------------------------
    if (results.flag('core_folders')) {
      Logger.warning('\n⚠️  WARNING: Destructive Operation');
      Logger.error('---------------------------------------------------');
      Logger.warning(
        'This action will permanently delete and rewrite:\n'
        ' * The "lib/core" directory (if it exists)\n'
        ' * The "assets" directory (if it exists)\n'
        ' * The "lib/main.dart" file content',
      );
      Logger.warning(
        'This command is intended for fresh project initialization only.',
      );
      Logger.warning(
        'Running this on an existing project will result in data loss.',
      );
      Logger.error('---------------------------------------------------');

      // Using stdout.write so the user types on the same line
      stdout.write('❓ Are you sure you want to proceed? (y/N): ');
      final confirm = stdin.readLineSync();

      if (confirm?.toLowerCase() == 'y') {
        await initializeFoldersCore();
      } else {
        Logger.info(
          '🛑 Operation cancelled. No changes were made to your project.',
        );
      }
      return;
    }

    // ---------------------------------------------------------------------------------
    // 6. Invalid Command Fallback
    // ---------------------------------------------------------------------------------
    Logger.error("❌ Invalid command or arguments.");
    Logger.info(
      "Use 'cleany -h' to see the available commands and usage instructions.",
    );
  } on FormatException catch (e) {
    Logger.error("❌ Format Error: ${e.message}");
    Logger.info("Use 'cleany -h' to see the available commands.");
  } catch (error) {
    // Print the actual error so it can be debugged
    Logger.error("❌ An unexpected error occurred: $error");
    Logger.info("Use 'cleany -h' to see the available commands.");
  }
}
