import 'dart:convert';
import 'dart:io';

import 'package:cleany/cleany.dart';
import 'package:cleany/src/ast_editor.dart';
import 'package:cleany/src/cli.dart';
import 'package:cleany/src/journal_store.dart';
import 'package:cleany/src/workspace.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

void main() {
  late Directory directory;
  late Project project;
  late Generator generator;
  setUp(() {
    directory = Directory.systemTemp.createTempSync('cleany_safety_');
    project = Project(directory.path);
    File(project.file('pubspec.yaml')).writeAsStringSync('''
name: fixture_app
environment:
  sdk: ^3.13.0
dependencies:
  flutter:
    sdk: flutter
''');
    generator = Generator(project);
  });
  tearDown(() => directory.deleteSync(recursive: true));
  Future<OperationResult> source(GenerationPlan plan) =>
      GenerationTransaction(project)
          .apply(plan, install: false, build: false, analyze: false);
  Future<void> initialize() async {
    await source(generator.initialize(appId: 'com.example.fixture'));
  }

  File write(String path, String contents) {
    final file = File(project.file(path));
    file.parent.createSync(recursive: true);
    return file..writeAsStringSync(contents);
  }

  test(
    'builder cannot replace an existing asset excluded from staging',
    () async {
      await initialize();
      write('assets/unlisted.json', 'developer');
      final plan = GenerationPlan(project)
        ..write('lib/probe.dart', 'const probe = 1;');
      await expectLater(
        GenerationTransaction(
          project,
          executor: (_, args, cwd) async {
            if (args.contains('build_runner')) {
              File('$cwd/assets/unlisted.json').writeAsStringSync('builder');
            }
            return const CommandResult(0, '', '');
          },
        ).apply(plan),
        throwsA(
          isA<OperationFailure>().having(
            (e) => e.message,
            'diagnostic',
            contains('Unstaged output conflicts'),
          ),
        ),
      );
      expect(project.read('assets/unlisted.json'), 'developer');
      expect(File(project.file('lib/probe.dart')).existsSync(), isFalse);
    },
  );

  test(
    'an explicit existing asset target can collect validated builder changes',
    () async {
      await initialize();
      write('assets/unlisted.json', 'developer');
      await GenerationTransaction(
        project,
        executor: (_, args, cwd) async {
          if (args.contains('build_runner')) {
            File('$cwd/assets/unlisted.json')
                .writeAsStringSync('validated builder');
          }
          return const CommandResult(0, '', '');
        },
      ).apply(
        GenerationPlan(project)..write('assets/unlisted.json', 'planned'),
      );
      expect(project.read('assets/unlisted.json'), 'validated builder');
    },
  );

  test(
    'doctor repairs one missing DI binding and preserves custom integrations',
    () async {
      await initialize();
      await source(
        generator.generate(name: 'auth', state: StateManagement.cubit),
      );
      const names = 'lib/app/router/route_names.dart';
      write(names, project.read(names).replaceAll('/auth', '/sign-in'));
      const di = 'lib/app/di/injection.dart';
      final editor = AstEditor(
        project
            .read(di)
            .replaceAll(
              'registerFactory<AuthCubit>',
              'registerLazySingleton<AuthCubit>',
            ),
      )..removeRegistrations({'GetAuth'});
      write(di, editor.source);
      const factories = 'lib/app/composition/feature_pages.dart';
      write(factories, project.read(factories).replaceAll('..load()', ''));
      final beforeFactory = project.read(factories);
      final plan = ProjectDoctor(project).inspect().plan;
      expect(plan.read(names), contains('/sign-in'));
      expect(plan.files.containsKey(names), isFalse);
      expect(plan.read(factories), beforeFactory);
      expect(plan.read(di), contains('registerLazySingleton<AuthCubit>'));
      expect(plan.read(di), contains('registerLazySingleton<GetAuth>'));
      await source(plan);
      expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
    },
  );

  void createJournal() {
    write('lib/recover.dart', 'after');
    write('.cleany/transaction/backups/0', 'before');
    JournalStore(project, GenerationTransaction.journalPath).create({
      'version': 3,
      'files': {
        'lib/recover.dart': {
          'before_hash': digestBytes(utf8.encode('before')),
          'after_hash': digestBytes(utf8.encode('after')),
          'backup': 'backups/0',
          'state': 'pending',
        },
      },
    });
  }

  for (final corrupt in [false, true]) {
    test(
      'secondary journal recovers with ${corrupt ? 'corrupt' : 'missing'} primary metadata',
      () async {
        createJournal();
        final primary = File(project.file('.cleany/transaction/manifest.json'));
        if (corrupt) {
          primary.writeAsStringSync('{bad');
        } else {
          primary.deleteSync();
        }
        final result = await GenerationTransaction(project).recover();
        expect(result.status, OperationStatus.rolledBack);
        expect(project.read('lib/recover.dart'), 'before');
      },
    );
  }

  test('unknown transaction preserves every available backup', () async {
    write('.cleany/transaction/backups/0', 'only remaining copy');
    await expectLater(
      GenerationTransaction(project).recover(),
      throwsA(
        isA<OperationFailure>().having(
          (e) => e.result.status,
          'outcome',
          OperationStatus.recoveryRequired,
        ),
      ),
    );
    expect(
      project.read('.cleany/transaction/backups/0'),
      'only remaining copy',
    );
  });

  test('tampered manifests preserve backups and original files', () async {
    createJournal();
    for (final path in ['manifest.json', 'manifest.backup.json']) {
      final file = File(project.file('.cleany/transaction/$path'));
      file.writeAsStringSync(
        file.readAsStringSync().replaceAll(
          'lib/recover.dart',
          'lib/victim.dart',
        ),
      );
    }
    await expectLater(
      GenerationTransaction(project).recover(),
      throwsA(isA<OperationFailure>()),
    );
    expect(project.read('lib/recover.dart'), 'after');
    expect(project.read('.cleany/transaction/backups/0'), 'before');
  });

  test(
    'observer exceptions after commit return success with warnings',
    () async {
      final result =
          await GenerationTransaction(
            project,
            context: OperationContext(
              onProgress: (event) {
                if (event.stage == 'completed') {
                  throw StateError('broken progress sink');
                }
              },
            ),
          ).apply(
            GenerationPlan(project)
              ..write('lib/committed.dart', 'const committed = true;'),
            install: false,
            build: false,
            analyze: false,
          );
      expect(result.status, OperationStatus.appliedWithWarnings);
      expect(result.warnings.single, contains('broken progress sink'));
      expect(project.read('lib/committed.dart'), 'const committed = true;');
    },
  );

  test('observer cannot mutate the approved plan during application', () async {
    final plan = GenerationPlan(project)
      ..write('lib/approved.dart', 'approved');
    await GenerationTransaction(
      project,
      context: OperationContext(
        onProgress: (event) {
          if (event.stage == 'applying') {
            plan.write('lib/approved.dart', 'unvalidated');
          }
        },
      ),
    ).apply(plan, install: false, build: false, analyze: false);
    expect(project.read('lib/approved.dart'), 'approved');
  });

  test(
    'rename preserves unrelated bytes and foreign symbols with identical names',
    () async {
      await initialize();
      await source(
        generator.generate(name: 'auth', state: StateManagement.cubit),
      );
      const unrelated =
          'class Unrelated{final int count;Unrelated(this.count);}\n';
      write('lib/unrelated.dart', unrelated);
      write('lib/external.dart', 'class AuthEntity{}\n');
      write(
        'lib/client.dart',
        "import 'features/auth/domain/entities/auth_entity.dart' as owned;\nimport 'external.dart' as other;\nowned.AuthEntity? local; other.AuthEntity? foreign;\n",
      );
      final plan = FeatureLifecycle(project).renameMove(
        name: 'auth',
        kind: GenerationKind.feature,
        newName: 'account',
      );
      expect(plan.files.containsKey('lib/unrelated.dart'), isFalse);
      expect(plan.files.containsKey('lib/external.dart'), isFalse);
      expect(
        plan.read('lib/client.dart'),
        contains('owned.AccountEntity? local; other.AuthEntity? foreign;'),
      );
      expect(project.read('lib/unrelated.dart'), unrelated);
    },
  );

  test(
    'conditional URI alternatives move without rewriting foreign symbols',
    () async {
      await initialize();
      await source(
        generator.generate(name: 'auth', state: StateManagement.cubit),
      );
      write(
        'lib/client.dart',
        "import 'features/auth/domain/entities/auth_entity.dart' if (dart.library.io) 'features/auth/domain/entities/auth_entity.dart';\nAuthEntity? entity;\n",
      );
      final plan = FeatureLifecycle(project).renameMove(
        name: 'auth',
        kind: GenerationKind.feature,
        newName: 'account',
      );
      expect(
        'account_entity.dart'.allMatches(plan.read('lib/client.dart')).length,
        2,
      );
      expect(plan.read('lib/client.dart'), contains('AccountEntity? entity'));
    },
  );

  test('staging follows recursively included local analysis and build configuration', () async {
    write('analysis_options.yaml', 'include: tooling/base.yaml\n');
    write('tooling/base.yaml', 'include: rules.yaml\n');
    write('tooling/rules.yaml', 'linter:\n  rules: []\n');
    write('build.yaml', 'include: tooling/builder.yaml\n');
    write('tooling/builder.yaml', 'targets: {}\n');
    final workspace = StagedWorkspace(project, OperationContext());
    try {
      final inputs = await workspace.create();
      expect(
        inputs.keys,
        containsAll([
          'tooling/base.yaml',
          'tooling/rules.yaml',
          'tooling/builder.yaml',
        ]),
      );
      expect(
        File('${workspace.directory.path}/tooling/rules.yaml').existsSync(),
        isTrue,
      );
    } finally {
      await workspace.dispose();
    }
  });

  test('staging failure keeps its original diagnostic', () async {
    write('analysis_options.yaml', 'include: missing/rules.yaml\n');
    await expectLater(
      GenerationTransaction(
        project,
        executor: (_, _, _) async => const CommandResult(0, '', ''),
      ).apply(GenerationPlan(project)..write('lib/x.dart', 'const x = 1;')),
      throwsA(
        isA<OperationFailure>().having(
          (e) => e.message,
          'cause',
          contains('Referenced configuration is missing'),
        ),
      ),
    );
    expect(Directory(project.file('.cleany/cache')).listSync(), isEmpty);
  });

  test(
    'mode-only builder outputs are applied and rollback restores modes',
    () async {
      if (Platform.isWindows) return;
      final script = write('tool/probe.sh', '#!/bin/sh\nexit 0\n');
      setFileMode(script, 0x1a4);
      await GenerationTransaction(
        project,
        executor: (_, args, cwd) async {
          if (args.contains('build_runner')) {
            setFileMode(File('$cwd/tool/probe.sh'), 0x1ed);
          }
          return const CommandResult(0, '', '');
        },
      ).apply(GenerationPlan(project));
      expect(script.statSync().mode & 0x1ff, 0x1ed);
      final plan = GenerationPlan(project)
        ..writeBytes('tool/probe.sh', script.readAsBytesSync(), mode: 0x1a4)
        ..write('z.txt', 'last');
      await expectLater(
        GenerationTransaction(project).apply(
          plan,
          install: false,
          build: false,
          analyze: false,
          beforeWrite: (path) {
            if (path == 'z.txt') throw StateError('stop');
          },
        ),
        throwsA(isA<OperationFailure>()),
      );
      expect(script.statSync().mode & 0x1ff, 0x1ed);
    },
  );

  test(
    'reset and doctor restore required assets without losing custom assets',
    () async {
      await initialize();
      final manifest = YamlEditor(project.read('pubspec.yaml'))
        ..update(['flutter', 'generate'], false)
        ..update(['flutter', 'assets'], ['assets/custom/']);
      write('pubspec.yaml', manifest.toString());
      for (final plan in [
        ProjectMaintenance(project).reset(),
        ProjectDoctor(project).inspect().plan,
      ]) {
        final yaml = loadYaml(plan.read('pubspec.yaml')) as Map;
        expect(yaml['flutter']['generate'], isTrue);
        expect(
          yaml['flutter']['assets'],
          containsAll(['assets/custom/', 'config/flavors/']),
        );
      }
    },
  );

  test('native identity properties never leak between platforms', () {
    write('android/gradle.properties', 'APP_ID=com.android.product\n');
    write('android/build.gradle.kts', 'val rootId = "com.example.root"\n');
    write(
      'android/app/build.gradle.kts',
      'defaultConfig { applicationId = rootId }',
    );
    write(
      'ios/Runner.xcodeproj/project.pbxproj',
      r'PRODUCT_BUNDLE_IDENTIFIER = "$(APP_ID)";',
    );
    expect(project.applicationIds(), ['com.example.root']);
  });

  test('field and destination validation precede builders', () async {
    await initialize();
    for (final name in [
      'copyWith',
      'toJson',
      'fromJson',
      'runtimeType',
      'hashCode',
      'when',
    ]) {
      expect(
        () => FieldSpec(name, 'String'),
        throwsA(isA<GenerationException>()),
      );
    }
    expect(
      () => generator.generate(
        name: 'auth',
        state: StateManagement.cubit,
        path: 'lib/core/extra',
      ),
      throwsA(isA<GenerationException>()),
    );
    final component = generator.generate(
      name: 'card',
      state: StateManagement.cubit,
      kind: GenerationKind.component,
    );
    expect(
      component.read('lib/components/card/cubit/card_cubit.dart'),
      contains('if (!isClosed)'),
    );
  });

  test('CLI retries retain inputs, require approval again and log each operation separately', () async {
    final answers = [
      '9',
      'com.example.fixture',
      '1',
      '1',
      '1',
      '',
      '',
      '1',
      '0',
    ].iterator;
    var attempts = 0;
    final output = StringBuffer();
    final error = StringBuffer();
    final code = await runCli(
      [],
      projectRoot: project.root,
      output: output,
      error: error,
      readLine: () => answers.moveNext() ? answers.current : null,
      executor: (_, _, _) async {
        if (attempts++ == 0) {
          return const CommandResult(1, '', 'first attempt failed');
        }
        return const CommandResult(0, '', '');
      },
    );
    expect(code, 0, reason: '$error\n$output');
    expect(
      output.toString(),
      contains(
        'Production app id (example: com.company.product) [com.example.fixture]',
      ),
    );
    expect('Continue [2]'.allMatches(output.toString()).length, 2);
    expect(Directory(project.file('.cleany/logs')).listSync().length, 2);
  });

  test('rollback preserves concurrent permission edits as conflicts', () async {
    if (Platform.isWindows) return;
    final file = write('a.txt', 'original');
    setFileMode(file, 0x1a4);
    final plan = GenerationPlan(project)
      ..write('a.txt', 'generated', mode: 0x1a4)
      ..write('z.txt', 'last');
    await expectLater(
      GenerationTransaction(project).apply(
        plan,
        install: false,
        build: false,
        analyze: false,
        beforeWrite: (path) {
          if (path == 'z.txt') {
            setFileMode(file, 0x180);
            throw StateError('stop');
          }
        },
      ),
      throwsA(
        isA<OperationFailure>().having(
          (e) => e.result.status,
          'outcome',
          OperationStatus.recoveryRequired,
        ),
      ),
    );
    expect(file.readAsStringSync(), 'generated');
    expect(file.statSync().mode & 0x1ff, 0x180);
    setFileMode(file, 0x1a4);
    await GenerationTransaction(project).recover();
    expect(file.readAsStringSync(), 'original');
  });

  test(
    'incomplete public environments fail before starting commands',
    () async {
      await initialize();
      write('config/flavors/uat.yaml', 'environment: prod\napi_base_url: ""\n');
      var commands = 0;
      await expectLater(
        GenerationTransaction(
          project,
          executor: (_, _, _) async {
            commands++;
            return const CommandResult(0, '', '');
          },
        ).apply(generator.generate(name: 'home', state: StateManagement.cubit)),
        throwsA(
          isA<OperationFailure>().having(
            (e) => e.message,
            'diagnostic',
            contains('Invalid config/flavors/uat.yaml'),
          ),
        ),
      );
      expect(commands, 0);
      expect(
        Directory(project.file('lib/features/home')).existsSync(),
        isFalse,
      );
    },
  );

  test(
    'a concurrent edit during output collection is never adopted as baseline',
    () async {
      write('lib/builder.dart', 'original');
      final context = OperationContext(
        onProgress: (event) {
          if (event.stage == 'collecting') {
            write('lib/builder.dart', 'developer edit');
          }
        },
      );
      await expectLater(
        GenerationTransaction(
          project,
          context: context,
          executor: (_, args, cwd) async {
            if (args.contains('build_runner')) {
              File('$cwd/lib/builder.dart').writeAsStringSync('generated');
            }
            return const CommandResult(0, '', '');
          },
        ).apply(GenerationPlan(project)),
        throwsA(
          isA<OperationFailure>().having(
            (e) => e.message,
            'diagnostic',
            contains('changed while collecting'),
          ),
        ),
      );
      expect(project.read('lib/builder.dart'), 'developer edit');
    },
  );

  test(
    'renamed ownership protects a customized binding during stale cleanup',
    () async {
      await initialize();
      await source(
        generator.generate(name: 'auth', state: StateManagement.cubit),
      );
      await source(
        FeatureLifecycle(project).renameMove(
          name: 'auth',
          kind: GenerationKind.feature,
          newName: 'account',
        ),
      );
      const di = 'lib/app/di/injection.dart';
      write(
        di,
        project
            .read(di)
            .replaceAll(
              'registerFactory<AccountCubit>',
              'registerLazySingleton<AccountCubit>',
            ),
      );
      Directory(project.file('lib/features/account'))
          .deleteSync(recursive: true);
      expect(
        () => ProjectDoctor(project).inspect(),
        throwsA(
          isA<GenerationException>().having(
            (e) => e.message,
            'diagnostic',
            contains('Customized binding'),
          ),
        ),
      );
      expect(project.read(di), contains('registerLazySingleton<AccountCubit>'));
    },
  );

  test(
    'process-tree tool failures still terminate the active command',
    () async {
      final context = OperationContext(
        timeout: const Duration(milliseconds: 250),
      );
      final clock = Stopwatch()..start();
      final script = write(
        'wait.dart',
        "import 'dart:async'; Future<void> main() async { await Future<void>.delayed(const Duration(seconds: 30)); }",
      );
      await expectLater(
        executeManagedCommand(
          Platform.resolvedExecutable,
          [script.path],
          project.root,
          context,
          processTreeCommand: (_, _) async =>
              throw const ProcessException('tree-tool', [], 'unavailable'),
        ),
        throwsA(
          isA<GenerationException>().having(
            (e) => e.message,
            'deadline',
            contains('exceeded'),
          ),
        ),
      );
      expect(clock.elapsed, lessThan(const Duration(seconds: 8)));
      expect(
        context.warnings.single,
        contains('terminating the command directly'),
      );
    },
  );

  test('a bad progress observer cannot fail a managed command', () async {
    final context = OperationContext(
      onProgress: (_) => throw StateError('observer'),
    );
    final result = await executeManagedCommand(
      Platform.resolvedExecutable,
      ['--version'],
      project.root,
      context,
    );
    expect(result.succeeded, isTrue);
    expect(context.warnings, isNotEmpty);
  });

  test(
    'committed recovery is reported as applied rather than rolled back',
    () async {
      createJournal();
      write('.cleany/transaction/committed', 'ok');
      final result = await GenerationTransaction(project).recover();
      expect(result.status, OperationStatus.applied);
      expect(project.read('lib/recover.dart'), 'after');
    },
  );

  test(
    'recovery retains unreferenced backups while restoring safe records',
    () async {
      createJournal();
      write('.cleany/transaction/backups/1', 'unknown owner');
      await expectLater(
        GenerationTransaction(project).recover(),
        throwsA(isA<OperationFailure>()),
      );
      expect(project.read('lib/recover.dart'), 'before');
      expect(project.read('.cleany/transaction/backups/1'), 'unknown owner');
    },
  );

  test(
    'builder entrypoints outside standard folders bring their local imports',
    () async {
      write(
        'build.yaml',
        'builders:\n  fixture:\n    import: builders/entry.dart\n',
      );
      write('builders/entry.dart', "import 'helper.dart'; class Builder {}\n");
      write('builders/helper.dart', 'const helper = true;\n');
      final workspace = StagedWorkspace(project, OperationContext());
      try {
        final inputs = await workspace.create();
        expect(
          inputs.keys,
          containsAll(['builders/entry.dart', 'builders/helper.dart']),
        );
      } finally {
        await workspace.dispose();
      }
    },
  );

  test(
    'Freezed public variants and aliased route owners rename together',
    () async {
      await initialize();
      await source(
        generator.generate(name: 'auth', state: StateManagement.cubit),
      );
      write(
        'lib/client.dart',
        "import 'features/auth/presentation/cubit/auth_state.dart';\nAuthFailure? failure;\n",
      );
      const router = 'lib/app/router/app_router.dart';
      write(
        router,
        project
            .read(router)
            .replaceAll(
              "import 'route_names.dart';",
              "import 'route_names.dart' as routing;",
            )
            .replaceAll('RouteNames.', 'routing.RouteNames.'),
      );
      final plan = FeatureLifecycle(project).renameMove(
        name: 'auth',
        kind: GenerationKind.feature,
        newName: 'account',
      );
      expect(plan.read('lib/client.dart'), contains('AccountFailure? failure'));
      expect(plan.read(router), contains('routing.RouteNames.account'));
      expect(plan.read(router), isNot(contains('routing.RouteNames.auth')));
    },
  );

  test('a foreign prefixed symbol inside the moved directory stays foreign', () async {
    await initialize();
    await source(
      generator.generate(name: 'auth', state: StateManagement.cubit),
    );
    write('lib/external.dart', 'class AuthEntity {}');
    write(
      'lib/features/auth/custom.dart',
      "import '../../external.dart' as foreign;\nforeign.AuthEntity? entity;\n",
    );
    final plan = FeatureLifecycle(project).renameMove(
      name: 'auth',
      kind: GenerationKind.feature,
      newName: 'account',
    );
    expect(
      plan.read('lib/features/account/custom.dart'),
      contains('foreign.AuthEntity? entity'),
    );
  });

  test(
    'import insertion distinguishes aliases and canonical relative URIs',
    () {
      final editor = AstEditor(
        "import 'package:fixture_app/features/auth.dart' as auth;\nimport '../../features/home.dart';\n",
        resolveUri: (uri) => project.dartUri('lib/app/di/injection.dart', uri),
      );
      editor.addImports([
        'package:fixture_app/features/auth.dart',
        'package:fixture_app/features/home.dart',
      ]);
      expect(
        "import 'package:fixture_app/features/auth.dart';"
            .allMatches(editor.source)
            .length,
        1,
      );
      expect(
        editor.source,
        isNot(contains("import 'package:fixture_app/features/home.dart';")),
      );
    },
  );

  test('mixed conditional imports are preserved for manual removal', () {
    final original =
        "import 'owned.dart' if (dart.library.io) 'external.dart';";
    final editor = AstEditor(original);
    expect(
      () => editor.removeImports((uri) => uri == 'owned.dart'),
      throwsA(isA<GenerationException>()),
    );
    expect(editor.source, original);
  });

  test(
    'native configurations resolve independently without Cartesian mixing',
    () {
      write(
        'ios/Flutter/prod.xcconfig',
        'PREFIX=com.example.prod\nSUFFIX=app\n',
      );
      write(
        'ios/Flutter/dev.xcconfig',
        'PREFIX=com.example.dev\nSUFFIX=testing\n',
      );
      write(
        'ios/Runner.xcodeproj/project.pbxproj',
        r'PRODUCT_BUNDLE_IDENTIFIER = "$(PREFIX).$(SUFFIX)";',
      );
      expect(
        project.applicationIds(),
        unorderedEquals(['com.example.prod.app', 'com.example.dev.testing']),
      );
    },
  );

  test(
    'successful recovery clears an earlier failed CLI exit status',
    () async {
      final answers = ['12', '1', '2', '12', '1', '0'].iterator;
      var reads = 0;
      createJournal();
      final original = project.read('.cleany/transaction/manifest.json');
      write('.cleany/transaction/manifest.json', 'invalid');
      write('.cleany/transaction/manifest.backup.json', 'invalid');
      final code = await runCli(
        [],
        projectRoot: project.root,
        output: StringBuffer(),
        error: StringBuffer(),
        readLine: () {
          if (++reads == 4) {
            write('.cleany/transaction/manifest.json', original);
          }
          return answers.moveNext() ? answers.current : null;
        },
      );
      expect(code, 0);
      expect(project.read('lib/recover.dart'), 'before');
    },
  );
}
