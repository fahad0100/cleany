import 'package:cleany/base_methods/extension/extensions.dart';

String baseRemoteDataSourceFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();

  return '''
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import '../models/${featureName}_model.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/network_exceptions.dart';


abstract class Base${nameCab}RemoteDataSource {
  Future<Result<${nameCab}Model, Failure>> get$nameCab();
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
  Future<Result<${nameCab}Model, Failure>> get$nameCab() async {
    try {
      return Success(TestaModel(id: "d"));
    } catch (error) {
      return Error(FailureExceptions.getDioException(error));
    }
  }
}
''';
}
