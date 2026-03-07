import 'dart:io';

import 'package:cleany/generate/generate_feature_widget_structure.dart';
import 'package:cleany/utils/file_modifier.dart';
import 'package:cleany/utils/logger.dart';

Future<void> initializeFeatureWidget({
  required String featureName,
  String? ownFeaturesName,
}) async {
  print("Start create $featureName features...");

  // 1. تحديد المسار الصحيح
  // إذا تم تمرير الفيتشر الأب، نضعها داخله، وإلا في مجلد sub العام
  final String targetRelativePath =
      (ownFeaturesName != null && ownFeaturesName.isNotEmpty)
      ? 'lib/features/$ownFeaturesName/sub/$featureName'
      : 'lib/features/sub/$featureName';

  // 2. التحقق من وجود الفيتشر الأب (إذا قام المستخدم بتحديده)
  if (ownFeaturesName != null && ownFeaturesName.isNotEmpty) {
    final parentDir = Directory('lib/features/$ownFeaturesName');
    if (!parentDir.existsSync()) {
      Logger.error(
        "❌ The parent feature '$ownFeaturesName' does not exist.\n"
        "When using '-p' for a custom feature, please ensure the parent exists in 'lib/features/' before adding a sub-feature to it.",
      );
      return;
    }
  }

  // 3. التحقق من أن الفيتشر الفرعي نفسه غير موجود مسبقاً لتجنب الكتابة عليه
  if (Directory(targetRelativePath).existsSync()) {
    Logger.error(
      "❌ The feature '$featureName' already exists at:\n📁 $targetRelativePath\nPlease choose a different name.",
    );
    return;
  }

  // 4. استدعاء دالة الإنشاء وإرسال المسار الصحيح
  await generateFeatureWidgetStructure(
    featureName: featureName,
    targetRelativePath: targetRelativePath,
    ownFeaturesName: ownFeaturesName,
  );

  Logger.info("Waiting run Build Runner ....");
  await FileModifier.runBuildRunner(showResult: false);
  Logger.success("Build Runner success....\n");
  Logger.warning(
    "--------------------------------------------------------------",
  );
  Logger.success("\nWidget Feature created successfully\n");
  Logger.warning(
    "--------------------------------------------------------------",
  );
}
