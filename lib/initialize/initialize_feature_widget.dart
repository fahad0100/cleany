import 'package:cleany/generate/generate_feature_widget_structure.dart';
import 'package:cleany/utils/file_modifier.dart';
import 'package:cleany/utils/logger.dart';

Future<void> initializeFeatureWidget({
  required String featureName,
  String? basePath,
}) async {
  print("Start create $featureName features ");

  await generateFeatureWidgetStructure(
    featureName,
    basePath ?? 'lib/features/sub',
  );
  Logger.info("Waiting run Build Runner ....");
  await FileModifier.runBuildRunner(showResult: false);
  Logger.success("Build Runner success....\n");

  print("create done");
}
