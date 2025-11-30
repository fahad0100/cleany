import 'package:cleany/base_methods/extension/extensions.dart';

String cubitFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();

  return '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/${featureName}_use_case.dart';
import '${featureName}_state.dart';

class ${nameCab}Cubit extends Cubit<${nameCab}State> {
  final ${nameCab}UseCase _${nameCab}UseCase;

  ${nameCab}Cubit(this._${nameCab}UseCase) : super(${nameCab}InitialState());

  Future<void> get${nameCab}Method() async {
    final result = await _${nameCab}UseCase.get$nameCab();
    result.when(
      (success) {
        //here is when success result
      },
      (whenError) {
       //here is when error result
      },
    );
  }

  @override
  Future<void> close() {
    //here is when close cubit
    return super.close();
  }
}
''';
}
