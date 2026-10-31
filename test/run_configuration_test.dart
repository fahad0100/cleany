import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:cleany/cleany.dart';
import 'package:cleany/src/registry.dart';
import 'package:cleany/src/run_configuration.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late Project project;
  setUp(() {
    directory = Directory.systemTemp.createTempSync('cleany_run_config_');
    project = Project(directory.path);
    File(project.file('pubspec.yaml')).writeAsStringSync(
      'name: fixture_app\nenvironment:\n  sdk: ^3.13.0\ndependencies:\n  flutter:\n    sdk: flutter\n',
    );
  });
  tearDown(() => directory.deleteSync(recursive: true));
  Future<void> apply(GenerationPlan plan) =>
      GenerationTransaction(project)
          .apply(plan, install: false, build: false, analyze: false);
  Future<void> initialize() =>
      apply(Generator(project).initialize(appId: 'com.example.fixture'));
  void write(String path, String source) {
    final file = File(project.file(path));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(source);
  }

  test(
    'init supplies six explicit environment/native profiles and a dev main',
    () async {
      await initialize();
      expect(project.read('lib/main.dart'), contains('cleany_dev.main()'));
      final launch = jsonDecode(project.read(launchConfigurationPath)) as Map;
      final configurations = launch['configurations'] as List;
      expect(configurations, hasLength(6));
      expect(launch['inputs'], hasLength(3));
      for (final env in ['dev', 'uat', 'prod']) {
        final plain = configurations.firstWhere(
          (row) => row['name'] == 'Cleany ${env.toUpperCase()}',
        );
        expect(plain['program'], 'lib/main_$env.dart');
        expect(plain['toolArgs'], [
          '--dart-define=API_BASE_URL=\${input:cleany_${env}_api_url}',
        ]);
        final native = configurations.firstWhere(
          (row) => row['name'] == 'Cleany ${env.toUpperCase()} (native flavor)',
        );
        expect(native['toolArgs'], containsAllInOrder(['--flavor', env]));
      }
      expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
      expect(project.read(runningGuidePath), contains('menu 10'));
      final paths = (FeatureRegistry(project).read()['project_files'] as List)
          .map((row) => row['path']);
      expect(
        paths,
        containsAll([
          launchConfigurationPath,
          runningGuidePath,
          'lib/main.dart',
        ]),
      );
    },
  );

  test('JSONC merge preserves comments, strings, custom profiles, inputs and trailing commas', () async {
    const original = r'''{
  // Keep this deployment note.
  "version": "0.2.0",
  "configurations": [
    {"name": "My App", "program": "lib/custom.dart", "type": "dart", "request": "launch", "env": {"URL": "https://example.com/a//b"}}, // Keep profile
  ],
  "inputs": [{"id": "existing", "type": "promptString", "description": "Keep me"},],
  "compounds": [],
}''';
    write(launchConfigurationPath, original);
    await initialize();
    final merged = project.read(launchConfigurationPath);
    expect(merged, contains('// Keep this deployment note.'));
    expect(merged, contains('// Keep profile'));
    expect(merged, contains('https://example.com/a//b'));
    expect(merged, contains('"id": "existing"'));
    expect(merged, contains('"compounds": []'));
    final plan = GenerationPlan(project);
    planRunConfiguration(project, plan);
    expect(plan.files, isEmpty);
    expect(project.read(launchConfigurationPath), merged);
  });

  test('Flutter scaffold main is rewired with its widget classes and exact original backup preserved', () async {
    const original =
        "import 'package:flutter/material.dart';\nvoid main() {runApp(const MainApp());}\nclass MainApp extends StatelessWidget {const MainApp({super.key}); @override Widget build(BuildContext context) { return const MaterialApp(home: Scaffold(body: Center(child: Text('Hello World!')))); }}\n";
    write('lib/main.dart', original);
    final plan = Generator(project).initialize(appId: 'com.example.fixture');
    final backups = plan.files.keys.where(
      (path) => path.startsWith('.cleany/backups/entrypoints/'),
    );
    expect(backups, hasLength(1));
    expect(plan.read(backups.single), original);
    final main = plan.read('lib/main.dart');
    expect(main, contains('Future<void> main() => cleany_dev.main()'));
    expect(main, contains('class MainApp'));
    expect(parseString(content: main).errors, isEmpty);
    await apply(plan);
    expect(FeatureRegistry(project).read()['project_files'], isNotEmpty);
    expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
  });

  test('default Flutter counter main is rewired while all widget declarations remain usable', () async {
    final original = File('test/fixtures/flutter_counter_main.dart.txt')
        .readAsStringSync();
    write('lib/main.dart', original);
    await initialize();
    final main = project.read('lib/main.dart');
    expect(main, contains('cleany_dev.main()'));
    for (final type in [
      'class MyApp',
      'class MyHomePage',
      'class _MyHomePageState',
    ]) {
      expect(main, contains(type));
    }
    expect(parseString(content: main).errors, isEmpty);
  });

  test('customizing a child of the default Flutter counter keeps the original entrypoint', () async {
    final original = File('test/fixtures/flutter_counter_main.dart.txt')
        .readAsStringSync()
        .replaceFirst('int _counter = 0;', 'int _counter = 100;');
    write('lib/main.dart', original);
    await initialize();
    expect(project.read('lib/main.dart'), original);
    expect(
      Directory(project.file('.cleany/backups/entrypoints')).existsSync(),
      isFalse,
    );
  });

  test(
    'custom entrypoint and same-name customized launch profile are preserved',
    () async {
      const main = "void main() { print('custom startup'); }\n";
      write('lib/main.dart', main);
      write(
        launchConfigurationPath,
        '{"configurations":[{"name":"Cleany DEV","program":"lib/custom.dart","type":"dart","request":"launch"}]}',
      );
      await initialize();
      expect(project.read('lib/main.dart'), main);
      final launch = jsonDecode(project.read(launchConfigurationPath)) as Map;
      expect(
        (launch['configurations'] as List).first['program'],
        'lib/custom.dart',
      );
      expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
    },
  );

  test('a customized MyApp using only Flutter imports is never treated as the empty scaffold', () async {
    const main =
        "import 'package:flutter/material.dart';\nvoid main() { runApp(const MainApp()); }\nclass MainApp extends StatelessWidget { const MainApp({super.key}); @override Widget build(BuildContext context) => const MaterialApp(home: Text('Real application')); }\n";
    write('lib/main.dart', main);
    await initialize();
    expect(project.read('lib/main.dart'), main);
    expect(
      Directory(project.file('.cleany/backups/entrypoints')).existsSync(),
      isFalse,
    );
    expect(
      project.read(launchConfigurationPath),
      contains('lib/main_prod.dart'),
    );
  });

  test('invalid JSONC refuses initialization before source writes', () {
    for (final source in [
      '{"configurations":{}}',
      '{/* unclosed',
      '{"configurations": [], "configurations": []}',
    ]) {
      write(launchConfigurationPath, source);
      expect(
        () => Generator(project).initialize(appId: 'com.example.fixture'),
        throwsA(isA<GenerationException>()),
      );
      expect(Directory(project.file('lib/app')).existsSync(), isFalse);
      expect(project.read(launchConfigurationPath), source);
    }
  });

  test('Doctor repairs missing profile/input entries and a legacy Flutter main without rewriting custom JSONC', () async {
    await initialize();
    write(
      launchConfigurationPath,
      '{\n// My editor note\n"configurations":[]\n}',
    );
    write(
      'lib/main.dart',
      "import 'package:flutter/material.dart';\nvoid main() { runApp(const MainApp()); }\nclass MainApp extends StatelessWidget {const MainApp({super.key}); @override Widget build(BuildContext context) { return const MaterialApp(home: Scaffold(body: Center(child: Text('Hello World!')))); }}\n",
    );
    File(project.file(runningGuidePath)).deleteSync();
    await apply(ProjectDoctor(project).inspect().plan);
    expect(
      project.read(launchConfigurationPath),
      contains('// My editor note'),
    );
    expect(project.read('lib/main.dart'), contains('cleany_dev.main()'));
    expect(File(project.file(runningGuidePath)).existsSync(), isTrue);
    expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
  });

  test('Doctor updates old generated native setup references and preserves customized run guides', () async {
    await initialize();
    final current = project.read(runningGuidePath);
    write(runningGuidePath, current.replaceAll('menu 10', 'menu 12'));
    await apply(ProjectDoctor(project).inspect().plan);
    expect(project.read(runningGuidePath), current);
    final custom = '$current\nTeam-specific instructions.\n';
    write(runningGuidePath, custom);
    expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
    expect(project.read(runningGuidePath), custom);
  });

  test(
    'reset preserves custom profiles and tracks run configuration ownership',
    () async {
      await initialize();
      final launch = jsonDecode(project.read(launchConfigurationPath)) as Map;
      (launch['configurations'] as List).add({
        'name': 'Personal',
        'program': 'lib/main.dart',
        'type': 'dart',
        'request': 'launch',
      });
      write(launchConfigurationPath, jsonEncode(launch));
      final before = project.read(launchConfigurationPath);
      await apply(ProjectMaintenance(project).reset());
      expect(project.read(launchConfigurationPath), before);
      expect(
        (FeatureRegistry(project).read()['project_files'] as List).map(
          (row) => row['path'],
        ),
        contains(launchConfigurationPath),
      );
      expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
    },
  );
}
