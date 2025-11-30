import 'package:cleany/base_methods/extension/extensions.dart';

String baseRemoteDataSourceFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();

  return '''
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import '../models/${featureName}_model.dart';

abstract class Base${nameCab}RemoteDataSource {
  Future<Future<Result<${nameCab}Model, Object>>> get$nameCab();
}


@LazySingleton(as: Base${nameCab}RemoteDataSource)
class ${nameCab}RemoteDataSource implements Base${nameCab}RemoteDataSource {
  // final DioClient _dio;
  // final SupabaseClient _supabase;
  // final GetStorage _storage;
  // final FlutterSecureStorage _secureStorage;
  // final LocalKeysService _localKeysService;
  

   // ${nameCab}LocalDataSource(
  //   this._dio,
  //   this._supabase,
  //   this._storage,
  //   this._secureStorage,
  //   this._localKeysService
  // );



    @override
  Future<Future<Result<${nameCab}Model, Object>>> get$nameCab() async {
    throw UnimplementedError();
  }
}
''';
}
