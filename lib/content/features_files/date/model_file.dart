import 'package:cleany/base_methods/extension/extensions.dart';

String modelData({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();

  return '''

import 'package:dart_mappable/dart_mappable.dart';
import '../../domain/entities/${featureName}_entity.dart';

part '${featureName}_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class ${nameCab}Model extends ${nameCab}Entity with ${nameCab}ModelMappable {
  ${nameCab}Model({required super.id});
}

''';
}
