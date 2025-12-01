import 'package:cleany/utils/extension/extensions.dart';

String screenPageFeatureFile({required String featureName}) {
  final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();

  return '''
import 'package:flutter/material.dart';

class ${nameCab}FeatureScreen extends StatelessWidget {
  const ${nameCab}FeatureScreen({super.key});
  @override
  Widget build(BuildContext context) {
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
