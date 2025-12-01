import 'package:cleany/base_methods/extension/extensions.dart';
import 'package:cleany/base_methods/extension/file_modifier.dart';

String cubitFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
  final projectName = FileModifier.getProjectName();

  return '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:$projectName/features/$nameCab/domain/use_cases/${nameCab}_use_case.dart';
import 'package:$projectName/features/$nameCab/presentation/cubit/${nameCab}_state.dart';

class ${nameCab}Cubit extends Cubit<${nameCab}State> {
  final ${nameCab}UseCase _${nameCab.toLowerFirst()}UseCase;

  ${nameCab}Cubit(this._${nameCab.toLowerFirst()}UseCase) : super(${nameCab}InitialState());

  Future<void> get${nameCab}Method() async {
    final result = await _${nameCab.toLowerFirst()}UseCase.get$nameCab();
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
