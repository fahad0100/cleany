import 'dart:io';

import 'package:cleany/cleany.dart';
import 'package:cleany/src/responsive_support.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

void main() {
  late Directory directory;
  late Project project;
  late Generator generator;
  Future<void> apply(GenerationPlan plan) async {
    await GenerationTransaction(project)
        .apply(plan, install: false, build: false, analyze: false);
  }

  setUp(() async {
    directory = Directory.systemTemp.createTempSync('cleany_responsive_');
    project = Project(directory.path);
    File(project.file('pubspec.yaml')).writeAsStringSync(
      'name: theme_fixture\nenvironment:\n  sdk: ^3.13.0\ndependencies:\n  flutter:\n    sdk: flutter\n',
    );
    generator = Generator(project);
    await apply(generator.initialize(appId: 'com.example.theme'));
  });
  tearDown(() => directory.deleteSync(recursive: true));

  test('init pins Sizer and Doctor restores missing themes while preserving colors', () async {
    expect(
      (loadYaml(project.read('pubspec.yaml')) as Map)['dependencies']['sizer'],
      '3.1.3',
    );
    const colors = 'lib/core/theme/app_colors.dart';
    final custom = project.read(colors).replaceAll('0xFF2563EB', '0xFF123456');
    File(project.file(colors)).writeAsStringSync(custom);
    File(project.file('lib/core/theme/app_text_theme.dart')).deleteSync();
    File(project.file('lib/core/theme/app_theme.dart')).deleteSync();
    final manifest = YamlEditor(project.read('pubspec.yaml'))
      ..remove(['dependencies', 'sizer']);
    File(project.file('pubspec.yaml')).writeAsStringSync(manifest.toString());
    final repair = ProjectDoctor(project).inspect().plan;
    expect(repair.files.containsKey(colors), isFalse);
    expect(
      repair.files.keys,
      containsAll([
        'lib/core/theme/app_text_theme.dart',
        'lib/core/theme/app_theme.dart',
      ]),
    );
    await apply(repair);
    expect(project.read(colors), custom);
    expect(
      (loadYaml(project.read('pubspec.yaml')) as Map)['dependencies']['sizer'],
      '3.1.3',
    );
    expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
  });

  test(
    'reset regenerates the three themes, Sizer root and dependency together',
    () async {
      final manifest = YamlEditor(project.read('pubspec.yaml'))
        ..remove(['dependencies', 'sizer']);
      File(project.file('pubspec.yaml')).writeAsStringSync(manifest.toString());
      await apply(ProjectMaintenance(project).reset());
      for (final file in ['app_colors', 'app_text_theme', 'app_theme']) {
        expect(
          File(project.file('lib/core/theme/$file.dart')).existsSync(),
          isTrue,
        );
      }
      expect(project.read('lib/app/app.dart'), contains('=> Sizer('));
      expect(
        (loadYaml(project.read('pubspec.yaml'))
            as Map)['dependencies']['sizer'],
        '3.1.3',
      );
      expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
    },
  );

  test(
    'Doctor wraps a legacy customized app before restoring responsive themes',
    () async {
      const path = 'lib/app/app.dart';
      File(project.file(path)).writeAsStringSync(legacyApp);
      File(project.file('lib/core/theme/app_theme.dart')).deleteSync();
      final repair = ProjectDoctor(project).inspect().plan;
      final app = repair.read(path);
      expect(app, contains('cleany_sizer.Sizer('));
      expect(app, contains("title: 'Custom title'"));
      expect(app, contains('themeMode: ThemeMode.light'));
      expect(app, contains('routerConfig: router'));
      expect(app, contains('theme: AppTheme.light'));
      expect(app, contains('// Preserve developer settings.'));
      await apply(repair);
      expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
    },
  );

  test('existing prefixed Sizer roots remain byte-for-byte unchanged', () {
    const path = 'lib/app/app.dart';
    final source = project
        .read(path)
        .replaceAll(
          "import 'package:sizer/sizer.dart';",
          "import 'package:sizer/sizer.dart' as adaptive;",
        )
        .replaceAll('=> Sizer(', '=> adaptive.Sizer(');
    File(project.file(path)).writeAsStringSync(source);
    final plan = GenerationPlan(project);
    expect(planSizerIntegration(plan), isFalse);
    expect(plan.files, isEmpty);
  });
}

const legacyApp = '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
class App extends StatelessWidget {
  const App({super.key, required this.router});
  final GoRouter router;
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    // Preserve developer settings.
    title: 'Custom title', routerConfig: router,
    theme: AppTheme.light, themeMode: ThemeMode.light,
  );
}
''';
