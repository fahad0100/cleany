import 'package:cleany/base_methods/extension/extensions.dart';

String modelData({required String featureName}) {
  return '''

import 'package:dart_mappable/dart_mappable.dart';
import '../../domain/entities/${featureName}_entity.dart';

part '${featureName}_model.mapper.dart';

@MappableClass()
class ${featureName.toCapitalized().toCapitalizeSecondWord()}Model extends ${featureName.toCapitalized().toCapitalizeSecondWord()}Entity with ${featureName.toCapitalized().toCapitalizeSecondWord()}ModelMappable {
  ${featureName.toCapitalized().toCapitalizeSecondWord()}Model({required super.id});
}

''';
}
