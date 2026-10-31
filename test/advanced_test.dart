import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cleany/cleany.dart';
import 'package:cleany/src/ast_editor.dart';
import 'package:cleany/src/cli.dart';
import 'package:cleany/src/registry.dart';
import 'package:cleany/src/workspace.dart';
import 'package:test/test.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

void main() {
  late Directory directory;
  late Project project;
  late Generator generator;
  setUp(() {
    directory = Directory.systemTemp.createTempSync('cleany_advanced_');
    project = Project(directory.path);
    File(project.file('pubspec.yaml')).writeAsStringSync('''
name: fixture_app
environment:
  sdk: ^3.10.0
dependencies:
  flutter:
    sdk: flutter
flutter:
  uses-material-design: true
''');
    generator = Generator(project);
  });
  tearDown(() => directory.deleteSync(recursive: true));
  Future<void> source(GenerationPlan plan) =>
      GenerationTransaction(project)
          .apply(plan, install: false, build: false, analyze: false);
  Future<void> initialize() =>
      source(generator.initialize(appId: 'com.example.fixture'));

  test(
    'ownership prevents deleting a hand-authored API for a component',
    () async {
      await initialize();
      await source(
        generator.generate(
          name: 'card',
          kind: GenerationKind.component,
          state: StateManagement.cubit,
        ),
      );
      final api = File(project.file('lib/core/network/retrofit/card_api.dart'))
        ..writeAsStringSync('class ManualApi {}');
      await source(
        generator.remove(name: 'card', kind: GenerationKind.component),
      );
      expect(api.readAsStringSync(), 'class ManualApi {}');
    },
  );

  test('builder ownership derives from a recorded template source', () async {
    await initialize();
    final plan = generator.generate(name: 'auth', state: StateManagement.cubit);
    await GenerationTransaction(
      project,
      executor: (exe, _, cwd) async {
        if (exe == 'dart') {
          File('$cwd/lib/core/network/retrofit/auth_api.g.dart')
              .writeAsStringSync('// generated');
        }
        return const CommandResult(0, '', '');
      },
    ).apply(plan);
    final record = (generator.readRegistry()['features'] as List).single as Map;
    expect(
      (record['files'] as List).any(
        (file) =>
            file['path'] == 'lib/core/network/retrofit/auth_api.g.dart' &&
            file['origin'] == 'builder',
      ),
      isTrue,
    );
    await source(generator.remove(name: 'auth', kind: GenerationKind.feature));
    expect(
      File(project.file('lib/core/network/retrofit/auth_api.g.dart'))
          .existsSync(),
      isFalse,
    );
  });

  test(
    'rollback restores safe files despite a later concurrent user edit',
    () async {
      File(project.file('a.txt')).writeAsStringSync('original A');
      File(project.file('b.txt')).writeAsStringSync('original B');
      final plan = GenerationPlan(project)
        ..write('a.txt', 'generated A')
        ..write('b.txt', 'generated B');
      await expectLater(
        GenerationTransaction(project).apply(
          plan,
          install: false,
          build: false,
          analyze: false,
          beforeWrite: (path) {
            if (path == 'b.txt') {
              File(project.file(path)).writeAsStringSync('user B');
            }
          },
        ),
        throwsA(isA<GenerationException>()),
      );
      expect(project.read('a.txt'), 'original A');
      expect(project.read('b.txt'), 'user B');
      final journal =
          jsonDecode(project.read('.cleany/transaction/manifest.json')) as Map;
      expect(journal['files']['a.txt']['state'], 'restored');
      expect(journal['files']['b.txt']['state'], 'conflict');
      File(project.file('b.txt')).writeAsStringSync('original B');
      await GenerationTransaction(project).recover();
      expect(
        Directory(project.file('.cleany/transaction')).existsSync(),
        isFalse,
      );
    },
  );

  test(
    'validated test and asset outputs are applied, not silently ignored',
    () async {
      final plan = generator.initialize(appId: 'com.example.fixture');
      await GenerationTransaction(
        project,
        executor: (exe, _, cwd) async {
          if (exe == 'dart') {
            File('$cwd/test/helper.g.dart')
                .writeAsStringSync('// generated test');
            File('$cwd/assets/translations/generated.json')
                .writeAsStringSync('{}');
          }
          return const CommandResult(0, '', '');
        },
      ).apply(plan);
      expect(project.read('test/helper.g.dart'), '// generated test');
      expect(project.read('assets/translations/generated.json'), '{}');
    },
  );

  test(
    'unsupported output paths fail before any original source commit',
    () async {
      await expectLater(
        GenerationTransaction(
          project,
          executor: (exe, _, cwd) async {
            if (exe == 'dart') {
              File('$cwd/unexpected.bin').writeAsStringSync('output');
            }
            return const CommandResult(0, '', '');
          },
        ).apply(generator.initialize(appId: 'com.example.fixture')),
        throwsA(isA<GenerationException>()),
      );
      expect(Directory(project.file('lib/app')).existsSync(), isFalse);
    },
  );

  test(
    'staging excludes unrelated large/sensitive files and streams fingerprints',
    () async {
      File(project.file('.env')).writeAsStringSync('PRIVATE=do-not-stage');
      File(project.file('large-unrelated.bin'))
          .writeAsBytesSync(List<int>.filled(1024 * 1024, 7));
      final lock = await ProjectLock.acquire(project);
      final workspace = StagedWorkspace(project, OperationContext());
      try {
        final snapshot = await workspace.create();
        expect(snapshot.containsKey('.env'), isFalse);
        expect(snapshot.containsKey('large-unrelated.bin'), isFalse);
        expect(File('${workspace.directory.path}/.env').existsSync(), isFalse);
        expect(snapshot['pubspec.yaml'], isA<FileFingerprint>());
      } finally {
        await workspace.dispose();
        await lock.release();
      }
    },
  );

  test(
    'dead legacy locks recover automatically and live locks remain exclusive',
    () async {
      Directory(project.file('.cleany')).createSync();
      File(project.file('.cleany/lock')).writeAsStringSync('2147483647');
      final lock = await ProjectLock.acquire(project);
      await expectLater(
        ProjectLock.acquire(project),
        throwsA(isA<GenerationException>()),
      );
      await lock.release();
      final again = await ProjectLock.acquire(project);
      await again.release();
      expect(File(project.file('.cleany/lock')).existsSync(), isFalse);
    },
  );

  test('cache cleanup preserves registry and recovery backups', () async {
    await initialize();
    final stage = Directory(project.file('.cleany/cache/stale'))
      ..createSync(recursive: true);
    File('${stage.path}/.cleany-stage').writeAsStringSync(project.root);
    final backup = File(project.file('.cleany/backups/keep.txt'));
    backup.parent.createSync(recursive: true);
    backup.writeAsStringSync('keep');
    expect(await ProjectMaintenance(project).cleanCache(), 1);
    expect(File(project.file(registryPath)).existsSync(), isTrue);
    expect(backup.readAsStringSync(), 'keep');
  });

  test(
    'reset archives user changes in managed folders and starts empty',
    () async {
      await initialize();
      await source(
        generator.generate(name: 'auth', state: StateManagement.cubit),
      );
      final userFile = File(project.file('lib/core/user_extension.dart'))
        ..writeAsStringSync('// user extension');
      File(project.file('lib/unrelated.dart'))
          .writeAsStringSync('// unrelated');
      final plan = ProjectMaintenance(project).reset();
      expect(
        plan.files.keys.any(
          (path) =>
              path.startsWith('.cleany/backups/reset_') &&
              path.endsWith('/lib/core/user_extension.dart'),
        ),
        isTrue,
      );
      await source(plan);
      expect(userFile.existsSync(), isFalse);
      expect(project.read('lib/unrelated.dart'), '// unrelated');
      expect(generator.readRegistry()['features'], isEmpty);
      expect(File(project.file('lib/app/app.dart')).existsSync(), isTrue);
      await source(
        generator.generate(name: 'home', state: StateManagement.bloc),
      );
    },
  );

  test(
    'doctor rebuilds missing registry and missing DI/route registrations',
    () async {
      await initialize();
      await source(
        generator.generate(name: 'auth', state: StateManagement.cubit),
      );
      File(project.file(registryPath)).deleteSync();
      File(project.file('lib/app/di/injection.dart')).deleteSync();
      File(project.file('lib/app/router/route_names.dart')).deleteSync();
      final report = ProjectDoctor(project).inspect();
      expect(report.issues.any((issue) => issue.code == 'registry'), isTrue);
      await source(report.plan);
      expect(
        (generator.readRegistry()['features'] as List).single['name'],
        'auth',
      );
      expect(
        (generator.readRegistry()['features'] as List).single['files'],
        contains(
          isA<Map>().having(
            (record) => record['path'],
            'path',
            'lib/core/network/retrofit/auth_api.dart',
          ),
        ),
      );
      expect(generator.readRegistry()['app_id'], 'com.example.fixture');
      expect(
        project.read('lib/app/di/injection.dart'),
        contains('registerFactory<AuthCubit>'),
      );
      expect(
        project.read('lib/app/router/route_names.dart'),
        contains('/auth'),
      );
    },
  );

  test(
    'maintenance shortcut uses menus and validates settings without builders',
    () async {
      final output = StringBuffer();
      final error = StringBuffer();
      final answers = ['3', '60', '1', '0'].iterator;
      final code = await runCli(
        ['maintenance'],
        projectRoot: project.root,
        output: output,
        error: error,
        useColor: false,
        readLine: () => answers.moveNext() ? answers.current : null,
        executor: (_, _, _) =>
            throw StateError('Settings must not run builders'),
      );
      expect(code, 0);
      expect(
        ProjectMaintenance(project).commandTimeout(),
        const Duration(seconds: 60),
      );
      expect(error.toString(), isEmpty);
      expect(output.toString(), contains('Project doctor / repair'));
      expect(output.toString(), isNot(contains('Preview diff')));
    },
  );

  test(
    'doctor restores nested parent metadata after losing the registry',
    () async {
      await initialize();
      await source(
        generator.generate(name: 'auth', state: StateManagement.cubit),
      );
      await source(
        generator.generate(
          name: 'card',
          kind: GenerationKind.component,
          state: StateManagement.none,
          parent: 'auth',
        ),
      );
      File(project.file(registryPath)).deleteSync();
      await source(ProjectDoctor(project).inspect().plan);
      final entries = generator.readRegistry()['features'] as List;
      expect(
        entries.firstWhere((entry) => entry['name'] == 'card')['parent'],
        'auth',
      );
    },
  );

  test(
    'doctor narrows broad constraints and repairs SDK dependencies',
    () async {
      await initialize();
      final manifest = File(project.file('pubspec.yaml'));
      manifest.writeAsStringSync(
        manifest
            .readAsStringSync()
            .replaceFirst('dio: ^5.11.0', 'dio: ">=4.0.0 <6.0.0"')
            .replaceFirst('sdk: flutter\n  intl:', 'sdk: unsupported\n  intl:'),
      );
      final report = ProjectDoctor(project).inspect();
      final yaml = loadYaml(report.plan.read('pubspec.yaml')) as Map;
      final constraint = VersionConstraint.parse(
        yaml['dependencies']['dio'] as String,
      );
      expect(constraint.allows(Version.parse('5.0.0')), isFalse);
      expect(constraint.allows(Version.parse('5.11.0')), isTrue);
      expect(yaml['dependencies']['flutter_localizations']['sdk'], 'flutter');
    },
  );

  test(
    'doctor removes stale directory records and composition safely',
    () async {
      await initialize();
      await source(
        generator.generate(name: 'auth', state: StateManagement.cubit),
      );
      Directory(project.file('lib/features/auth')).deleteSync(recursive: true);
      final report = ProjectDoctor(project).inspect();
      await source(report.plan);
      expect(generator.readRegistry()['features'], isEmpty);
      expect(
        project.read('lib/app/di/injection.dart'),
        isNot(contains('AuthCubit')),
      );
    },
  );

  test(
    'rename/move rewrites imports, parts, symbols, descendants and registry',
    () async {
      await initialize();
      await source(
        generator.generate(name: 'auth', state: StateManagement.cubit),
      );
      await source(
        generator.generate(
          name: 'card',
          kind: GenerationKind.component,
          state: StateManagement.cubit,
          parent: 'auth',
        ),
      );
      File(project.file('test/reference.dart')).writeAsStringSync(
        "import 'package:fixture_app/features/auth/domain/entities/auth_entity.dart';\nAuthEntity? value;\n",
      );
      final plan = FeatureLifecycle(project).renameMove(
        name: 'auth',
        kind: GenerationKind.feature,
        newName: 'account',
        destination: 'lib/modules',
      );
      await source(plan);
      expect(
        Directory(project.file('lib/features/auth')).existsSync(),
        isFalse,
      );
      expect(
        project.read('lib/modules/account/domain/entities/account_entity.dart'),
        contains('class AccountEntity'),
      );
      expect(
        project.read('lib/modules/account/domain/entities/account_entity.dart'),
        contains("part \"account_entity.freezed.dart\""),
      );
      expect(
        project.read('test/reference.dart'),
        contains(
          'package:fixture_app/modules/account/domain/entities/account_entity.dart',
        ),
      );
      expect(project.read('test/reference.dart'), contains('AccountEntity?'));
      expect(
        project.read('lib/app/router/route_names.dart'),
        contains('account'),
      );
      expect(
        project.read('lib/core/network/retrofit/account_api.dart'),
        contains('/auth'),
      );
      final entries = generator.readRegistry()['features'] as List;
      expect(entries.first['name'], 'account');
      expect(entries.last['parent'], 'account');
      expect(entries.last['path'], 'lib/modules/account/subfeatures/card');
    },
  );

  test('AST integration accepts returned lists and named list variables', () {
    final source =
        "List<RouteBase> buildRoutes(GetIt c) { final routes = <RouteBase>[GoRoute(path: RouteNames.root)]; return routes; }";
    final editor = AstEditor(source)
      ..addRoutes('GoRoute(path: RouteNames.auth),');
    expect(editor.source, contains('RouteNames.auth'));
    editor.removeRoutes({'auth'});
    expect(editor.source, isNot(contains('RouteNames.auth')));
  });

  test('app ids resolve static Gradle and xcconfig properties without executing code', () {
    Directory(project.file('android/app')).createSync(recursive: true);
    File(project.file('android/gradle.properties'))
        .writeAsStringSync('APP_ID=com.example.variable\n');
    File(project.file('android/app/build.gradle.kts')).writeAsStringSync('''
val website = "https://example.com/{literal}"
android { defaultConfig {
  applicationId = providers.gradleProperty("APP_ID").get()
} }
''');
    Directory(project.file('ios/Flutter')).createSync(recursive: true);
    File(project.file('ios/Flutter/Config.xcconfig'))
        .writeAsStringSync('BASE_ID=com.example.variable\n');
    Directory(project.file('ios/Runner.xcodeproj')).createSync(recursive: true);
    File(project.file('ios/Runner.xcodeproj/project.pbxproj'))
        .writeAsStringSync(r'PRODUCT_BUNDLE_IDENTIFIER = "$(BASE_ID)";');
    expect(project.applicationIds(), ['com.example.variable']);
  });

  test(
    'typed fields and API parameters stay out of Domain transport concerns',
    () async {
      await initialize();
      final spec = FeatureSpec(
        fields: [
          FieldSpec('orderId', 'int', jsonKey: 'order_id'),
          FieldSpec('title', 'String?'),
        ],
        requestFields: [FieldSpec('reference', 'String')],
        method: 'POST',
        endpoint: '/v1/orders',
        requestEncoding: 'body',
      );
      final plan = generator.generate(
        name: 'orders',
        state: StateManagement.bloc,
        specification: spec,
      );
      expect(
        plan.read('lib/features/orders/domain/entities/orders_entity.dart'),
        contains('required int orderId'),
      );
      expect(
        plan.read('lib/core/network/retrofit/orders_api.dart'),
        contains('@POST("/v1/orders")'),
      );
      expect(
        plan.read('lib/core/network/retrofit/orders_api.dart'),
        contains('@Body()'),
      );
      final domain = plan.read(
        'lib/features/orders/domain/repositories/orders_repository.dart',
      );
      expect(domain, contains('required OrdersRequest request'));
      expect(
        plan.read('lib/app/composition/feature_pages.dart'),
        isNot(contains('OrdersEvent.requested()')),
      );
      expect(domain, isNot(contains('Map<String, dynamic>')));
      expect(domain, isNot(contains('dio')));
    },
  );

  test('managed commands enforce deadlines and cancellation', () async {
    final dart = Platform.resolvedExecutable;
    final script = File(project.file('slow.dart'))
      ..writeAsStringSync(
        "import 'dart:async'; Future<void> main() async { await Future<void>.delayed(const Duration(seconds: 30)); }",
      );
    await expectLater(
      executeManagedCommand(
        dart,
        [script.path],
        project.root,
        OperationContext(timeout: const Duration(milliseconds: 100)),
      ),
      throwsA(isA<GenerationException>()),
    );
    final token = CancellationToken();
    Timer(const Duration(milliseconds: 100), token.cancel);
    await expectLater(
      executeManagedCommand(
        dart,
        [script.path],
        project.root,
        OperationContext(cancellation: token),
      ),
      throwsA(isA<OperationCancelled>()),
    );
  });

  test('failed commands never emit a successful progress marker', () async {
    final script = File(project.file('failed_command.dart'))
      ..writeAsStringSync("import 'dart:io'; void main() => exit(7);\n");
    final events = <OperationEvent>[];
    final result = await executeManagedCommand(
      Platform.resolvedExecutable,
      [script.path],
      project.root,
      OperationContext(onProgress: events.add),
    );
    expect(result.exitCode, 7);
    expect(events.last.completed, isFalse);
    expect(events.last.detail, contains('exit 7'));
  });

  test(
    'asynchronous cancellation during commit restores applied files',
    () async {
      File(project.file('a.txt')).writeAsStringSync('original A');
      File(project.file('b.txt')).writeAsStringSync('original B');
      final plan = GenerationPlan(project)
        ..write('a.txt', 'generated A')
        ..write('b.txt', 'generated B');
      final token = CancellationToken();
      await expectLater(
        GenerationTransaction(
          project,
          context: OperationContext(cancellation: token),
        ).apply(
          plan,
          install: false,
          build: false,
          analyze: false,
          beforeWrite: (path) {
            if (path == 'a.txt') Timer.run(token.cancel);
          },
        ),
        throwsA(isA<OperationCancelled>()),
      );
      expect(project.read('a.txt'), 'original A');
      expect(project.read('b.txt'), 'original B');
      expect(
        Directory(project.file('.cleany/transaction')).existsSync(),
        isFalse,
      );
    },
  );
  test('outputs changed during analysis are rejected before commit', () async {
    await expectLater(
      GenerationTransaction(
        project,
        executor: (_, args, cwd) async {
          if (args.contains('analyze')) {
            File('$cwd/lib/late.dart').writeAsStringSync('class Late {}');
          }
          return const CommandResult(0, '', '');
        },
      ).apply(generator.initialize(appId: 'com.example.fixture')),
      throwsA(isA<GenerationException>()),
    );
    expect(Directory(project.file('lib')).existsSync(), isFalse);
  });

  test(
    'manifest changes during analysis cannot be hidden by portable restoration',
    () async {
      final original = project.read('pubspec.yaml');
      await expectLater(
        GenerationTransaction(
          project,
          executor: (_, args, cwd) async {
            if (args.contains('analyze')) {
              File('$cwd/pubspec.yaml').writeAsStringSync('name: changed\n');
            }
            return const CommandResult(0, '', '');
          },
        ).apply(generator.initialize(appId: 'com.example.fixture')),
        throwsA(isA<GenerationException>()),
      );
      expect(project.read('pubspec.yaml'), original);
    },
  );

  test(
    'native flavor failure leaves original platform files unchanged',
    () async {
      await initialize();
      Directory(project.file('android/app')).createSync(recursive: true);
      File(project.file('android/app/build.gradle.kts'))
          .writeAsStringSync('// original native file');
      final plan = planPlatformFlavors(project, {'android'});
      await expectLater(
        GenerationTransaction(
          project,
          executor: (_, args, cwd) async {
            if (args.contains('flutter_flavorizr')) {
              expect(Directory('$cwd/ios').existsSync(), isFalse);
              File('$cwd/android/app/build.gradle.kts')
                  .writeAsStringSync('// changed');
              return const CommandResult(7, '', 'platform processor failed');
            }
            return const CommandResult(0, '', '');
          },
        ).apply(plan, build: false),
        throwsA(isA<GenerationException>()),
      );
      expect(
        project.read('android/app/build.gradle.kts'),
        '// original native file',
      );
    },
  );

  test('doctor reconstructs custom fields and contracts from source when registry is lost', () async {
    await initialize();
    await source(
      generator.generate(
        name: 'orders',
        state: StateManagement.bloc,
        specification: FeatureSpec(
          fields: [FieldSpec('orderId', 'int', jsonKey: 'order_id')],
          requestFields: [FieldSpec('reference', 'String')],
          method: 'POST',
          endpoint: '/v1/orders',
          requestEncoding: 'body',
        ),
      ),
    );
    File(project.file(registryPath)).writeAsStringSync('{broken');
    final report = ProjectDoctor(project).inspect();
    await source(report.plan);
    final record = (generator.readRegistry()['features'] as List).single as Map;
    expect(record['specification']['fields'][0]['name'], 'orderId');
    expect(record['specification']['fields'][0]['type'], 'int');
    expect(record['specification']['method'], 'POST');
    expect(record['specification']['endpoint'], '/v1/orders');
  });

  test('expression DI and static route lists are integrated without text signatures', () {
    final di = AstEditor(
      'void registerFeatureDependencies(GetIt container) => container.registerFactory<AuthCubit>(() => AuthCubit());',
    );
    di.removeRegistrations({'AuthCubit'});
    di.addStatements(
      'registerFeatureDependencies',
      'container.registerFactory<HomeCubit>(() => HomeCubit());',
    );
    expect(di.source, contains('HomeCubit'));
    expect(di.source, isNot(contains('AuthCubit')));
    final routes = AstEditor(
      'class Routing { static final items = <RouteBase>[]; } List<RouteBase> buildRoutes(GetIt c) => Routing.items;',
    )..addRoutes('GoRoute(path: RouteNames.auth),');
    expect(routes.source, contains('RouteNames.auth'));
  });

  test('kernel lock is released automatically when its owner process dies', () async {
    final script = File(project.file('hold_lock.dart'));
    script.writeAsStringSync(
      "import 'dart:async'; import 'package:cleany/cleany.dart'; Future<void> main() async { final lock = await ProjectLock.acquire(Project(${dartLiteral(project.root)})); print('ready'); await Future<void>.delayed(const Duration(seconds: 30)); await lock.release(); }",
    );
    final process = await Process.start(Platform.resolvedExecutable, [
      '--packages=${File('.dart_tool/package_config.json').absolute.path}',
      script.path,
    ]);
    try {
      await process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .first
          .timeout(const Duration(seconds: 20));
      await expectLater(
        ProjectLock.acquire(project),
        throwsA(isA<GenerationException>()),
      );
    } finally {
      process.kill(
        Platform.isWindows ? ProcessSignal.sigterm : ProcessSignal.sigkill,
      );
      await process.exitCode;
    }
    final recovered = await ProjectLock.acquire(project);
    await recovered.release();
  });

  test(
    'corrupt backup does not block restoring other journal records',
    () async {
      File(project.file('safe.txt')).writeAsStringSync('applied safe');
      File(project.file('broken.txt')).writeAsStringSync('applied broken');
      final backup = File(project.file('.cleany/transaction/backups/0'));
      backup.parent.createSync(recursive: true);
      backup.writeAsStringSync('original safe');
      File(project.file('.cleany/transaction/backups/1'))
          .writeAsStringSync('damaged');
      File(project.file('.cleany/transaction/manifest.json')).writeAsStringSync(
        prettyJson({
          'version': 2,
          'files': {
            'safe.txt': {
              'before_hash': contentDigest(utf8.encode('original safe')),
              'after_hash': contentDigest(utf8.encode('applied safe')),
              'backup': 'backups/0',
              'state': 'applied',
            },
            'broken.txt': {
              'before_hash': contentDigest(utf8.encode('original broken')),
              'after_hash': contentDigest(utf8.encode('applied broken')),
              'backup': 'backups/1',
              'state': 'applied',
            },
          },
        }),
      );
      File(project.file('.cleany/transaction/manifest.json.cleany-tmp'))
          .writeAsStringSync('interrupted journal write');
      await expectLater(
        GenerationTransaction(project).recover(),
        throwsA(isA<GenerationException>()),
      );
      expect(project.read('safe.txt'), 'original safe');
      expect(project.read('broken.txt'), 'applied broken');
      File(project.file('.cleany/transaction/backups/1'))
          .writeAsStringSync('original broken');
      await GenerationTransaction(project).recover();
      expect(project.read('broken.txt'), 'original broken');
    },
  );

  test('registry cannot claim unrelated files as project-owned', () async {
    await initialize();
    final registry = generator.readRegistry();
    (registry['project_files'] as List).add(
      artifactRecord(
        'lib/manual.dart',
        utf8.encode('class Manual {}'),
        '@project',
      ),
    );
    File(project.file(registryPath)).writeAsStringSync(prettyJson(registry));
    expect(
      ProjectMaintenance(project).reset,
      throwsA(isA<GenerationException>()),
    );
  });

  test(
    'macOS flavor plan isolates processors and keeps production identity',
    () async {
      await initialize();
      Directory(project.file('macos')).createSync();
      final plan = planPlatformFlavors(project, {'macos'});
      final yaml = plan.stageOverrides['flavorizr.yaml']!;
      expect(yaml, contains('macos:buildTargets'));
      expect(yaml, isNot(contains('ios:buildTargets')));
      expect(yaml, contains('bundleId: "com.example.fixture"'));
      expect(plan.platformRoots, {'macos'});
    },
  );
}
