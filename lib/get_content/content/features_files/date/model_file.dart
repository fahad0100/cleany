import 'package:cleany/utils/extension/extensions.dart';
import 'package:cleany/utils/file_modifier.dart';
// import 'package:cleany/utils/file_modifier.dart';

String modelDataScreenFeature({
  required String featureName,
  String? ownFeaturesName,
  required bool isSub,
}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
  final projectName = FileModifier.getProjectName();
  return '''
import 'package:$projectName/features/${ownFeaturesName != null
      ? '$ownFeaturesName/sub/'
      : isSub
      ? 'sub/'
      : ''}$featureName/domain/entities/${featureName}_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part '${featureName}_model.freezed.dart';
part '${featureName}_model.g.dart';

@freezed
abstract class ${nameCab}Model with _\$${nameCab}Model {
  const factory ${nameCab}Model({
    required int id,
    required String firstName,
    required String lastName,
    
  }) = _${nameCab}Model;

  factory ${nameCab}Model.fromJson(Map<String, Object?> json) => _\$${nameCab}ModelFromJson(json);
}



extension ${nameCab}ModelMapper on ${nameCab}Model {
  ${nameCab}Entity toEntity() {
    return ${nameCab}Entity(id: id, firstName: firstName, lastName: lastName);
  }
  }
''';
}
