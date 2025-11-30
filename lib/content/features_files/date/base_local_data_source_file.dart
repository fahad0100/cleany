import 'package:cleany/base_methods/extension/extensions.dart';

String baseLocalDataSourceFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
  return '''
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import '../../../../../core/errors/failure.dart';
import '../models/${featureName}_model.dart';



abstract class Base${nameCab}LocalDataSource {

  Future<Future<Result<${nameCab}Model, Failure>>> getCached$nameCab();

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
  Future<Future<Result<${nameCab}Model, Failure>>> getCachedLogin() async {
    throw UnimplementedError();
  }
}
''';
}
