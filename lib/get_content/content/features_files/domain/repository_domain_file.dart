import 'package:cleany/utils/extension/extensions.dart';
import 'package:cleany/utils/file_modifier.dart';

String repositoryDomainScreenFeatureFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
  final projectName = FileModifier.getProjectName();

  return '''
import 'package:multiple_result/multiple_result.dart';
import 'package:$projectName/core/errors/failure.dart';
import 'package:$projectName/features/$featureName/domain/entities/${featureName}_entity.dart';

abstract class ${nameCab}RepositoryDomain {
    Future<Result<${nameCab}Entity, Failure>> get$nameCab();
}
''';
}
