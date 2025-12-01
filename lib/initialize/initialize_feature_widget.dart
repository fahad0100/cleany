import 'dart:io';

import 'package:cleany/generate/generate_feature_widget_structure.dart';

Future<void> initializeFeatureWidget({
  required String featureName,
  String? basePath,
}) async {
  print("Start create $featureName features ");

  await generateFeatureWidgetStructure(
    featureName,
    basePath ?? 'lib/features/sub',
  );
  await Process.run('dart', ['run', 'build_runner', 'build']);
  print("create done");
}
