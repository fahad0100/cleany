import 'package:cleany/utils/extension/extensions.dart';
import 'package:cleany/utils/file_modifier.dart';

String modelDataWidgetFeatureFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
  final projectName = FileModifier.getProjectName();

  return '''
import 'package:dart_mappable/dart_mappable.dart';
import 'package:$projectName/features/sub/$featureName/domain/entities/${featureName}_entity.dart';
part '${featureName}_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class ${nameCab}Model extends ${nameCab}Entity with ${nameCab}ModelMappable {
  ${nameCab}Model({required super.id});
}

''';
}
