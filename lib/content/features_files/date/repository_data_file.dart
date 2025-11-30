import 'package:cleany/base_methods/extension/extensions.dart';

String createRepositoryDataFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();

  return '''

import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import '../../domain/repositories/${featureName}_repository_domain.dart';
import '../datasources/${featureName}_remote_data_source.dart';
import '../datasources/${featureName}_local_data_source.dart';
import '../models/${featureName}_model.dart';
import '../../../../core/errors/failure.dart';


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
