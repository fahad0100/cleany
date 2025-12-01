import 'dart:io';

import 'package:cleany/base_methods/folders/create_feature_widget_folder_structure.dart';

Future<void> createFeatureWidgetInit({
  required String featureName,
  String? basePath,
}) async {
  print("Start create $featureName features ");

  await createFeatureWidgetFolderStructure(
    featureName,
    basePath ?? 'lib/features/sub',
  );
  await Process.run('dart', ['run', 'build_runner', 'build']);
  print("create done");
}
