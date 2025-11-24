import 'package:cleany/base_methods/extension/extensions.dart';

String repositoryDomainFile({required String featureName}) {
  return '''
import '../entities/${featureName}_entity.dart';
abstract class ${featureName.toCapitalized().toCapitalizeSecondWord()}RepositoryDomain {
  Future<${featureName.toCapitalized().toCapitalizeSecondWord()}Entity> get${featureName.toCapitalized().toCapitalizeSecondWord()}();
}
''';
}
