import 'package:cleany/utils/extension/extensions.dart';
import 'package:cleany/utils/file_modifier.dart';

String widgetPageFeatureFile({
  required String featureName,
  String? ownFeaturesName,
  required bool isSub,
}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
  final projectName = FileModifier.getProjectName();

  return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:$projectName/features/${ownFeaturesName != null
      ? '$ownFeaturesName/sub'
      : isSub
      ? 'sub'
      : ''}/$featureName/presentation/cubit/${featureName}_cubit.dart';


class ${nameCab}FeatureWidget extends StatelessWidget {
  const ${nameCab}FeatureWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ${nameCab}Cubit(GetIt.I.get()),
      child: Builder(
        builder: (context) {
          final _ = context.read<${nameCab}Cubit>();
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
