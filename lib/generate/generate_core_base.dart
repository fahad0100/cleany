import 'dart:io';

import 'package:cleany/get_content/get_file_core_content.dart';
import 'package:cleany/utils/logger.dart';
import 'package:path/path.dart' as path;

Future<void> generateCoreBase() async {
  Logger.info("📂 Generating core directory structure...");

  try {
    // Using path.join directly for cross-platform compatibility
    final featurePath = path.join(Directory.current.path, 'lib', 'core');

    // Explicitly defining the Map type for better Type Safety
    final Map<String, List<String>> structure = {
      'common': [],
      'constants': [
        'app_colors.dart',
        'app_images.dart',
        'app_enums.dart',
        'app_icons.dart',
      ],
      'di': ['configure_dependencies.dart', 'third_part.dart'],
      'errors': ['failure.dart', 'network_exceptions.dart'],
      'extensions': [
        'context_extensions.dart',
        'string_extensions.dart',
        'color_extensions.dart',
        'font_extensions.dart',
      ],
      'navigation': ['app_router.dart', 'routers.dart'],
      'network': ['dio_client.dart', 'api_endpoints.dart'],
      'services': ['local_keys_service.dart', 'app_device_utils.dart'],
      'theme': ['app_theme.dart', 'app_text_theme.dart'],
      'utils': ['validators.dart', 'formatters.dart'],
      'widgets': ['loading_widget.dart'],
      '': ['setup.dart'], // Files placed directly inside lib/core/
    };

    for (final entry in structure.entries) {
      final folderPath = path.join(featurePath, entry.key);

      // Create the directory if it doesn't exist
      await Directory(folderPath).create(recursive: true);

      // Create files inside the directory
      for (final fileName in entry.value) {
        final filePath = path.join(folderPath, fileName);
        final content = getCoreFileContent(fileName: fileName);
        await File(filePath).writeAsString(content);
      }
    }

    Logger.success("✅ Core base structure generated successfully.");
  } catch (e) {
    Logger.error("❌ Failed to generate core base structure: $e");
    // Rethrow instead of exit(1) to allow the parent orchestrator to handle the failure gracefully
    rethrow;
  }
}
