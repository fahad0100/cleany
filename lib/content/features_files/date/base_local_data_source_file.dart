import 'package:cleany/base_methods/extension/extensions.dart';

String baseLocalDataSourceFile({required String featureName}) {
  return '''
import 'package:injectable/injectable.dart';
import '../models/${featureName}_model.dart';


abstract class Base${featureName.toCapitalized().toCapitalizeSecondWord()}LocalDataSource {
  Future<${featureName.toCapitalized().toCapitalizeSecondWord()}Model> getCached${featureName.toCapitalized().toCapitalizeSecondWord()}();
}


@LazySingleton(as: Base${featureName.toCapitalized().toCapitalizeSecondWord()}LocalDataSource)
class ${featureName.toCapitalized().toCapitalizeSecondWord()}LocalDataSource implements Base${featureName.toCapitalized().toCapitalizeSecondWord()}LocalDataSource {
  // final SharedPreferences _sharedPreferences;
  
  // ${featureName.toCapitalized().toCapitalizeSecondWord()}LocalDataSource({required this._sharedPreferences});

  @override
  Future<${featureName.toCapitalized().toCapitalizeSecondWord()}Model> getCached${featureName.toCapitalized().toCapitalizeSecondWord()}() async {

    throw UnimplementedError();
  }
}
''';
}
