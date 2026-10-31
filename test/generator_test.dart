import 'dart:convert';
import 'dart:io';

import 'package:cleany/cleany.dart';
import 'package:cleany/src/ast_editor.dart';
import 'package:cleany/src/cli.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  late Directory directory;
  late Project project;
  late Generator generator;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('cleany_test_');
    project = Project(directory.path);
    File(project.file('pubspec.yaml')).writeAsStringSync('''
# Keep this comment
name: fixture_app
environment:
  sdk: ^3.10.0
dependencies:
  flutter:
    sdk: flutter
dependency_overrides:
  collection: ^1.19.0
flutter:
  uses-material-design: true
  assets:
    - assets/custom/
''');
    generator = Generator(project);
  });
  tearDown(() => directory.deleteSync(recursive: true));

  Future<void> apply(GenerationPlan plan) =>
      GenerationTransaction(project)
          .apply(plan, install: false, build: false, analyze: false);
  Future<void> initialize({ApiProvider provider = ApiProvider.retrofit}) =>
      apply(
        generator.initialize(
          provider: provider,
          appId: 'com.example.playground',
        ),
      );

  test('validates Flutter SDK rather than mobile platform directories', () {
    expect(project.validate(), 'fixture_app');
  });

  test(
    'initialization preserves pubspec metadata, comments, assets, and main',
    () async {
      Directory(project.file('lib')).createSync();
      File(project.file('lib/main.dart'))
          .writeAsStringSync('// user entrypoint\n');
      await initialize();
      final text = project.read('pubspec.yaml');
      final yaml = loadYaml(text) as Map;
      expect(text, contains('# Keep this comment'));
      expect(yaml['dependency_overrides']['collection'], '^1.19.0');
      expect(yaml['flutter']['assets'], contains('assets/custom/'));
      expect(project.read('lib/main.dart'), '// user entrypoint\n');
      expect(text, isNot(contains('supabase')));
      expect(text, isNot(contains('injectable')));
      expect(text, isNot(contains('flutter_dotenv')));
      expect(
        () => generator.initialize(appId: 'com.example.playground'),
        throwsA(isA<GenerationException>()),
      );
    },
  );

  test('initialization refuses every existing file before writing', () {
    Directory(project.file('assets/translations')).createSync(recursive: true);
    File(project.file('assets/translations/app_en.arb'))
        .writeAsStringSync('{"saved":true}');
    final before = project.read('pubspec.yaml');
    expect(
      () => generator.initialize(appId: 'com.example.playground'),
      throwsA(isA<GenerationException>()),
    );
    expect(project.read('pubspec.yaml'), before);
    expect(Directory(project.file('lib/app')).existsSync(), isFalse);
  });

  for (final name in [
    '',
    '../auth',
    'a/b',
    'Auth',
    'two words',
    'class',
    'class_',
    'a__b',
    '_auth',
    '9auth',
    'nul',
    'a-b',
    'é',
    'string',
    'a' * 65,
  ]) {
    test('rejects invalid or reserved name "$name"', () {
      expect(() => validateName(name), throwsA(isA<GenerationException>()));
    });
  }

  test('menu cancellation is read only and does not invoke commands', () async {
    final output = StringBuffer();
    final error = StringBuffer();
    final before = project.read('pubspec.yaml');
    final answers = ['7', 'com.example.playground', '1', '2', '0'].iterator;
    final code = await runCli(
      [],
      projectRoot: directory.path,
      output: output,
      error: error,
      readLine: () => answers.moveNext() ? answers.current : null,
      executor: (_, _, _) async => throw StateError('must not execute'),
    );
    expect(code, 0, reason: error.toString());
    expect(output.toString(), contains('Cancelled. No files were changed.'));
    expect(output.toString(), isNot(contains('Preview diff only')));
    expect(project.read('pubspec.yaml'), before);
    expect(Directory(project.file('.cleany')).existsSync(), isFalse);
  });

  test('custom path, subfeatures, components and central DI', () async {
    await initialize();
    await apply(
      generator.generate(
        name: 'auth',
        state: StateManagement.cubit,
        path: 'lib/modules/account',
      ),
    );
    await apply(
      generator.generate(
        name: 'profile',
        state: StateManagement.bloc,
        parent: 'auth',
      ),
    );
    await apply(
      generator.generate(
        name: 'header',
        kind: GenerationKind.component,
        state: StateManagement.none,
        parent: 'auth',
      ),
    );
    expect(
      File(
        project.file(
          'lib/modules/account/auth/subfeatures/profile/domain/usecases/get_profile.dart',
        ),
      ).existsSync(),
      isTrue,
    );
    final entries = generator.readRegistry()['features'] as List;
    expect(entries.length, 3);
    expect(entries.last['path'], 'lib/modules/account/auth/subfeatures/header');
    expect(
      project.read('lib/app/di/injection.dart'),
      contains('registerFactory<AuthCubit>'),
    );
    expect(
      project.read('lib/app/di/injection.dart'),
      contains('registerLazySingleton<AuthRepository>'),
    );
    final router = project.read('lib/app/router/app_router.dart');
    expect(router, contains('FeaturePages.profile(container)'));
    expect(router, isNot(contains('Cubit')));
    expect(router, isNot(contains('BlocProvider')));
    expect(router, isNot(contains('header')));
    expect(
      Directory(project.file('lib/modules/account/auth/di')).existsSync(),
      isFalse,
    );
  });

  test('all component state options use small templates', () async {
    await initialize();
    for (final mode in StateManagement.values) {
      final path = 'lib/components/card_${mode.name}';
      await apply(
        generator.generate(
          name: 'card_${mode.name}',
          kind: GenerationKind.component,
          state: mode,
        ),
      );
      expect(Directory(project.file('$path/data')).existsSync(), isFalse);
      expect(Directory(project.file('$path/domain')).existsSync(), isFalse);
      expect(
        Directory(project.file('$path/${mode.name}')).existsSync(),
        mode != StateManagement.none,
      );
    }
  });

  test('datasource propagates JSON, repository maps once, presentation uses entity', () async {
    await initialize();
    await apply(generator.generate(name: 'auth', state: StateManagement.cubit));
    final remote = project.read(
      'lib/features/auth/data/datasources/auth_remote_data_source.dart',
    );
    expect(remote, contains('Future<Map<String, dynamic>>'));
    expect(remote, isNot(contains('catch')));
    final repository = project.read(
      'lib/features/auth/data/repositories/auth_repository_impl.dart',
    );
    expect(repository, contains('AuthModel.fromJson(json)'));
    expect(repository, contains('Success(AuthEntity(id: model.id))'));
    expect(repository, contains('final failure = mapFailure(error)'));
    final cubit = project.read(
      'lib/features/auth/presentation/cubit/auth_cubit.dart',
    );
    expect(cubit, contains('AuthState.loading()'));
    expect(cubit, contains('AuthState.success(entity)'));
    expect(cubit, contains('AuthState.failure(failure)'));
    expect(cubit, contains('if (isClosed) return'));
    final domainFiles = Directory(project.file('lib/features/auth/domain'))
        .listSync(recursive: true)
        .whereType<File>();
    for (final file in domainFiles) {
      expect(file.readAsStringSync(), isNot(contains('package:dio')));
      expect(file.readAsStringSync(), isNot(contains('get_it')));
    }
  });

  test('Dio provider omits Retrofit packages and generated APIs', () async {
    await initialize(provider: ApiProvider.dio);
    await apply(generator.generate(name: 'auth', state: StateManagement.bloc));
    expect(project.read('pubspec.yaml'), isNot(contains('retrofit')));
    expect(
      project.read(
        'lib/features/auth/data/datasources/auth_remote_data_source.dart',
      ),
      contains('_dio.get'),
    );
  });

  test(
    'names collide across paths and after snake case normalization',
    () async {
      await initialize();
      await apply(
        generator.generate(name: 'foo_bar', state: StateManagement.cubit),
      );
      expect(
        () => generator.generate(
          name: 'foo_bar',
          state: StateManagement.bloc,
          path: 'lib/custom',
        ),
        throwsA(isA<GenerationException>()),
      );
      expect(
        () => generator.generate(name: 'foo__bar', state: StateManagement.bloc),
        throwsA(isA<GenerationException>()),
      );
      File(project.file('lib/user.dart'))
          .writeAsStringSync('class OtherCubit {}');
      expect(
        () => generator.generate(name: 'other', state: StateManagement.cubit),
        throwsA(isA<GenerationException>()),
      );
    },
  );

  test('unsafe paths and symlinks are rejected', () async {
    await initialize();
    for (final path in [
      '../lib/features',
      '/tmp/features',
      'lib/../assets',
      'lib/features/../../other',
      'lib\\features',
      'lib/Foo',
    ]) {
      expect(
        () => generator.generate(
          name: 'auth',
          state: StateManagement.cubit,
          path: path,
        ),
        throwsA(isA<GenerationException>()),
      );
    }
    if (!Platform.isWindows) {
      Link('${directory.path}/lib/linked').createSync(directory.path);
      expect(
        () => generator.generate(
          name: 'auth',
          state: StateManagement.cubit,
          path: 'lib/linked',
        ),
        throwsA(isA<GenerationException>()),
      );
    }
  });

  test(
    'menu selects state by number each time and rejects command arguments',
    () async {
      await initialize();
      final output = StringBuffer();
      final error = StringBuffer();
      expect(
        await runCli(
          ['feature', 'auth'],
          projectRoot: directory.path,
          output: output,
          error: error,
        ),
        64,
      );
      final answers = ['1', 'auth', '2', '1', '1', '2', '0'].iterator;
      expect(
        await runCli(
          [],
          projectRoot: directory.path,
          output: output,
          error: error,
          useColor: true,
          readLine: () => answers.moveNext() ? answers.current : null,
        ),
        0,
      );
      expect(output.toString(), contains('auth_bloc.dart'));
      expect(output.toString(), contains('\x1B['));
      expect(output.toString(), contains('Remove component'));
      expect(
        Directory(project.file('lib/features/auth')).existsSync(),
        isFalse,
      );
    },
  );

  for (final state in ['1', '2']) {
    test(
      'compact response fields create a feature using state $state without transport prompts',
      () async {
        await initialize();
        final answers = [
          '١',
          'home',
          state,
          '1',
          '2',
          '٣',
          'userName:string:home',
          'y',
          'favourite:list<string>:favourite',
          'Y',
          'age:int:age',
          'yes',
          '1',
          '0',
        ].iterator;
        final output = StringBuffer();
        final errors = StringBuffer();
        final commands = <String>[];
        final code = await runCli(
          [],
          projectRoot: directory.path,
          output: output,
          error: errors,
          useColor: false,
          readLine: () => answers.moveNext() ? answers.current : null,
          executor: (executable, arguments, _) async {
            commands.add('$executable ${arguments.join(' ')}');
            return const CommandResult(0, '', '');
          },
        );
        expect(code, 0, reason: errors.toString());
        expect(commands, contains('flutter analyze --no-pub'));
        final record =
            (generator.readRegistry()['features'] as List).single as Map;
        expect(record['specification']['fields'], [
          {'name': 'userName', 'type': 'String?', 'json_key': 'home'},
          {
            'name': 'favourite',
            'type': 'List<String>?',
            'json_key': 'favourite',
          },
          {'name': 'age', 'type': 'int?', 'json_key': 'age'},
        ]);
        expect(record['specification']['request_fields'], isEmpty);
        expect(
          File(
            project.file('lib/features/home/domain/entities/home_request.dart'),
          ).existsSync(),
          isFalse,
        );
        final model = project.read(
          'lib/features/home/data/models/home_model.dart',
        );
        expect(model, contains('@JsonKey(name: "home")'));
        expect(model, contains('List<String>? favourite'));
        for (final prompt in [
          'HTTP method',
          'API endpoint',
          'Request data',
          'Dart type',
          '› JSON key',
        ]) {
          expect(output.toString(), isNot(contains(prompt)));
        }
        expect(output.toString(), contains('Nullable [3] (y/N)'));
        expect(output.toString(), contains('Review changes'));
      },
    );
  }

  test('compact field validation retries the current prompt and preserves earlier fields', () async {
    await initialize();
    final answers = [
      '1',
      'home',
      '1',
      '1',
      '2',
      '0',
      '2',
      'broken',
      'userName:uuid:home',
      'userName: STRING :home',
      'maybe',
      'n',
      'userName:int:age',
      'age:int:home',
      'age:int:age',
      '',
      '1',
      '0',
    ].iterator;
    final output = StringBuffer();
    final errors = StringBuffer();
    final code = await runCli(
      [],
      projectRoot: directory.path,
      output: output,
      error: errors,
      useColor: false,
      readLine: () => answers.moveNext() ? answers.current : null,
      executor: (_, _, _) async => const CommandResult(0, '', ''),
    );
    expect(code, 0, reason: errors.toString());
    final fields =
        (generator.readRegistry()['features'] as List)
                .single['specification']['fields']
            as List;
    expect(fields.map((field) => field['type']), ['String', 'int']);
    expect(
      output.toString(),
      contains('Field names and JSON keys must be unique.'),
    );
    expect(output.toString(), contains('Enter y or n'));
    expect(output.toString(), isNot(contains('Retry this action')));
  });

  test(
    'EOF during compact fields cancels without creating a feature',
    () async {
      await initialize();
      final before = project.read(registryPath);
      final answers = [
        '1',
        'home',
        '1',
        '1',
        '2',
        '2',
        'userName:string:home',
        'y',
        'age:int:age',
      ].iterator;
      final code = await runCli(
        [],
        projectRoot: directory.path,
        output: StringBuffer(),
        error: StringBuffer(),
        readLine: () => answers.moveNext() ? answers.current : null,
        executor: (_, _, _) async => throw StateError('Must not execute'),
      );
      expect(code, 0);
      expect(project.read(registryPath), before);
      expect(
        Directory(project.file('lib/features/home')).existsSync(),
        isFalse,
      );
    },
  );

  test('registry corruption stops generation', () async {
    await initialize();
    File(project.file(registryPath)).writeAsStringSync('{"version":99}');
    expect(
      () => generator.generate(name: 'auth', state: StateManagement.cubit),
      throwsA(isA<GenerationException>()),
    );
  });

  test('failed commands never commit and return nonzero status', () async {
    final before = project.read('pubspec.yaml');
    final errors = StringBuffer();
    final answers = ['7', 'com.example.playground', '1', '1'].iterator;
    final code = await runCli(
      [],
      projectRoot: directory.path,
      output: StringBuffer(),
      error: errors,
      readLine: () => answers.moveNext() ? answers.current : null,
      executor: (_, _, _) async => const CommandResult(42, '', 'offline'),
    );
    expect(code, 1);
    expect(errors.toString(), contains('failed (42)'));
    expect(project.read('pubspec.yaml'), before);
    expect(Directory(project.file('lib')).existsSync(), isFalse);
    expect(File(project.file('.cleany/lock')).existsSync(), isFalse);
  });

  test('write failure rolls back overwritten files, new files, registry, and directories', () async {
    final before = project.read('pubspec.yaml');
    final plan = GenerationPlan(project)
      ..write('pubspec.yaml', 'changed')
      ..write('lib/deep/new.dart', 'new')
      ..write('last.txt', 'fail here');
    await expectLater(
      GenerationTransaction(project).apply(
        plan,
        install: false,
        build: false,
        analyze: false,
        beforeWrite: (path) {
          if (path == 'last.txt') throw StateError('disk failure');
        },
      ),
      throwsStateError,
    );
    expect(project.read('pubspec.yaml'), before);
    expect(Directory(project.file('lib')).existsSync(), isFalse);
    expect(
      Directory(project.file('.cleany/transaction')).existsSync(),
      isFalse,
    );
  });

  test(
    'concurrent generation lock and stale plans preserve user edits',
    () async {
      final plan = generator.initialize(appId: 'com.example.playground');
      final lock = await ProjectLock.acquire(project);
      await expectLater(apply(plan), throwsA(isA<GenerationException>()));
      await lock.release();
      File(project.file('pubspec.yaml')).writeAsStringSync('user edit');
      await expectLater(apply(plan), throwsA(isA<GenerationException>()));
      expect(project.read('pubspec.yaml'), 'user edit');
    },
  );

  test('durable journal recovers interrupted writes', () async {
    final before = project.read('pubspec.yaml');
    Directory(project.file('.cleany/transaction')).createSync(recursive: true);
    File(project.file('.cleany/transaction/manifest.json')).writeAsStringSync(
      jsonEncode({
        'version': 1,
        'files': {
          'pubspec.yaml': {
            'before': base64Encode(utf8.encode(before)),
            'after': base64Encode(utf8.encode('partial write')),
          },
        },
      }),
    );
    File(project.file('pubspec.yaml')).writeAsStringSync('partial write');
    await GenerationTransaction(project).recover();
    expect(project.read('pubspec.yaml'), before);
  });

  test('staged outputs are included and checked before commit', () async {
    final calls = <String>[];
    await GenerationTransaction(
      project,
      executor: (exe, args, cwd) async {
        calls.add('$exe ${args.join(' ')}');
        if (exe == 'dart') {
          File('$cwd/lib/generated.g.dart').writeAsStringSync('// generated\n');
        }
        return const CommandResult(0, '', '');
      },
    ).apply(generator.initialize(appId: 'com.example.playground'));
    expect(calls, [
      'flutter pub get',
      'flutter gen-l10n',
      'dart run build_runner build --delete-conflicting-outputs',
      'flutter analyze --no-pub',
    ]);
    expect(project.read('lib/generated.g.dart'), '// generated\n');
  });

  test('AST integration survives nested blocks, comments and strings', () {
    final editor = AstEditor('''
// import 'fake.dart';
void registerFeatureDependencies(Object container) {
  if (true) { print('}'); }
  final callback = () { print('nested'); };
}
void unrelated() {}
''');
    editor.addImports(['real.dart', 'real.dart']);
    editor.addStatements('registerFeatureDependencies', 'registerAuth();');
    expect(
      editor.source.indexOf('registerAuth();'),
      greaterThan(editor.source.indexOf("print('nested')")),
    );
    expect(
      editor.source.indexOf('registerAuth();'),
      lessThan(editor.source.indexOf('void unrelated')),
    );
    expect("import 'real.dart';".allMatches(editor.source).length, 1);
    expect(
      () => AstEditor('void x() => 1;').addStatements('x', 'a();'),
      throwsA(isA<GenerationException>()),
    );
  });

  test(
    'AST preserves library and part ordering and rejects member collisions',
    () {
      final editor = AstEditor(
        "library sample;\npart 'sample.g.dart';\nclass Names { static const auth = '/auth'; }",
      );
      editor.addImports(['auth.dart']);
      expect(
        editor.source.indexOf("import 'auth.dart'"),
        lessThan(editor.source.indexOf("part 'sample.g.dart'")),
      );
      expect(
        editor.source.indexOf("import 'auth.dart'"),
        greaterThan(editor.source.indexOf('library sample;')),
      );
      expect(
        () => editor.addMembers('Names', "static const auth = '/other';"),
        throwsA(isA<GenerationException>()),
      );
      expect(
        () => editor.requireUnusedRoutePath('/auth'),
        throwsA(isA<GenerationException>()),
      );
    },
  );

  test('rollback preserves pre-existing empty directories', () async {
    Directory(project.file('lib/existing')).createSync(recursive: true);
    final plan = GenerationPlan(project)
      ..write('lib/existing/new.dart', 'new')
      ..write('last.txt', 'fail');
    await expectLater(
      GenerationTransaction(project).apply(
        plan,
        install: false,
        build: false,
        analyze: false,
        beforeWrite: (path) {
          if (path == 'last.txt') throw StateError('failure');
        },
      ),
      throwsStateError,
    );
    expect(Directory(project.file('lib/existing')).existsSync(), isTrue);
    expect(Directory(project.file('lib/existing')).listSync(), isEmpty);
  });

  test('user edit during staging prevents every commit', () async {
    final before = project.read('pubspec.yaml');
    final transaction = GenerationTransaction(
      project,
      executor: (_, _, _) async {
        Directory(project.file('lib')).createSync(recursive: true);
        File(project.file('lib/new_user_file.dart'))
            .writeAsStringSync('// user edit');
        return const CommandResult(0, '', '');
      },
    );
    await expectLater(
      transaction.apply(generator.initialize(appId: 'com.example.playground')),
      throwsA(isA<GenerationException>()),
    );
    expect(project.read('pubspec.yaml'), before);
    expect(project.read('lib/new_user_file.dart'), '// user edit');
  });

  test('relative dependency paths are rebased only in staging', () async {
    File(project.file('pubspec.yaml')).writeAsStringSync(
      project
          .read('pubspec.yaml')
          .replaceFirst(
            '  flutter:',
            '  local_package:\n    path: ../local_package\n  flutter:',
          ),
    );
    final transaction = GenerationTransaction(
      project,
      executor: (_, args, cwd) async {
        final staged =
            loadYaml(File('$cwd/pubspec.yaml').readAsStringSync()) as Map;
        expect(
          staged['dependencies']['local_package']['path'],
          isNot('../local_package'),
        );
        if (args.contains('get')) {
          File('$cwd/pubspec.lock').writeAsStringSync('''
packages:
  local_package:
    source: path
    description:
      path: "/absolute/staging/path"
      relative: false
''');
        }
        return const CommandResult(0, '', '');
      },
    );
    await transaction.apply(
      generator.initialize(appId: 'com.example.playground'),
    );
    final lock = loadYaml(project.read('pubspec.lock')) as Map;
    expect(
      lock['packages']['local_package']['description']['path'],
      '../local_package',
    );
    expect(
      lock['packages']['local_package']['description']['relative'],
      isTrue,
    );
    expect(project.read('pubspec.yaml'), contains('path: ../local_package'));
  });

  test('recovery preserves concurrent user edits and its backup', () async {
    Directory(project.file('.cleany/transaction')).createSync(recursive: true);
    File(project.file('.cleany/transaction/manifest.json')).writeAsStringSync(
      jsonEncode({
        'version': 1,
        'files': {
          'pubspec.yaml': {
            'before': base64Encode(utf8.encode('original')),
            'after': base64Encode(utf8.encode('generated')),
          },
        },
      }),
    );
    final original = project.read('pubspec.yaml');
    await expectLater(
      GenerationTransaction(project).recover(),
      throwsA(isA<GenerationException>()),
    );
    expect(project.read('pubspec.yaml'), original);
    expect(
      File(project.file('.cleany/transaction/manifest.json')).existsSync(),
      isTrue,
    );
  });

  test('planned null snapshots stay null even if a new file appears', () async {
    final plan = GenerationPlan(project)..write('new.txt', 'first');
    File(project.file('new.txt')).writeAsStringSync('user edit');
    plan.write('new.txt', 'second');
    await expectLater(apply(plan), throwsA(isA<GenerationException>()));
    expect(project.read('new.txt'), 'user edit');
  });

  test('reverting a planned edit removes the change', () {
    final before = project.read('pubspec.yaml');
    final plan = GenerationPlan(project)..write('pubspec.yaml', 'change');
    plan.write('pubspec.yaml', before);
    expect(plan.files, isEmpty);
  });

  test(
    'recovery clears interrupted temporary writes before restoring',
    () async {
      final before = project.read('pubspec.yaml');
      Directory(project.file('.cleany/transaction'))
          .createSync(recursive: true);
      File(project.file('.cleany/transaction/manifest.json')).writeAsStringSync(
        jsonEncode({
          'version': 1,
          'files': {
            'pubspec.yaml': {
              'before': base64Encode(utf8.encode(before)),
              'after': base64Encode(utf8.encode('generated')),
            },
          },
        }),
      );
      File(project.file('pubspec.yaml.cleany-tmp'))
          .writeAsStringSync('partial');
      await GenerationTransaction(project).recover();
      expect(project.read('pubspec.yaml'), before);
      expect(
        File(project.file('pubspec.yaml.cleany-tmp')).existsSync(),
        isFalse,
      );
    },
  );
  test(
    'staging excludes root platforms but preserves similarly named features',
    () async {
      Directory(project.file('android')).createSync();
      File(project.file('android/native.txt')).writeAsStringSync('platform');
      Directory(project.file('lib/features/web')).createSync(recursive: true);
      File(project.file('lib/features/web/web.dart'))
          .writeAsStringSync('// source');
      await GenerationTransaction(
        project,
        executor: (_, _, cwd) async {
          expect(File('$cwd/android/native.txt').existsSync(), isFalse);
          expect(
            File('$cwd/lib/features/web/web.dart').readAsStringSync(),
            '// source',
          );
          return const CommandResult(0, '', '');
        },
      ).apply(generator.initialize(appId: 'com.example.playground'));
    },
  );
  test('detects native production app id and derives flavor suffixes', () {
    Directory(project.file('android/app')).createSync(recursive: true);
    File(project.file('android/app/build.gradle.kts')).writeAsStringSync('''
android {
  namespace = "com.example.namespace"
  defaultConfig {
    applicationId = "com.example.playground"
    testInstrumentationRunnerArguments["x"] = "value"
  }
}
''');
    expect(project.detectAppId(), 'com.example.playground');
    final plan = generator.initialize();
    final flavor = loadYaml(plan.read('flavorizr.yaml')) as Map;
    expect(
      flavor['flavors']['prod']['android']['applicationId'],
      'com.example.playground',
    );
    expect(
      flavor['flavors']['dev']['android']['applicationId'],
      'com.example.playground.dev',
    );
    expect(
      flavor['flavors']['uat']['ios']['bundleId'],
      'com.example.playground.uat',
    );
  });

  test(
    'detects Groovy application id and iOS ids while excluding test bundles',
    () {
      Directory(project.file('android/app')).createSync(recursive: true);
      File(project.file('android/app/build.gradle')).writeAsStringSync(
        'android { defaultConfig { applicationId "com.company.product" } }',
      );
      Directory(project.file('ios/Runner.xcodeproj'))
          .createSync(recursive: true);
      File(project.file('ios/Runner.xcodeproj/project.pbxproj'))
          .writeAsStringSync(
            'PRODUCT_BUNDLE_IDENTIFIER = com.company.product;\n'
            'PRODUCT_BUNDLE_IDENTIFIER = com.company.product.RunnerTests;',
          );
      expect(project.applicationIds(), ['com.company.product']);
      File(project.file('android/app/build.gradle')).deleteSync();
      expect(project.detectAppId(), 'com.company.product');
    },
  );

  test(
    'ambiguous native ids require a choice rather than changing production id',
    () {
      Directory(project.file('android/app')).createSync(recursive: true);
      File(project.file('android/app/build.gradle')).writeAsStringSync(
        'defaultConfig { applicationId "com.android.product" }',
      );
      Directory(project.file('ios/Runner.xcodeproj'))
          .createSync(recursive: true);
      File(project.file('ios/Runner.xcodeproj/project.pbxproj'))
          .writeAsStringSync('PRODUCT_BUNDLE_IDENTIFIER = com.ios.product;');
      expect(project.applicationIds().length, 2);
      expect(() => project.detectAppId(), throwsA(isA<GenerationException>()));
    },
  );

  test(
    'init configures official ARB localization and documents every Dart file',
    () {
      final plan = generator.initialize(appId: 'com.example.playground');
      final pubspec = loadYaml(plan.read('pubspec.yaml')) as Map;
      expect(
        pubspec['dependencies']['flutter_localizations']['sdk'],
        'flutter',
      );
      expect(pubspec['dependencies'].containsKey('easy_localization'), isFalse);
      expect(pubspec['flutter']['generate'], isTrue);
      expect(plan.read('assets/translations/app_ar.arb'), contains('مرحبًا'));
      expect(
        plan.read('lib/app/app.dart'),
        contains('AppLocalizations.supportedLocales'),
      );
      for (final path in plan.files.keys.where(
        (path) => path.endsWith('.dart'),
      )) {
        expect(plan.read(path), startsWith('// '), reason: path);
        expect(plan.read(path), contains('///'), reason: path);
      }
    },
  );

  test('feature and stateful component builds read their controller explicitly', () async {
    await initialize();
    for (final mode in [StateManagement.cubit, StateManagement.bloc]) {
      final feature = generator.generate(name: 'sample', state: mode);
      expect(
        feature.read('lib/features/sample/presentation/pages/sample_page.dart'),
        contains(
          'final _ = context.read<Sample${mode == StateManagement.cubit ? 'Cubit' : 'Bloc'}>();',
        ),
      );
      final component = generator.generate(
        name: 'card',
        kind: GenerationKind.component,
        state: mode,
      );
      expect(
        component.read('lib/components/card/widgets/card_widget.dart'),
        contains(
          'final _ = context.read<Card${mode == StateManagement.cubit ? 'Cubit' : 'Bloc'}>();',
        ),
      );
      for (final path in component.files.keys.where(
        (p) => p.startsWith('lib/components/') && p.endsWith('.dart'),
      )) {
        expect(component.read(path), contains('///'), reason: path);
      }
    }
    final component = generator.generate(
      name: 'plain',
      kind: GenerationKind.component,
      state: StateManagement.none,
    );
    expect(
      component.read('lib/components/plain/widgets/plain_widget.dart'),
      isNot(contains('context.read')),
    );
  });

  test(
    'removal updates registry, DI, factories, routes and nested entries',
    () async {
      await initialize();
      await apply(
        generator.generate(name: 'auth', state: StateManagement.cubit),
      );
      await apply(
        generator.generate(
          name: 'profile',
          state: StateManagement.bloc,
          parent: 'auth',
        ),
      );
      await apply(
        generator.generate(
          name: 'card',
          kind: GenerationKind.component,
          state: StateManagement.cubit,
          parent: 'auth',
        ),
      );
      await apply(
        generator.generate(name: 'catalog', state: StateManagement.bloc),
      );
      File(project.file('lib/core/network/retrofit/auth_api.g.dart'))
          .writeAsStringSync('// generated');
      final plan = generator.remove(name: 'auth', kind: GenerationKind.feature);
      expect(plan.preview(), contains('+++ /dev/null'));
      await apply(plan);
      expect(
        Directory(project.file('lib/features/auth')).existsSync(),
        isFalse,
      );
      expect(
        File(project.file('lib/core/network/retrofit/auth_api.g.dart'))
            .existsSync(),
        isTrue,
      );
      expect(
        (generator.readRegistry()['features'] as List).single['name'],
        'catalog',
      );
      expect(
        project.read('lib/app/di/injection.dart'),
        isNot(contains('AuthCubit')),
      );
      expect(
        project.read('lib/app/di/injection.dart'),
        contains('CatalogBloc'),
      );
      expect(
        project.read('lib/app/router/app_router.dart'),
        isNot(contains('RouteNames.auth')),
      );
      expect(
        project.read('lib/app/router/route_names.dart'),
        isNot(contains("'/auth'")),
      );
      expect(
        project.read('lib/app/composition/feature_pages.dart'),
        isNot(contains('ProfilePage')),
      );
    },
  );

  test(
    'last component removal cleans state imports and retains other kinds',
    () async {
      await initialize();
      await apply(
        generator.generate(
          name: 'card',
          kind: GenerationKind.component,
          state: StateManagement.bloc,
        ),
      );
      await apply(
        generator.remove(name: 'card', kind: GenerationKind.component),
      );
      expect(
        project.read('lib/app/composition/feature_pages.dart'),
        isNot(contains('flutter_bloc')),
      );
      expect(
        () => generator.remove(name: 'card', kind: GenerationKind.feature),
        throwsA(isA<GenerationException>()),
      );
    },
  );

  test('failed deletion restores files and registry byte for byte', () async {
    await initialize();
    await apply(generator.generate(name: 'auth', state: StateManagement.cubit));
    final registry = project.read(registryPath);
    final source = project.read(
      'lib/features/auth/domain/entities/auth_entity.dart',
    );
    final plan = generator.remove(name: 'auth', kind: GenerationKind.feature);
    await expectLater(
      GenerationTransaction(project).apply(
        plan,
        install: false,
        build: false,
        analyze: false,
        beforeWrite: (path) {
          if (path == registryPath) throw StateError('failure');
        },
      ),
      throwsStateError,
    );
    expect(project.read(registryPath), registry);
    expect(
      project.read('lib/features/auth/domain/entities/auth_entity.dart'),
      source,
    );
  });

  test('menu remove cancellation preserves the selected component', () async {
    await initialize();
    await apply(
      generator.generate(
        name: 'card',
        kind: GenerationKind.component,
        state: StateManagement.cubit,
      ),
    );
    final answers = ['4', '6', '1', '2', '0'].iterator;
    final output = StringBuffer();
    final errors = StringBuffer();
    expect(
      await runCli(
        [],
        projectRoot: directory.path,
        output: output,
        error: errors,
        readLine: () => answers.moveNext() ? answers.current : null,
      ),
      0,
      reason: errors.toString(),
    );
    expect(output.toString(), contains('REMOVE'));
    expect(Directory(project.file('lib/components/card')).existsSync(), isTrue);
  });
  test(
    'menu initializes with detected id without asking for a replacement',
    () async {
      Directory(project.file('android/app')).createSync(recursive: true);
      File(project.file('android/app/build.gradle.kts')).writeAsStringSync(
        'defaultConfig { applicationId = "com.example.detected" }',
      );
      final answers = ['7', '1', '2', '0'].iterator;
      final output = StringBuffer();
      final errors = StringBuffer();
      expect(
        await runCli(
          [],
          projectRoot: directory.path,
          output: output,
          error: errors,
          readLine: () => answers.moveNext() ? answers.current : null,
        ),
        0,
        reason: errors.toString(),
      );
      expect(
        output.toString(),
        contains('Detected production app id: com.example.detected'),
      );
      expect(output.toString(), contains('com.example.detected.dev'));
      expect(output.toString(), isNot(contains('Production app id (example:')));
      expect(File(project.file(registryPath)).existsSync(), isFalse);
    },
  );

  test(
    'numbered create and remove actions apply without command flags',
    () async {
      await initialize();
      final answers = [
        '1',
        'auth',
        '1',
        '1',
        '1',
        '1',
        '3',
        '5',
        '1',
        '1',
        '0',
      ].iterator;
      final errors = StringBuffer();
      final output = StringBuffer();
      var validations = 0;
      expect(
        await runCli(
          [],
          projectRoot: directory.path,
          output: output,
          error: errors,
          readLine: () => answers.moveNext() ? answers.current : null,
          executor: (_, args, _) async {
            if (args.contains('analyze')) validations++;
            return const CommandResult(0, '', '');
          },
        ),
        0,
        reason: errors.toString(),
      );
      expect(validations, 2);
      expect(
        output.toString(),
        contains('Completed. Staged generation and analysis passed.'),
      );
      expect(
        Directory(project.file('lib/features/auth')).existsSync(),
        isFalse,
      );
      expect(generator.readRegistry()['features'], isEmpty);
    },
  );

  test(
    'incomplete menu input cancels creation without modifying files',
    () async {
      await initialize();
      final before = project.read(registryPath);
      final answers = ['1', 'auth'].iterator;
      expect(
        await runCli(
          [],
          projectRoot: directory.path,
          output: StringBuffer(),
          error: StringBuffer(),
          readLine: () => answers.moveNext() ? answers.current : null,
        ),
        0,
      );
      expect(project.read(registryPath), before);
      expect(
        Directory(project.file('lib/features/auth')).existsSync(),
        isFalse,
      );
    },
  );
}
