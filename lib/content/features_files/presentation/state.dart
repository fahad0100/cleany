import 'package:cleany/base_methods/extension/extensions.dart';

String stateFile({required String featureName}) {
  return '''
import 'package:equatable/equatable.dart';

abstract class ${featureName.toCapitalized().toCapitalizeSecondWord()}State extends Equatable {
  const ${featureName.toCapitalized().toCapitalizeSecondWord()}State();

  @override
  List<Object?> get props => [];
}

class ${featureName.toCapitalized().toCapitalizeSecondWord()}InitialState extends ${featureName.toCapitalized().toCapitalizeSecondWord()}State {}

class ${featureName.toCapitalized().toCapitalizeSecondWord()}LoadingState extends ${featureName.toCapitalized().toCapitalizeSecondWord()}State {}

class ${featureName.toCapitalized().toCapitalizeSecondWord()}LoadedState extends ${featureName.toCapitalized().toCapitalizeSecondWord()}State {}

class ${featureName.toCapitalized().toCapitalizeSecondWord()}ErrorState extends ${featureName.toCapitalized().toCapitalizeSecondWord()}State {
  final String message;
  const ${featureName.toCapitalized().toCapitalizeSecondWord()}ErrorState({required this.message});
  @override
  List<Object?> get props => [message];
}
''';
}
