import 'package:cleany/base_methods/extension/extensions.dart';

String screenPageFile({required String featureName}) {
  return '''
import 'package:flutter/material.dart';

class ${featureName.toCapitalized().toCapitalizeSecondWord()}Screen extends StatelessWidget {
  const ${featureName.toCapitalized().toCapitalizeSecondWord()}Screen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('${featureName.toCapitalized().toCapitalizeSecondWord()} Screen')),
      body: Column(children: [
          
        ],
      ),
    );
  }
}
''';
}
