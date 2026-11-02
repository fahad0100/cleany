import 'dart:convert';
import 'dart:io';

import 'package:cleany/cleany.dart';
import 'package:cleany/src/cli.dart';
import 'package:cleany/src/app_config_editor.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  late Directory directory;
  late Project project;
  late Generator generator;
  Future<void> apply(GenerationPlan plan) async {
    await GenerationTransaction(project)
        .apply(plan, install: false, build: false, analyze: false);
  }

  setUp(() async {
    directory = Directory.systemTemp.createTempSync('cleany_app_config_');
    project = Project(directory.path);
    File(project.file('pubspec.yaml')).writeAsStringSync(
      'name: config_fixture\nenvironment:\n  sdk: ^3.13.0\ndependencies:\n  flutter:\n    sdk: flutter\n',
    );
    generator = Generator(project);
    await apply(generator.initialize(appId: 'com.example.config'));
  });
  tearDown(() => directory.deleteSync(recursive: true));

  test(
    'init, Doctor restoration and reset expose the DI AppConfig to pages',
    () async {
      const path = 'lib/app/bootstrap.dart';
      void expectConfigProvider(String source) {
        expect(source, contains('MultiRepositoryProvider('));
        expect(source, contains('RepositoryProvider<AppConfig>.value('));
        expect(source, contains('value: container<AppConfig>()'));
        expect(source, contains('disposeRouter: router.dispose'));
      }

      expectConfigProvider(project.read(path));
      File(project.file(path)).deleteSync();
      final repair = ProjectDoctor(project).inspect().plan;
      expectConfigProvider(repair.read(path));
      await apply(repair);
      expectConfigProvider(ProjectMaintenance(project).reset().read(path));
      expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
    },
  );

  test(
    'storage keeps the public API at its root and helpers in storage_extension',
    () async {
      const helperNames = [
        'database_factory_io',
        'database_factory_web',
        'database_factory',
        'storage_cipher',
        'storage_exceptions',
        'storage_key_store',
      ];
      for (final name in helperNames) {
        expect(
          File(project.file('lib/core/storage/storage_extension/$name.dart'))
              .existsSync(),
          isTrue,
        );
        expect(
          File(project.file('lib/core/storage/$name.dart')).existsSync(),
          isFalse,
        );
      }
      expect(
        File(project.file('lib/core/storage/local_keys.dart')).existsSync(),
        isTrue,
      );
      expect(
        project.read('lib/core/storage/app_local_storage.dart'),
        contains("import 'storage_extension/database_factory.dart'"),
      );
      const missing =
          'lib/core/storage/storage_extension/database_factory_web.dart';
      File(project.file(missing)).deleteSync();
      final plan = ProjectDoctor(project).inspect().plan;
      expect(plan.files, contains(missing));
      await apply(plan);
      expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
    },
  );

  test('adds typed fields and exact YAML values without embedding values in Dart or registry', () async {
    final before = project.read(appConfigPath);
    final values = {
      'dev': '  quote " and \$dollar: مرحبًا\nline2  ',
      'uat': 'https://uat.example.com?x=1',
      'prod': '',
    };
    final plan = AppConfigValues(project)
        .add(key: 'SUPPORT_EMAIL', values: values);
    expect(project.read(appConfigPath), before);
    expect(
      discoverConfigValues(plan.read(appConfigPath)).map((value) => value.key),
      contains('SUPPORT_EMAIL'),
    );
    expect(plan.read(appConfigPath), contains('final String supportEmail'));
    expect(plan.read(appConfigPath), isNot(contains(values['uat']!)));
    await apply(plan);
    for (final environment in values.keys) {
      final yaml =
          loadYaml(project.read('config/flavors/$environment.yaml')) as Map;
      expect(yaml['support_email'], values[environment]);
      expect(yaml['db_secret_key'], 'pass_key_storage');
    }
    final registry = generator.readRegistry();
    expect(registry['app_config_values'], [
      {'key': 'SUPPORT_EMAIL'},
    ]);
    expect(jsonEncode(registry), isNot(contains(values['uat']!)));
    expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
  });

  test(
    'validates reserved/invalid/duplicate keys before changing files',
    () async {
      final manager = AppConfigValues(project);
      final before = project.read(appConfigPath);
      for (final key in [
        'bad-key',
        'lower_case',
        'API_BASE_URL',
        'DB_SECRET_KEY',
        'IS_DEBUG',
        'CLASS',
        '1_BAD',
      ]) {
        expect(
          () => manager.add(
            key: key,
            values: {'dev': 'a', 'uat': 'b', 'prod': 'c'},
          ),
          throwsA(isA<GenerationException>()),
          reason: key,
        );
      }
      expect(project.read(appConfigPath), before);
      File(project.file(appConfigPath)).writeAsStringSync(
        before.replaceFirst('class AppConfig {', '''class AppConfig {
  static const existingAlias = String.fromEnvironment('CUSTOM_ALIAS');
'''),
      );
      expect(
        () => manager.validateNewKey('CUSTOM_ALIAS'),
        throwsA(isA<GenerationException>()),
      );
      File(project.file(appConfigPath)).writeAsStringSync(before);
      await apply(
        manager.add(
          key: 'SUPPORT_EMAIL',
          values: {'dev': 'a', 'uat': 'b', 'prod': 'c'},
        ),
      );
      expect(
        () => manager.validateNewKey('SUPPORT_EMAIL'),
        throwsA(isA<GenerationException>()),
      );
    },
  );

  test('Doctor recovers schema and missing AppConfig; reset preserves configuration choices', () async {
    await apply(
      AppConfigValues(project).add(
        key: 'SUPPORT_EMAIL',
        values: {'dev': 'a', 'uat': 'b', 'prod': 'c'},
      ),
    );
    File(project.file(registryPath)).deleteSync();
    await apply(ProjectDoctor(project).inspect().plan);
    expect(generator.readRegistry()['app_config_values'], [
      {'key': 'SUPPORT_EMAIL'},
    ]);
    File(project.file(appConfigPath)).deleteSync();
    await apply(ProjectDoctor(project).inspect().plan);
    expect(project.read(appConfigPath), contains('final String supportEmail'));
    await apply(ProjectMaintenance(project).reset());
    expect(
      (loadYaml(project.read('config/flavors/uat.yaml'))
          as Map)['support_email'],
      'b',
    );
    expect(project.read(appConfigPath), contains('final String supportEmail'));
    expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
  });

  test(
    'a failed multi-file update rolls back configuration and registry together',
    () async {
      final manager = AppConfigValues(project);
      final paths = [
        appConfigPath,
        registryPath,
        for (final e in ['dev', 'uat', 'prod']) 'config/flavors/$e.yaml',
      ];
      final before = {for (final path in paths) path: project.read(path)};
      final plan = manager.add(
        key: 'SUPPORT_EMAIL',
        values: {'dev': 'a', 'uat': 'b', 'prod': 'c'},
      );
      await expectLater(
        GenerationTransaction(project).apply(
          plan,
          install: false,
          build: false,
          analyze: false,
          beforeWrite: (path) {
            if (path.endsWith('/uat.yaml')) throw StateError('write failed');
          },
        ),
        throwsA(isA<OperationFailure>()),
      );
      for (final path in paths) {
        expect(project.read(path), before[path], reason: path);
      }
    },
  );

  test(
    'Doctor keeps legacy projects free of unconfigured storage integrations',
    () async {
      final registry = generator.readRegistry();
      registry['local_storage'] = false;
      for (final record in List<Map<String, dynamic>>.from(
        registry['project_files'] as List,
      )) {
        final path = record['path'] as String;
        if (path.startsWith('lib/core/storage/') ||
            path == 'LOCAL_STORAGE.md') {
          File(project.file(path)).deleteSync();
          (registry['project_files'] as List).remove(record);
        }
      }
      File(project.file(registryPath)).writeAsStringSync(jsonEncode(registry));
      for (final path in [
        'lib/app/bootstrap.dart',
        'lib/app/di/injection.dart',
      ]) {
        File(project.file(path)).deleteSync();
      }
      final plan = ProjectDoctor(project).inspect().plan;
      expect(
        plan.read('lib/app/bootstrap.dart'),
        isNot(contains('flavor.values')),
      );
      expect(
        plan.read('lib/app/bootstrap.dart'),
        isNot(contains('RepositoryProvider<AppLocalStorage>')),
      );
      expect(
        plan.read('lib/app/di/injection.dart'),
        isNot(contains('AppLocalStorage')),
      );
      expect(
        plan.files.keys.any((path) => path.startsWith('lib/core/storage/')),
        isFalse,
      );
    },
  );

  test(
    'reset archives malformed flavor YAML and restores safe defaults',
    () async {
      File(project.file('config/flavors/uat.yaml'))
          .writeAsStringSync('environment: [broken');
      final plan = ProjectMaintenance(project).reset();
      expect(
        (loadYaml(plan.read('config/flavors/uat.yaml'))
            as Map)['db_secret_key'],
        'pass_key_storage',
      );
      expect(
        plan.files.entries.any(
          (entry) =>
              entry.key.contains('/backups/') &&
              entry.value.after != null &&
              utf8.decode(entry.value.after!) == 'environment: [broken',
        ),
        isTrue,
      );
    },
  );

  test('menu 11 retries a bad key and applies or cancels through the normal review', () async {
    final answers = [
      '11',
      'bad-key',
      'SUPPORT_EMAIL',
      'dev-value',
      'uat-value',
      'prod-value',
      '2',
      '0',
    ].iterator;
    final output = StringBuffer();
    final before = project.read(appConfigPath);
    expect(
      await runCli(
        [],
        projectRoot: project.root,
        output: output,
        useColor: false,
        readLine: () => answers.moveNext() ? answers.current : null,
      ),
      0,
    );
    expect(output.toString(), contains('UPPER_SNAKE_CASE'));
    expect(output.toString(), contains('11. App config value'));
    expect(output.toString(), contains('Apply and validate'));
    expect(output.toString(), isNot(contains('dev-value')));
    expect(project.read(appConfigPath), before);
    final applyAnswers = [
      '11',
      'SUPPORT_EMAIL',
      'dev-value',
      'uat-value',
      'prod-value',
      '1',
      '0',
    ].iterator;
    expect(
      await runCli(
        [],
        projectRoot: project.root,
        output: StringBuffer(),
        useColor: false,
        readLine: () => applyAnswers.moveNext() ? applyAnswers.current : null,
        executor: (_, _, _) async => const CommandResult(0, '', ''),
      ),
      0,
    );
    expect(project.read(appConfigPath), contains('supportEmail'));
  });
}
