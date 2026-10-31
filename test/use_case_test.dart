import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:cleany/cleany.dart';
import 'package:cleany/src/cli.dart';
import 'package:cleany/src/ast_editor.dart';
import 'package:cleany/src/registry.dart';
import 'package:cleany/src/templates/use_case_templates.dart';
import 'package:cleany/src/templates/feature_templates.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late Project project;
  late Generator generator;
  setUp(() {
    directory = Directory.systemTemp.createTempSync('cleany_use_case_');
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
  Future<void> source(GenerationPlan plan) =>
      GenerationTransaction(project)
          .apply(plan, install: false, build: false, analyze: false);
  Future<void> initialize({ApiProvider provider = ApiProvider.retrofit}) =>
      source(
        generator.initialize(appId: 'com.example.fixture', provider: provider),
      );

  for (final mode in [StateManagement.cubit, StateManagement.bloc]) {
    for (final provider in ApiProvider.values) {
      test(
        'adds independent entity and void actions for ${mode.name}/${provider.name}',
        () async {
          await initialize(provider: provider);
          await source(
            generator.generate(
              name: 'profile',
              state: mode,
              path: 'lib/modules/account',
              specification: FeatureSpec(
                fields: [FieldSpec('id', 'String'), FieldSpec('age', 'int?')],
              ),
            ),
          );
          const root = 'lib/modules/account/profile';
          final page = project.read(
            '$root/presentation/pages/profile_page.dart',
          );
          final entity = project.read(
            '$root/domain/entities/profile_entity.dart',
          );
          final model = project.read('$root/data/models/profile_model.dart');
          final plan = generator.addUseCase(
            feature: 'profile',
            name: 'refresh_profile',
            returnType: UseCaseReturnType.entity,
          );
          expect(
            plan.files.containsKey(
              '$root/domain/repositories/profile_repository.dart',
            ),
            isTrue,
          );
          expect(
            plan.files.containsKey(
              '$root/data/repositories/profile_repository_impl.dart',
            ),
            isTrue,
          );
          expect(
            plan.read('$root/data/repositories/profile_repository_impl.dart'),
            contains('ProfileModel.fromJson(json)'),
          );
          expect(
            plan.read('$root/data/repositories/profile_repository_impl.dart'),
            contains('age: model.age'),
          );
          expect(
            plan.read('$root/data/datasources/profile_remote_data_source.dart'),
            contains('throw UnimplementedError'),
          );
          expect(
            plan.files.containsKey(
              '$root/domain/repositories/refresh_profile_repository.dart',
            ),
            isFalse,
          );
          expect(
            plan.read('$root/domain/usecases/refresh_profile.dart'),
            contains('final ProfileRepository _repository'),
          );
          final di = plan.read('lib/app/di/injection.dart');
          expect(di, isNot(contains('RefreshProfileRepository')));
          expect(
            di,
            contains('RefreshProfile(container<ProfileRepository>())'),
          );
          expect(
            di,
            contains('refreshProfileUseCase: container<RefreshProfile>()'),
          );
          expect(
            di.indexOf('registerLazySingleton<RefreshProfile>'),
            lessThan(di.indexOf('registerFactory<Profile')),
          );
          for (final entry in plan.files.entries.where(
            (entry) => entry.key.endsWith('.dart'),
          )) {
            expect(
              parseString(
                content: utf8.decode(entry.value.after!),
                throwIfDiagnostics: false,
              ).errors,
              isEmpty,
              reason: entry.key,
            );
          }
          await source(plan);
          await source(
            generator.addUseCase(
              feature: 'profile',
              name: 'clear_profile',
              returnType: UseCaseReturnType.voidResult,
            ),
          );
          final state = project.read(
            '$root/presentation/${mode.name}/profile_state.dart',
          );
          expect('refreshProfileStatus'.allMatches(state).length, 4);
          expect('clearProfileStatus'.allMatches(state).length, 4);
          final controller = project.read(
            '$root/presentation/${mode.name}/profile_${mode.name}.dart',
          );
          expect(
            controller,
            contains('refreshProfileStatus: state.refreshProfileStatus'),
          );
          expect(
            controller,
            contains('clearProfileStatus: state.clearProfileStatus'),
          );
          expect(controller, contains('state.copyWith('));
          // Constant named constructors have a different unresolved AST shape
          // from success/failure calls. Loading must preserve action progress.
          expect(controller, isNot(contains('const ProfileState.loading()')));
          expect(controller, contains('ProfileState.loading(\n'));
          expect(
            project.read('$root/domain/usecases/clear_profile.dart'),
            contains('Result<void, Failure>'),
          );
          expect(
            project.read('$root/presentation/pages/profile_page.dart'),
            page,
          );
          expect(
            project.read('$root/domain/entities/profile_entity.dart'),
            entity,
          );
          expect(project.read('$root/data/models/profile_model.dart'), model);
          final entry =
              (FeatureRegistry(project).read()['features'] as List).single;
          expect((entry['use_cases'] as List).length, 2);
          expect(
            (entry['integrations'] as List).any(
              (record) => record['node'] == 'DI.RefreshProfile',
            ),
            isTrue,
          );
          expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
        },
      );
    }
  }

  test(
    'validates selection, names, collisions and preserves read-only plans',
    () async {
      await initialize();
      await source(
        generator.generate(
          name: 'card',
          kind: GenerationKind.component,
          state: StateManagement.cubit,
        ),
      );
      expect(
        () => generator.addUseCase(
          feature: 'card',
          name: 'refresh_card',
          returnType: UseCaseReturnType.entity,
        ),
        throwsA(isA<GenerationException>()),
      );
      await source(
        generator.generate(name: 'home', state: StateManagement.cubit),
      );
      for (final name in [
        '../escape',
        'close',
        'load',
        'fetch',
        'on_error',
        'use_case_state',
      ]) {
        expect(
          () => generator.addUseCase(
            feature: 'home',
            name: name,
            returnType: UseCaseReturnType.voidResult,
          ),
          throwsA(isA<GenerationException>()),
        );
      }
      expect(
        () => generator.addUseCase(
          feature: 'home',
          name: 'get_home',
          returnType: UseCaseReturnType.entity,
        ),
        throwsA(isA<GenerationException>()),
      );
      final plan = generator.addUseCase(
        feature: 'home',
        name: 'refresh_home',
        returnType: UseCaseReturnType.entity,
      );
      expect(
        File(
          project.file('lib/features/home/domain/usecases/refresh_home.dart'),
        ).existsSync(),
        isFalse,
      );
      await source(plan);
      expect(
        () => generator.addUseCase(
          feature: 'home',
          name: 'refresh_home',
          returnType: UseCaseReturnType.entity,
        ),
        throwsA(isA<GenerationException>()),
      );
      final registry = jsonDecode(project.read(registryPath)) as Map;
      (registry['features'] as List).firstWhere(
        (entry) => entry['name'] == 'home',
      )['use_cases'][0]['return_type'] = 'String';
      File(project.file(registryPath)).writeAsStringSync(jsonEncode(registry));
      expect(
        () => FeatureRegistry(project).read(),
        throwsA(isA<GenerationException>()),
      );
    },
  );

  test('Doctor restores operation sources and shared state and rebuilds lost metadata', () async {
    await initialize();
    await source(generator.generate(name: 'home', state: StateManagement.bloc));
    await source(
      generator.addUseCase(
        feature: 'home',
        name: 'refresh_home',
        returnType: UseCaseReturnType.entity,
      ),
    );
    await source(
      generator.addUseCase(
        feature: 'home',
        name: 'clear_home',
        returnType: UseCaseReturnType.voidResult,
      ),
    );
    for (final path in [
      useCaseStatePath,
      'lib/features/home/domain/usecases/refresh_home.dart',
      'lib/features/home/presentation/bloc/home_bloc.dart',
    ]) {
      File(project.file(path)).deleteSync();
    }
    await source(ProjectDoctor(project).inspect().plan);
    expect(
      project.read('lib/features/home/presentation/bloc/home_bloc.dart'),
      contains('refreshHomeUseCase'),
    );
    final di = File(project.file('lib/app/di/injection.dart'));
    final missing = AstEditor(di.readAsStringSync())
      ..removeRegistrations({'RefreshHome'});
    di.writeAsStringSync(missing.source);
    await source(ProjectDoctor(project).inspect().plan);
    expect(
      di.readAsStringSync(),
      contains('registerLazySingleton<RefreshHome>'),
    );
    expect(
      di.readAsStringSync(),
      isNot(contains('registerLazySingleton<RefreshHomeRepository>')),
    );
    File(project.file(registryPath)).deleteSync();
    await source(ProjectDoctor(project).inspect().plan);
    final entry = (FeatureRegistry(project).read()['features'] as List).single;
    expect(
      (entry['use_cases'] as List).map((record) => record['name']),
      unorderedEquals(['refresh_home', 'clear_home']),
    );
    expect(
      project.read('lib/app/di/injection.dart'),
      contains('clearHomeUseCase: container<ClearHome>()'),
    );
  });

  test('rename preserves operation names and removal clears their DI registrations', () async {
    await initialize();
    await source(
      generator.generate(name: 'home', state: StateManagement.cubit),
    );
    await source(
      generator.addUseCase(
        feature: 'home',
        name: 'home_refresh',
        returnType: UseCaseReturnType.entity,
      ),
    );
    await source(
      FeatureLifecycle(project).renameMove(
        name: 'home',
        kind: GenerationKind.feature,
        newName: 'dashboard',
        destination: 'lib/modules',
      ),
    );
    expect(
      File(
        project.file('lib/modules/dashboard/domain/usecases/home_refresh.dart'),
      ).existsSync(),
      isTrue,
    );
    expect(
      project.read(
        'lib/modules/dashboard/data/repositories/dashboard_repository_impl.dart',
      ),
      contains('DashboardEntity'),
    );
    expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
    await source(
      generator.remove(name: 'dashboard', kind: GenerationKind.feature),
    );
    expect(
      project.read('lib/app/di/injection.dart'),
      isNot(contains('HomeRefresh')),
    );
  });

  test('DI node ownership does not absorb another feature operation with a shared prefix', () async {
    await initialize();
    await source(
      generator.generate(name: 'home', state: StateManagement.cubit),
    );
    await source(
      generator.generate(name: 'other', state: StateManagement.bloc),
    );
    await source(
      generator.addUseCase(
        feature: 'other',
        name: 'home_extra',
        returnType: UseCaseReturnType.voidResult,
      ),
    );
    await source(
      generator.addUseCase(
        feature: 'home',
        name: 'refresh_home',
        returnType: UseCaseReturnType.entity,
      ),
    );
    final entries = (FeatureRegistry(project).read()['features'] as List);
    final home = entries.firstWhere((entry) => entry['name'] == 'home');
    expect(
      (home['integrations'] as List).any(
        (record) => record['node'] == 'DI.HomeExtra',
      ),
      isFalse,
    );
  });

  test(
    'preserves customized DI arguments, route paths and ownership baselines',
    () async {
      await initialize();
      await source(
        generator.generate(name: 'home', state: StateManagement.cubit),
      );
      final di = File(project.file('lib/app/di/injection.dart'));
      di.writeAsStringSync(
        di.readAsStringSync().replaceFirst(
          'container.registerFactory<HomeCubit>(() => HomeCubit(container<GetHome>()));',
          'container.registerSingleton<HomeCubit>(HomeCubit(GetHome(container<HomeRepository>())));',
        ),
      );
      final router = File(project.file('lib/app/router/app_router.dart'));
      router.writeAsStringSync(
        router.readAsStringSync().replaceFirst(
          "path: '/home'",
          "path: '/sign-in'",
        ),
      );
      final beforeRouter = router.readAsBytesSync();
      await source(
        generator.addUseCase(
          feature: 'home',
          name: 'refresh_home',
          returnType: UseCaseReturnType.entity,
        ),
      );
      final updated = di.readAsStringSync();
      expect(updated, contains('registerSingleton<HomeCubit>'));
      expect(updated, contains('GetHome(container<HomeRepository>())'));
      expect(updated, contains('refreshHomeUseCase: container<RefreshHome>()'));
      expect(
        updated.indexOf('registerLazySingleton<RefreshHome>'),
        lessThan(updated.indexOf('registerSingleton<HomeCubit>')),
      );
      expect(router.readAsBytesSync(), beforeRouter);
      final registry = FeatureRegistry(project).read();
      final entry = (registry['features'] as List).single;
      final ownership = (entry['integrations'] as List).firstWhere(
        (record) => record['node'] == 'DI.HomeCubit',
      );
      expect(
        ownership['sha256'],
        isNot(
          contentDigest(
            utf8.encode(AstEditor(updated).integrationNodes()['DI.HomeCubit']!),
          ),
        ),
      );
      expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
    },
  );

  test('reuses actual current Entity and Model fields and rejects guessed conversions', () async {
    await initialize();
    await source(
      generator.generate(name: 'home', state: StateManagement.cubit),
    );
    final entity = File(
      project.file('lib/features/home/domain/entities/home_entity.dart'),
    );
    final model = File(
      project.file('lib/features/home/data/models/home_model.dart'),
    );
    entity.writeAsStringSync(
      entity.readAsStringSync().replaceFirst(
        'required String id',
        'required String id, required int score',
      ),
    );
    model.writeAsStringSync(
      model.readAsStringSync().replaceFirst(
        'required String id',
        'required String id, required int score',
      ),
    );
    final original = [entity.readAsBytesSync(), model.readAsBytesSync()];
    final plan = generator.addUseCase(
      feature: 'home',
      name: 'refresh_home',
      returnType: UseCaseReturnType.entity,
    );
    expect(
      plan.read(
        'lib/features/home/data/repositories/home_repository_impl.dart',
      ),
      contains('score: model.score'),
    );
    await source(plan);
    expect(entity.readAsBytesSync(), original[0]);
    expect(model.readAsBytesSync(), original[1]);
    File(
      project.file(
        'lib/features/home/data/repositories/home_repository_impl.dart',
      ),
    ).deleteSync();
    expect(
      ProjectDoctor(project).inspect().plan.read(
        'lib/features/home/data/repositories/home_repository_impl.dart',
      ),
      contains('score: model.score'),
    );
    await source(ProjectDoctor(project).inspect().plan);
    model.writeAsStringSync(
      model.readAsStringSync().replaceFirst('int score', 'String score'),
    );
    expect(
      () => generator.addUseCase(
        feature: 'home',
        name: 'another_home',
        returnType: UseCaseReturnType.entity,
      ),
      throwsA(isA<GenerationException>()),
    );
    // Completion operations require no Model/Entity conversion.
    expect(
      generator
          .addUseCase(
            feature: 'home',
            name: 'clear_home',
            returnType: UseCaseReturnType.voidResult,
          )
          .files,
      isNotEmpty,
    );
  });

  test('rejects existing event factories, Freezed variants and unowned shared state without writes', () async {
    await initialize();
    await source(generator.generate(name: 'home', state: StateManagement.bloc));
    for (final name in ['home_success', 'home_requested']) {
      expect(
        () => generator.addUseCase(
          feature: 'home',
          name: name,
          returnType: UseCaseReturnType.entity,
        ),
        throwsA(isA<GenerationException>()),
      );
    }
    final event = File(
      project.file('lib/features/home/presentation/bloc/home_event.dart'),
    );
    final editor = AstEditor(event.readAsStringSync())
      ..addMembers(
        'HomeEvent',
        'const factory HomeEvent.refreshHomeRequested() = CustomRefreshRequested;',
      );
    event.writeAsStringSync(editor.source);
    expect(
      () => generator.addUseCase(
        feature: 'home',
        name: 'refresh_home',
        returnType: UseCaseReturnType.entity,
      ),
      throwsA(isA<GenerationException>()),
    );
    expect(
      File(project.file('lib/features/home/domain/usecases/refresh_home.dart'))
          .existsSync(),
      isFalse,
    );
    final shared = File(project.file(useCaseStatePath));
    shared.parent.createSync(recursive: true);
    shared.writeAsStringSync('// custom owned file\n');
    expect(
      () => generator.addUseCase(
        feature: 'home',
        name: 'clear_home',
        returnType: UseCaseReturnType.voidResult,
      ),
      throwsA(isA<GenerationException>()),
    );
    expect(shared.readAsStringSync(), '// custom owned file\n');
  });

  test('Bloc rename updates extra event types while preserving explicit operation names', () async {
    await initialize();
    await source(generator.generate(name: 'home', state: StateManagement.bloc));
    await source(
      generator.addUseCase(
        feature: 'home',
        name: 'home_refresh',
        returnType: UseCaseReturnType.entity,
      ),
    );
    await source(
      FeatureLifecycle(project).renameMove(
        name: 'home',
        kind: GenerationKind.feature,
        newName: 'dashboard',
        destination: 'lib/modules',
      ),
    );
    final controller = project.read(
      'lib/modules/dashboard/presentation/bloc/dashboard_bloc.dart',
    );
    final event = project.read(
      'lib/modules/dashboard/presentation/bloc/dashboard_event.dart',
    );
    expect(controller, contains('on<DashboardHomeRefreshRequested>'));
    expect(controller, contains('final HomeRefresh? homeRefreshUseCase'));
    expect(event, contains('DashboardEvent.homeRefreshRequested()'));
    expect(event, contains('DashboardHomeRefreshRequested'));
    expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
  });

  test('legacy separate repositories survive new shared actions, Doctor and rename', () async {
    await initialize();
    await source(
      generator.generate(name: 'home', state: StateManagement.cubit),
    );
    final legacy = UseCaseSpec(
      name: 'old_refresh',
      returnType: UseCaseReturnType.entity,
      repositoryBinding: UseCaseRepositoryBinding.operation,
    );
    final files = featureTemplates(
      name: 'home',
      path: 'lib/features/home',
      package: 'fixture_app',
      kind: GenerationKind.feature,
      state: StateManagement.cubit,
      provider: ApiProvider.retrofit,
      useCases: [legacy],
    );
    final plan = GenerationPlan(project);
    for (final file in files.entries) {
      plan.write(file.key, file.value);
    }
    plan.write(useCaseStatePath, useCaseStateTemplate());
    final registry = FeatureRegistry(project).read();
    final entry = (registry['features'] as List).single;
    final metadata = legacy.toJson()..remove('repository_binding');
    entry['use_cases'] = [metadata];
    entry['files'] = [
      for (final file in files.entries)
        artifactRecord(file.key, utf8.encode(file.value), 'home'),
    ];
    (registry['project_files'] as List).add(
      artifactRecord(
        useCaseStatePath,
        utf8.encode(useCaseStateTemplate()),
        '@project',
      ),
    );
    plan.write(registryPath, jsonEncode(registry));
    generator.reconcileIntegrations(plan, []);
    await source(plan);
    final legacyPath =
        'lib/features/home/data/repositories/old_refresh_repository_impl.dart';
    final oldCode = project.read(legacyPath);
    await source(
      generator.addUseCase(
        feature: 'home',
        name: 'clear_home',
        returnType: UseCaseReturnType.voidResult,
      ),
    );
    expect(project.read(legacyPath), oldCode);
    expect(
      project.read('lib/app/di/injection.dart'),
      contains('OldRefreshRepositoryImpl'),
    );
    expect(
      project.read('lib/app/di/injection.dart'),
      contains('ClearHome(container<HomeRepository>())'),
    );
    expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
    File(project.file('lib/features/home/domain/usecases/manual_action.dart'))
        .writeAsStringSync('''
import 'package:multiple_result/multiple_result.dart';
import 'package:fixture_app/core/errors/failure.dart';
import '../entities/home_entity.dart';
class ManualAction { Future<Result<HomeEntity, Failure>> call({required String id}) => throw UnimplementedError(); }
''');
    File(project.file(registryPath)).deleteSync();
    await source(ProjectDoctor(project).inspect().plan);
    final operations = entryUseCases(
      (FeatureRegistry(project).read()['features'] as List).single,
    );
    expect(operations.map((op) => op.name), isNot(contains('manual_action')));
    expect(
      operations.firstWhere((op) => op.name == 'old_refresh').repositoryBinding,
      UseCaseRepositoryBinding.operation,
    );
    expect(
      operations.firstWhere((op) => op.name == 'clear_home').repositoryBinding,
      UseCaseRepositoryBinding.feature,
    );
    await source(
      FeatureLifecycle(project).renameMove(
        name: 'home',
        kind: GenerationKind.feature,
        newName: 'dashboard',
        destination: 'lib/modules',
      ),
    );
    expect(
      project.read(
        'lib/modules/dashboard/data/repositories/old_refresh_repository_impl.dart',
      ),
      contains('DashboardEntity'),
    );
    expect(
      project.read(
        'lib/modules/dashboard/data/repositories/dashboard_repository_impl.dart',
      ),
      contains('clearHome()'),
    );
    await source(
      generator.remove(name: 'dashboard', kind: GenerationKind.feature),
    );
    expect(
      project.read('lib/app/di/injection.dart'),
      isNot(contains('OldRefresh')),
    );
    expect(
      project.read('lib/app/di/injection.dart'),
      isNot(contains('ClearHome')),
    );
  });

  test('shared actions preserve renamed repository dependencies and reject existing methods', () async {
    await initialize();
    await source(
      generator.generate(name: 'home', state: StateManagement.cubit),
    );
    final implementation = File(
      project.file(
        'lib/features/home/data/repositories/home_repository_impl.dart',
      ),
    );
    implementation.writeAsStringSync(
      implementation
          .readAsStringSync()
          .replaceAll('_remote', '_source')
          .replaceAll('reportError', 'errorSink'),
    );
    final plan = generator.addUseCase(
      feature: 'home',
      name: 'refresh_home',
      returnType: UseCaseReturnType.entity,
    );
    expect(
      plan.read(
        'lib/features/home/data/repositories/home_repository_impl.dart',
      ),
      contains('await _source.refreshHome()'),
    );
    expect(
      plan.read(
        'lib/features/home/data/repositories/home_repository_impl.dart',
      ),
      contains('errorSink(error, stackTrace)'),
    );
    await source(plan);
    final contract = File(
      project.file(
        'lib/features/home/domain/repositories/home_repository.dart',
      ),
    );
    final editor = AstEditor(contract.readAsStringSync())
      ..addMembers(
        'HomeRepository',
        'Future<Result<void, Failure>> clearHome();',
      );
    contract.writeAsStringSync(editor.source);
    expect(
      () => generator.addUseCase(
        feature: 'home',
        name: 'clear_home',
        returnType: UseCaseReturnType.voidResult,
      ),
      throwsA(isA<GenerationException>()),
    );
    expect(
      File(project.file('lib/features/home/domain/usecases/clear_home.dart'))
          .existsSync(),
      isFalse,
    );
  });

  test(
    'CLI filters features, offers both return types and cancels without writes',
    () async {
      await initialize();
      await source(
        generator.generate(
          name: 'card',
          kind: GenerationKind.component,
          state: StateManagement.none,
        ),
      );
      final empty = ['3', '0'].iterator;
      final output = StringBuffer();
      expect(
        await runCli(
          [],
          projectRoot: project.root,
          output: output,
          error: StringBuffer(),
          readLine: () => empty.moveNext() ? empty.current : null,
        ),
        0,
      );
      expect(
        output.toString(),
        contains('Create a feature using option 1 first.'),
      );
      await source(
        generator.generate(name: 'home', state: StateManagement.cubit),
      );
      final answers = ['3', '1', 'refresh_home', '2', '2', '0'].iterator;
      final review = StringBuffer();
      expect(
        await runCli(
          [],
          projectRoot: project.root,
          output: review,
          error: StringBuffer(),
          readLine: () => answers.moveNext() ? answers.current : null,
          executor: (_, _, _) async =>
              throw StateError('Cancelled plans must not execute commands.'),
        ),
        0,
      );
      expect(review.toString(), contains('3. Add use case'));
      expect(review.toString(), contains('void (completion only)'));
      expect(
        review.toString(),
        contains('HomeEntity (existing feature entity)'),
      );
      expect(review.toString(), contains('returns Failure'));
      expect(
        File(
          project.file('lib/features/home/domain/usecases/refresh_home.dart'),
        ).existsSync(),
        isFalse,
      );
    },
  );
}
