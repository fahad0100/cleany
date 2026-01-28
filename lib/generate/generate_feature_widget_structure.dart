import 'dart:io';
import 'package:cleany/get_content/get_file_widget_feature_content.dart';
import 'package:path/path.dart' as path;

Future<void> generateFeatureWidgetStructure(
  String featureName,
  String basePath,
) async {
  try {
    final featurePath = path.join(
      Directory.current.path,
      basePath,
      featureName,
    );

    final structure = {
      //Date
      'data/datasources': ['${featureName}_remote_data_source.dart'],
      'data/models': ['${featureName}_model.dart'],
      'data/repositories': ['${featureName}_repository_data.dart'],
      //Domain
      'domain/entities': ['${featureName}_entity.dart'],
      'domain/repositories': ['${featureName}_repository_domain.dart'],
      'domain/use_cases': ['${featureName}_use_case.dart'],
      //Presentation
      'presentation/cubit': [
        '${featureName}_cubit.dart',
        '${featureName}_state.dart',
      ],
      'presentation/pages': ['${featureName}_feature_widget.dart'],
    };

    for (final entry in structure.entries) {
      final folderPath = path.join(featurePath, entry.key);
      await Directory(folderPath).create(recursive: true);
      for (final fileName in entry.value) {
        final filePath = path.join(folderPath, fileName);

        final content = getFileWidgetFeatureContent(
          fileName: fileName,
          featureName: featureName,
          basePath: basePath,
        );
        await File(filePath).writeAsString(content);
        // dart run build_runner build
      }
    }

    print('✅ Feature "$featureName" has been created successfully! 🎉');
    print('📁 Path: $featurePath\n');
  } catch (e) {
    print('❌ Failed to create Feature: $e');
    exit(1);
  }
}
