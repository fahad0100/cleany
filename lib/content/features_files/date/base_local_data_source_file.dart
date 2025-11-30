import 'package:cleany/base_methods/extension/extensions.dart';

String baseLocalDataSourceFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
  return '''
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import '../../../../../core/errors/failure.dart';
import '../models/${featureName}_model.dart';
import '../../../../core/errors/network_exceptions.dart';



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
