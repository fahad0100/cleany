import 'package:cleany/utils/extension/extensions.dart';
import 'package:cleany/utils/file_modifier.dart';

String createRepositoryDataWidgetFeatureFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
  final projectName = FileModifier.getProjectName();

  return '''

import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:$projectName/core/errors/failure.dart';
import 'package:$projectName/features/sub/$featureName/data/datasources/${featureName}_local_data_source.dart';
import 'package:$projectName/features/sub/$featureName/data/datasources/${featureName}_remote_data_source.dart';
import 'package:$projectName/features/sub/$featureName/data/models/${featureName}_model.dart';
import 'package:$projectName/features/sub/$featureName/domain/repositories/${featureName}_repository_domain.dart';

@LazySingleton(as: ${nameCab}RepositoryDomain)
class ${nameCab}RepositoryData implements ${nameCab}RepositoryDomain{
  final Base${nameCab}RemoteDataSource remoteDataSource;
  final Base${nameCab}LocalDataSource localDataSource;

  ${nameCab}RepositoryData(this.remoteDataSource, this.localDataSource);

  @override
    Future<Result<${nameCab}Model, Failure>> get$nameCab() async {
        try{
        return await localDataSource.getCached$nameCab();
        }catch(error){
        return await remoteDataSource.get$nameCab();
        } 
  }
}
''';
}
