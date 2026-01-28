import 'package:cleany/utils/extension/extensions.dart';
import 'package:cleany/utils/file_modifier.dart';

String baseRemoteDataSourceWidgetFeatureFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
  final projectName = FileModifier.getProjectName();

  return '''
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:$projectName/features/sub/$featureName/data/models/${featureName}_model.dart';
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
  

   // ${nameCab}RemoteDataSource(
  //   this._dio,
  //   this._supabase,
  //   this._storage,
  //   this._secureStorage,
  //   this._localKeysService
  // );



    @override
  Future<Result<${nameCab}Model, Failure>> get$nameCab() async {
    try {
      return Success(${nameCab}Model(id: "d"));
    } catch (error) {
      return Error(FailureExceptions.getException(error));
    }
  }
}
''';
}
