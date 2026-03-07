import 'package:cleany/utils/extension/extensions.dart';

String diFeatureFile({
  required String featureName,
  String? ownFeaturesName,
  required bool isSub,
}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
  final ownFeaturesNameCab = ownFeaturesName != null
      ? ownFeaturesName.toCapitalized().toCapitalizeSecondWord()
      : null;

  return '''
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '${featureName}_di.config.dart'; 

@InjectableInit(
  initializerName: 'init$nameCab${isSub == true ? 'Sub' : ''}${ownFeaturesNameCab != null ? 'For$ownFeaturesNameCab' : ''}',
   // Optional: specify the directory to scan for injectable annotations
  generateForDir: ['lib/features/${ownFeaturesName != null
      ? '$ownFeaturesName/sub/'
      : isSub
      ? 'sub/'
      : ''}$featureName'],
)
void configure$nameCab${isSub == true ? 'Sub' : ''}${ownFeaturesNameCab != null ? 'For$ownFeaturesNameCab' : ''}(GetIt getIt) {
  getIt.init$nameCab${isSub == true ? 'Sub' : ''}${ownFeaturesNameCab != null ? 'For$ownFeaturesNameCab' : ''}();
}
''';
}
