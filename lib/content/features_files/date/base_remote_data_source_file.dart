import 'package:cleany/base_methods/extension/extensions.dart';
import 'package:cleany/base_methods/extension/file_modifier.dart';

String baseRemoteDataSourceFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
  final projectName = FileModifier.getProjectName();

  return '''
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:$projectName/features/$featureName/data/models/${featureName}_model.dart';
import 'package:$projectName/core/errors/failure.dart';
import 'package:$projectName/core/errors/network_exceptions.dart';


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
