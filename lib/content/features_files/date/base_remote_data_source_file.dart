import 'package:cleany/base_methods/extension/extensions.dart';

String baseRemoteDataSourceFile({required String featureName}) {
  return '''
import 'package:injectable/injectable.dart';
import '../models/${featureName}_model.dart';

abstract class Base${featureName.toCapitalized().toCapitalizeSecondWord()}RemoteDataSource {
    Future<${featureName.toCapitalized().toCapitalizeSecondWord()}Model> get${featureName.toCapitalized().toCapitalizeSecondWord()}();
}


@LazySingleton(as: Base${featureName.toCapitalized().toCapitalizeSecondWord()}RemoteDataSource)
class ${featureName.toCapitalized().toCapitalizeSecondWord()}RemoteDataSource implements Base${featureName.toCapitalized().toCapitalizeSecondWord()}RemoteDataSource {
  // final DioClient _dio;
  // final SupabaseClient _supabase;
  
  // ${featureName.toCapitalized().toCapitalizeSecondWord()}RemoteDataSource(required this._dio,required this._supabase);

  @override
  Future<${featureName.toCapitalized().toCapitalizeSecondWord()}Model> get${featureName.toCapitalized().toCapitalizeSecondWord()}() async {

    throw UnimplementedError();
  }
}
''';
}
