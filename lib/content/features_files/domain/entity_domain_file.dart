import 'package:cleany/base_methods/extension/extensions.dart';

String entityDomainFile({required String featureName}) {
  return '''
import 'package:equatable/equatable.dart';

class ${featureName.toCapitalized().toCapitalizeSecondWord()}Entity extends Equatable {
  final String id;

  const ${featureName.toCapitalized().toCapitalizeSecondWord()}Entity({
    required this.id,
  });

  @override
  List<Object?> get props => [id];
}
''';
}
