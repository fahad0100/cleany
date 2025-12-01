import 'package:cleany/base_methods/extension/extensions.dart';
import 'package:cleany/base_methods/extension/file_modifier.dart';

String widgetPageFeatureFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
  final projectName = FileModifier.getProjectName();

  return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:$projectName/features/sub/$featureName/presentation/cubit/${featureName}_cubit.dart';
import 'package:$projectName/features/sub/sub/$featureName/presentation/cubit/${featureName}_cubit.dart';


class ${nameCab}FeatureWidget extends StatelessWidget {
  const ${nameCab}FeatureWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ${nameCab}Cubit(GetIt.I.get()),
      child: Builder(
        builder: (context) {
          final _ = context.read<LoginCubit>();
          return Column(children: [
              
              ],
            );
        },
      ),
    );
  }
}
''';
}
