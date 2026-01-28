import 'package:cleany/utils/extension/extensions.dart';
import 'package:cleany/utils/file_modifier.dart';

String createRepositoryDataScreenFeatureFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
  final projectName = FileModifier.getProjectName();

  return '''

import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:$projectName/core/errors/failure.dart';
import 'package:$projectName/features/$featureName/data/datasources/${featureName}_remote_data_source.dart';
import 'package:$projectName/features/$featureName/data/models/${featureName}_model.dart';
import 'package:$projectName/features/$featureName/domain/repositories/${featureName}_repository_domain.dart';

@LazySingleton(as: ${nameCab}RepositoryDomain)
class ${nameCab}RepositoryData implements ${nameCab}RepositoryDomain{
  final Base${nameCab}RemoteDataSource remoteDataSource;


  ${nameCab}RepositoryData(this.remoteDataSource);

  @override
    Future<Result<${nameCab}Model, Failure>> get$nameCab() async {
           return await remoteDataSource.get$nameCab();
  }
}
''';
}
