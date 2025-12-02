import 'package:cleany/generate/generate_feature_widget_structure.dart';
import 'package:cleany/utils/file_modifier.dart';

Future<void> initializeFeatureWidget({
  required String featureName,
  String? basePath,
}) async {
  print("Start create $featureName features ");

  await generateFeatureWidgetStructure(
    featureName,
    basePath ?? 'lib/features/sub',
  );
  await FileModifier.runBuildRunner(showResult: false);
  print("create done");
}
