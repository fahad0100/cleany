import 'package:cleany/base_methods/extension/extensions.dart';

String createRepositoryDataFile({required String featureName}) {
  return '''

import 'package:injectable/injectable.dart';
import '../../domain/repositories/${featureName}_repository_domain.dart';
import '../datasources/${featureName}_remote_data_source.dart';
import '../datasources/${featureName}_local_data_source.dart';
import '../models/${featureName}_model.dart';

@LazySingleton(as: ${featureName.toCapitalized().toCapitalizeSecondWord()}RepositoryDomain)
class ${featureName.toCapitalized().toCapitalizeSecondWord()}RepositoryData implements ${featureName.toCapitalized().toCapitalizeSecondWord()}RepositoryDomain{
  final Base${featureName.toCapitalized().toCapitalizeSecondWord()}RemoteDataSource remoteDataSource;
  final Base${featureName.toCapitalized().toCapitalizeSecondWord()}LocalDataSource localDataSource;

  ${featureName.toCapitalized().toCapitalizeSecondWord()}RepositoryData({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<${featureName.toCapitalized().toCapitalizeSecondWord()}Model> get${featureName.toCapitalized().toCapitalizeSecondWord()}() async {
        try{
        return await localDataSource.getCached${featureName.toCapitalized().toCapitalizeSecondWord()}();
        }catch(error){
        return await remoteDataSource.get${featureName.toCapitalized().toCapitalizeSecondWord()}();
        }
        
  }
}
''';
}
