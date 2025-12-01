import 'package:cleany/base_methods/extension/extensions.dart';
import 'package:cleany/base_methods/extension/file_modifier.dart';

String repositoryDomainWidgetFeatureFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
  final projectName = FileModifier.getProjectName();

  return '''
import 'package:multiple_result/multiple_result.dart';
import 'package:$projectName/core/errors/failure.dart';
import 'package:$projectName/features/sub/$featureName/domain/entities/${featureName}_entity.dart';

abstract class ${nameCab}RepositoryDomain {
    Future<Result<${nameCab}Entity, Failure>> get$nameCab();
}
''';
}
