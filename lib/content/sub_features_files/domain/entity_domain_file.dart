import 'package:cleany/base_methods/extension/extensions.dart';

String entityDomainWidgetFeatureFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();

  return '''
import 'package:equatable/equatable.dart';

class ${nameCab}Entity extends Equatable {
  final String id;

  const ${nameCab}Entity({
    required this.id,
  });

  @override
  List<Object?> get props => [id];
}
''';
}
