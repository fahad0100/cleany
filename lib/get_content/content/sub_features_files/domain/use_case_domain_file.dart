import 'package:cleany/utils/extension/extensions.dart';
import 'package:cleany/utils/file_modifier.dart';

String useCaseWidgetFeatureFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
  final projectName = FileModifier.getProjectName();

  return '''
import 'package:multiple_result/multiple_result.dart';
import 'package:injectable/injectable.dart';
import 'package:$projectName/core/errors/failure.dart';
import 'package:$projectName/features/sub/$featureName/domain/entities/${featureName}_entity.dart';
import 'package:$projectName/features/sub/$featureName/domain/repositories/${featureName}_repository_domain.dart';


@lazySingleton
class ${nameCab}UseCase {
  final ${nameCab}RepositoryDomain _repositoryData;

  ${nameCab}UseCase(this._repositoryData);

   Future<Result<${nameCab}Entity, Failure>> get$nameCab() async {
    return _repositoryData.get$nameCab();
  }
}
''';
}
