import 'package:cleany/utils/extension/extensions.dart';

String entityDomainScreenFeatureFile({
  required String featureName,
  String? ownFeaturesName,
}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();

  return '''
import 'package:equatable/equatable.dart';

class ${nameCab}Entity extends Equatable {
  final int id;
  final String firstName;
  final String lastName;

  const ${nameCab}Entity({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object?> get props => [firstName, lastName, id];
}
''';
}
