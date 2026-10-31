import 'dart:io';

import 'package:cleany/cleany.dart';

/// Prepares a reviewable initialization plan using a disposable project.
void main() {
  final directory = Directory.systemTemp.createTempSync('cleany_example_');
  try {
    File('${directory.path}/pubspec.yaml').writeAsStringSync('''
name: example_app
environment:
  sdk: ^3.13.0
dependencies:
  flutter:
    sdk: flutter
''');
    final project = Project(directory.path);
    final plan = Generator(project).initialize(
      appId: 'com.example.playground',
      provider: ApiProvider.retrofit,
    );
    stdout.writeln('Prepared ${plan.files.length} file changes:');
    for (final path in plan.files.keys.take(5)) {
      stdout.writeln('  $path');
    }
    stdout.writeln('The plan has not been applied.');
    // In a real project, review the plan and use the default validated workflow:
    // await GenerationTransaction(project).apply(plan);
  } finally {
    directory.deleteSync(recursive: true);
  }
}
