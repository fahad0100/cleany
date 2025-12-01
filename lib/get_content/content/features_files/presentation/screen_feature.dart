import 'package:cleany/utils/extension/extensions.dart';

String screenPageFeatureFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();

  return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_app/features/$featureName/presentation/cubit/${featureName}_cubit.dart';

class ${nameCab}FeatureScreen extends StatelessWidget {
  const ${nameCab}FeatureScreen({super.key});
  @override
  Widget build(BuildContext context) {
      final _ = context.read<${nameCab}Cubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('$nameCab Feature Screen')),
      body: Column(children: [
          
        ],
      ),
    );
  }
}
''';
}
