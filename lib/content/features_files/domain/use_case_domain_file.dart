import 'package:cleany/base_methods/extension/extensions.dart';

String useCaseFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();

  return '''
import 'package:multiple_result/multiple_result.dart';
import 'package:injectable/injectable.dart';
import '../entities/${featureName}_entity.dart';
import '../repositories/${featureName}_repository_domain.dart';
import '../../../../core/errors/failure.dart';


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
