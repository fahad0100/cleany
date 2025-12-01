import 'package:cleany/utils/extension/extensions.dart';

String stateWidgetFeatureFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();

  return '''
import 'package:equatable/equatable.dart';

abstract class ${nameCab}State extends Equatable {
  const ${nameCab}State();

  @override
  List<Object?> get props => [];
}

class ${nameCab}InitialState extends ${nameCab}State {}

class ${nameCab}LoadingState extends ${nameCab}State {}

class ${nameCab}SuccessState extends ${nameCab}State {}

class ${nameCab}LoadedState extends ${nameCab}State {}

class ${nameCab}ErrorState extends ${nameCab}State {
  final String message;
  const ${nameCab}ErrorState({required this.message});
  @override
  List<Object?> get props => [message];
}

''';
}
