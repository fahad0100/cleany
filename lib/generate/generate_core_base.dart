import 'dart:io';
import 'package:cleany/get_content/get_file_core_content.dart';
import 'package:path/path.dart' as path;

Future<void> generateCoreBase() async {
  try {
    final featurePath = path.join(Directory.current.path, 'lib/core/');
    final structure = {
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
      ],
      'global/cubit': ['public_cubit.dart', 'public_state.dart'],
      'navigation': ['app_router.dart', 'routers.dart'],
      'network': ['dio_client.dart', 'api_endpoints.dart'],
      'services': ['local_keys_service.dart', 'app_device_utils.dart'],
      'theme': ['app_theme.dart', 'app_text_theme.dart'],
      'utils': ['validators.dart', 'formatters.dart'],
      'widgets': ['loading_widget.dart'],
      '': ['setup.dart'],
    };

    for (final entry in structure.entries) {
      final folderPath = path.join(featurePath, entry.key);
      await Directory(folderPath).create(recursive: true);
      for (final fileName in entry.value) {
        final filePath = path.join(folderPath, fileName);
        final content = getCoreFileContent(fileName: fileName);
        await File(filePath).writeAsString(content);
      }
    }
  } catch (e) {
    print('❌ Failed to create Feature: $e');
    exit(1);
  }
}
