import 'package:cleany/base_methods/extension/extensions.dart';
import 'package:cleany/base_methods/extension/file_modifier.dart';

String baseLocalDataSourceFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
  final projectName = FileModifier.getProjectName();

  return '''
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:$projectName/core/errors/failure.dart';
import 'package:$projectName/core/errors/network_exceptions.dart';
import 'package:$projectName/features/testa/data/models/${featureName}_model.dart';




abstract class Base${nameCab}LocalDataSource {

   Future<Result<${nameCab}Model, Failure>> getCached$nameCab();

}


@LazySingleton(as: Base${nameCab}LocalDataSource)
class ${nameCab}LocalDataSource implements Base${nameCab}LocalDataSource {
  // final GetStorage _storage;
  // final FlutterSecureStorage _secureStorage;
  // final LocalKeysService _localKeysService;

  

   // ${nameCab}LocalDataSource(
  //   this._storage,
  //   this._secureStorage,
  //   this._localKeysService
  // );


  @override
  Future<Result<${nameCab}Model, Failure>> getCached$nameCab() async {
  try {
      return Success(${nameCab}Model(id: "d"));
    } catch (error) {
      return Error(FailureExceptions.getDioException(error));
    }
  }
}
''';
}
