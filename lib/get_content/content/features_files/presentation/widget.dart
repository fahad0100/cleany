import 'package:cleany/utils/extension/extensions.dart';

String widgetScreenFeatureFile({required String featureName}) {
  return '''
 import 'package:flutter/material.dart';

class ${featureName.toCapitalized().toCapitalizeSecondWord()}Widget extends StatelessWidget {
  const ${featureName.toCapitalized().toCapitalizeSecondWord()}Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
  }
''';
}
