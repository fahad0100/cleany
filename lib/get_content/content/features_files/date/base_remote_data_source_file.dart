import 'package:cleany/utils/extension/extensions.dart';
import 'package:cleany/utils/file_modifier.dart';

String baseRemoteDataScreenFeatureFile({
  required String featureName,
  String? ownFeaturesName,
  required bool isSub,
}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
  final projectName = FileModifier.getProjectName();

  return '''
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:$projectName/core/services/local_keys_service.dart';
import 'package:$projectName/features/${ownFeaturesName != null
      ? '$ownFeaturesName/sub/'
      : isSub
      ? 'sub/'
      : ''}$featureName/data/models/${featureName}_model.dart';
import 'package:$projectName/core/errors/network_exceptions.dart';


abstract class Base${nameCab}RemoteDataSource {
  Future<${nameCab}Model> get$nameCab();
}


@LazySingleton(as: Base${nameCab}RemoteDataSource)
class ${nameCab}RemoteDataSource implements Base${nameCab}RemoteDataSource {
 
  final SupabaseClient _supabase;
  final LocalKeysService _localKeysService;
  
  

   ${nameCab}RemoteDataSource(this._localKeysService, this._supabase);



    @override
  Future<${nameCab}Model> get$nameCab() async {
    try {
      return ${nameCab}Model(id: 1, firstName: "Last Name", lastName: "First Name");
    } catch (error) {
     throw FailureExceptions.getException(error);
    }
  }
}
''';
}
