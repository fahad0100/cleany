import 'package:cleany/base_methods/extension/extensions.dart';

String repositoryDomainFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();

  return '''
import '../entities/${featureName}_entity.dart';
import 'package:multiple_result/multiple_result.dart';


abstract class ${nameCab}RepositoryDomain {
    Future<Result<${nameCab}Entity, Object>> get$nameCab();
}
''';
}
