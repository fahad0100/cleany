import 'package:cleany/utils/extension/extensions.dart';
import 'package:cleany/utils/file_modifier.dart';

String createRepositoryDataScreenFeatureFile({
  required String featureName,
  String? ownFeaturesName,
  required bool isSub,
}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
  final projectName = FileModifier.getProjectName();

  return '''

import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:$projectName/core/errors/network_exceptions.dart';
import 'package:$projectName/core/errors/failure.dart';
import 'package:$projectName/features/${ownFeaturesName != null
      ? '$ownFeaturesName/sub/'
      : isSub
      ? 'sub/'
      : ''}$featureName/domain/entities/${featureName}_entity.dart';

import 'package:$projectName/features/${ownFeaturesName != null
      ? '$ownFeaturesName/sub/'
      : isSub
      ? 'sub/'
      : ''}$featureName/data/datasources/${featureName}_remote_data_source.dart';
import 'package:$projectName/features/${ownFeaturesName != null
      ? '$ownFeaturesName/sub/'
      : isSub
      ? 'sub/'
      : ''}$featureName/data/models/${featureName}_model.dart';
import 'package:$projectName/features/${ownFeaturesName != null
      ? '$ownFeaturesName/sub/'
      : isSub
      ? 'sub/'
      : ''}$featureName/domain/repositories/${featureName}_repository_domain.dart';

@LazySingleton(as: ${nameCab}RepositoryDomain)
class ${nameCab}RepositoryData implements ${nameCab}RepositoryDomain{
  final Base${nameCab}RemoteDataSource remoteDataSource;


  ${nameCab}RepositoryData(this.remoteDataSource);

@override
  Future<Result<${nameCab}Entity, Failure>> get$nameCab() async {
    try {
      final response = await remoteDataSource.get$nameCab();
      return Success(response.toEntity());
    } catch (error) {
      return Error(FailureExceptions.getException(error));
    }
  }
}
''';
}
