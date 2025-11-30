import 'package:cleany/base_methods/extension/extensions.dart';

String repositoryDomainFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();

  return '''
import 'package:multiple_result/multiple_result.dart';
import '../entities/${featureName}_entity.dart';
import '../../../../core/errors/failure.dart';


abstract class ${nameCab}RepositoryDomain {
    Future<Result<${nameCab}Entity, Failure>> get$nameCab();
}
''';
}
