import 'dart:io';
import 'package:cleany/get_content/get_file_widget_feature_content.dart';
import 'package:cleany/utils/file_modifier.dart';
import 'package:path/path.dart' as path;

Future<void> generateFeatureWidgetStructure({
  required String featureName,
  required String targetRelativePath,
  String? ownFeaturesName,
}) async {
  try {
    final featurePath = path.join(Directory.current.path, targetRelativePath);

    final structure = {
      //Data
      'data/datasources': ['${featureName}_remote_data_source.dart'],
      'di': ['${featureName}_di.dart'],
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
          ownFeaturesName: ownFeaturesName,
        );

        await File(filePath).writeAsString(content);
      }
    }
    final projectName = FileModifier.getProjectName();

    await FileModifier.updateMainDiFile(
      featureName: featureName,
      packageName: projectName,
      ownFeaturesName: ownFeaturesName,
      isSub: true,
    );
    await FileModifier.runBuildRunner(showResult: false);
    print('✅ Feature "$featureName" has been created successfully! 🎉');
    print('📁 Path: $targetRelativePath\n');
  } catch (e) {
    print('❌ Failed to create Feature: $e');
    exit(1);
  }
}
