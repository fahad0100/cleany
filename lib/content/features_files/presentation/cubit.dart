import 'package:cleany/base_methods/extension/extensions.dart';

String cubitFile({required String featureName}) {
  return '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/${featureName}_use_case.dart';

import '${featureName}_state.dart';

class ${featureName.toCapitalized().toCapitalizeSecondWord()}Cubit extends Cubit<${featureName.toCapitalized().toCapitalizeSecondWord()}State> {
  final ${featureName.toCapitalized().toCapitalizeSecondWord()}UseCase ${featureName.toCapitalizeSecondWord()}UseCase;

  ${featureName.toCapitalized().toCapitalizeSecondWord()}Cubit({required this.${featureName}UseCase}) : super(${featureName.toCapitalized().toCapitalizeSecondWord()}InitialState());

  @override
  Future<void> close() {
      //here is when close cubit
    return super.close();
  }
}
''';
}
