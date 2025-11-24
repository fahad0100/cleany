import 'package:cleany/base_methods/extension/extensions.dart';

String useCaseFile({required String featureName}) {
  return '''
import '../entities/${featureName}_entity.dart';
import '../repositories/${featureName}_repository_domain.dart';

import 'package:injectable/injectable.dart';

@lazySingleton
class ${featureName.toCapitalized().toCapitalizeSecondWord()}UseCase {
  final ${featureName.toCapitalized().toCapitalizeSecondWord()}RepositoryDomain _repositoryData;

  ${featureName.toCapitalized().toCapitalizeSecondWord()}UseCase(this._repositoryData);

  Future<${featureName.toCapitalized().toCapitalizeSecondWord()}Entity> get${featureName.toCapitalized().toCapitalizeSecondWord()}() async {
    return _repositoryData.get${featureName.toCapitalized().toCapitalizeSecondWord()}();
  }
}
''';
}
