import 'dart:io';
import 'dart:convert';

import 'package:cleany/cleany.dart';
import 'package:cleany/src/ast_editor.dart';
import 'package:cleany/src/cli.dart';
import 'package:cleany/src/registry.dart';
import 'package:cleany/src/templates/feature_templates.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

// Opt-in because these tests resolve Flutter dependencies and execute builders.
// CI enables them for both API providers, never just the generator's own code.
void main() {
  for (final provider in ApiProvider.values) {
    test(
      'generated ${provider.name} app builds, analyzes and passes runtime tests',
      () async {
        final directory = Directory.systemTemp.createTempSync(
          'cleany_flutter_${provider.name}_',
        );
        try {
          if (provider == ApiProvider.retrofit) {
            (await executeCommand('flutter', [
              'create',
              '--empty',
              '--no-pub',
              '--project-name',
              'generated_app',
              '--platforms',
              'android,ios,macos',
              directory.path,
            ], directory.parent.path)).requireSuccess('create native fixture');
          }
          // Exercise both the older and current language-version lint behavior.
          final languageVersion = provider == ApiProvider.retrofit
              ? '3.13.0'
              : '3.10.0';
          File('${directory.path}/pubspec.yaml').writeAsStringSync('''
name: generated_app
environment:
  sdk: ^$languageVersion
dependencies:
  flutter:
    sdk: flutter
dev_dependencies:
  flutter_test:
    sdk: flutter
flutter:
  uses-material-design: true
''');
          final project = Project(directory.path);
          if (provider == ApiProvider.dio) {
            final dependency = Directory(
              project.file('packages/local_fixture/lib'),
            )..createSync(recursive: true);
            File('${dependency.parent.path}/pubspec.yaml').writeAsStringSync(
              'name: local_fixture\nenvironment:\n  sdk: ^3.10.0\n',
            );
            File('${dependency.path}/local_fixture.dart')
                .writeAsStringSync('const localValue = 7;\n');
            final manifest = File(project.file('pubspec.yaml'));
            manifest.writeAsStringSync(
              manifest.readAsStringSync().replaceFirst(
                'dependencies:\n',
                'dependencies:\n  local_fixture:\n    path: packages/local_fixture\n',
              ),
            );
            final reference = File(project.file('lib/local_reference.dart'));
            reference.parent.createSync(recursive: true);
            reference.writeAsStringSync(
              "import 'package:local_fixture/local_fixture.dart';\nint get reference => localValue;\n",
            );
          }
          final generator = Generator(project);
          final transaction = GenerationTransaction(
            project,
            context: OperationContext(
              onProgress: (event) => print(
                '[${provider.name}] ${event.stage}: ${event.command ?? event.detail ?? ''}',
              ),
            ),
          );
          Future<void> sourceOnly(GenerationPlan plan) => transaction.apply(
            plan,
            install: false,
            build: false,
            analyze: false,
          );
          await sourceOnly(
            generator.initialize(
              provider: provider,
              appId: 'com.example.playground',
            ),
          );
          await sourceOnly(
            generator.generate(name: 'auth', state: StateManagement.cubit),
          );
          await sourceOnly(
            generator.generate(
              name: 'catalog',
              state: StateManagement.bloc,
              path: 'lib/modules/shop',
            ),
          );
          await sourceOnly(
            generator.generate(
              name: 'details',
              state: StateManagement.bloc,
              parent: 'auth',
            ),
          );
          for (final mode in StateManagement.values) {
            await sourceOnly(
              generator.generate(
                name: 'card_${mode.name}',
                kind: GenerationKind.component,
                state: mode,
                parent: 'catalog',
              ),
            );
          }
          // Keep one previous-release layout in the same real Flutter fixture.
          await sourceOnly(
            generator.generate(
              name: 'legacy_badge',
              kind: GenerationKind.component,
              state: StateManagement.cubit,
            ),
          );
          final legacyRegistry = generator.readRegistry();
          final legacyEntry = (legacyRegistry['features'] as List).firstWhere(
            (entry) => entry['name'] == 'legacy_badge',
          );
          final legacyFiles = featureTemplates(
            name: 'legacy_badge',
            path: 'lib/components/legacy_badge',
            package: 'generated_app',
            kind: GenerationKind.component,
            state: StateManagement.cubit,
            provider: provider,
            legacyComponentWidgets: true,
          );
          final legacyPlan = GenerationPlan(project)
            ..delete('lib/components/legacy_badge/legacy_badge_widget.dart');
          for (final file in legacyFiles.entries) {
            legacyPlan.write(file.key, file.value);
          }
          legacyEntry.remove('component_layout');
          legacyEntry['template_version'] = '2.0.0';
          legacyEntry['files'] = [
            for (final file in legacyFiles.entries)
              artifactRecord(file.key, utf8.encode(file.value), 'legacy_badge'),
          ];
          legacyPlan.write(
            'lib/app/composition/feature_pages.dart',
            project
                .read('lib/app/composition/feature_pages.dart')
                .replaceAll(
                  '/legacy_badge/legacy_badge_widget.dart',
                  '/legacy_badge/widgets/legacy_badge_widget.dart',
                ),
          );
          legacyPlan.write(registryPath, prettyJson(legacyRegistry));
          await sourceOnly(legacyPlan);
          await sourceOnly(
            generator.generate(
              name: 'orders',
              state: StateManagement.bloc,
              specification: FeatureSpec(
                fields: [
                  FieldSpec('orderId', 'int', jsonKey: 'order_id'),
                  FieldSpec('title', 'String'),
                  FieldSpec('active', 'bool?'),
                  FieldSpec('createdAt', 'DateTime', jsonKey: 'created_at'),
                  FieldSpec('tags', 'List<String>'),
                ],
                method: 'POST',
                endpoint: '/v1/orders',
                requestEncoding: 'body',
                requestFields: [
                  FieldSpec('reference', 'String', jsonKey: 'client_reference'),
                  FieldSpec('amount', 'int'),
                  FieldSpec('since', 'DateTime?'),
                ],
              ),
            ),
          );
          await sourceOnly(
            generator.generate(
              name: 'search',
              state: StateManagement.cubit,
              specification: FeatureSpec(
                fields: [FieldSpec('home', 'String')],
                endpoint: '/get/home',
                requestFields: [
                  FieldSpec('idUser', 'String?', jsonKey: 'keyUser'),
                ],
              ),
            ),
          );
          // Add operations to shared feature repositories; fakes below implement
          // the expanded contracts as production implementations must do.
          for (final action in [
            ('auth', 'clear_auth', UseCaseReturnType.voidResult),
            ('catalog', 'refresh_catalog', UseCaseReturnType.entity),
            if (provider == ApiProvider.retrofit)
              ('catalog', 'clear_catalog', UseCaseReturnType.voidResult)
            else
              ('auth', 'refresh_auth', UseCaseReturnType.entity),
          ]) {
            await sourceOnly(
              generator.addUseCase(
                feature: action.$1,
                name: action.$2,
                returnType: action.$3,
              ),
            );
          }
          expect(project.read('lib/main.dart'), contains('cleany_dev.main()'));
          expect(
            project.read('.vscode/launch.json'),
            contains('lib/main_prod.dart'),
          );
          expect(project.read('CLEANY_RUN.md'), contains('native flavor'));
          // The interactive transaction validates templates and collects builder outputs.
          final answers = [
            '1',
            'home',
            '1',
            '1',
            '2',
            '3',
            'userName:string:home',
            'y',
            'favourite:list<string>:favourite',
            'y',
            'age:int:age',
            'y',
            '1',
            '3',
            provider == ApiProvider.retrofit ? '1' : '2',
            provider == ApiProvider.retrofit ? 'refresh_auth' : 'clear_catalog',
            provider == ApiProvider.retrofit ? '2' : '1',
            '1',
            '0',
          ].iterator;
          final cliOutput = StringBuffer();
          final cliErrors = StringBuffer();
          final cliCode = await runCli(
            [],
            projectRoot: project.root,
            output: cliOutput,
            error: cliErrors,
            useColor: false,
            readLine: () => answers.moveNext() ? answers.current : null,
          );
          expect(cliCode, 0, reason: cliErrors.toString());
          expect(cliOutput.toString(), isNot(contains('HTTP method')));
          expect(cliOutput.toString(), isNot(contains('API endpoint')));
          expect(cliOutput.toString(), isNot(contains('Request data')));
          expect(cliOutput.toString(), contains('Observe state.'));
          expect(
            cliOutput.toString(),
            contains('until connected, the operation returns Failure.'),
          );
          final projectFiles =
              generator.readRegistry()['project_files'] as List;
          expect(
            projectFiles.any(
              (record) =>
                  record['path'] ==
                      'lib/core/state/use_case_state.freezed.dart' &&
                  record['owner'] == '@project',
            ),
            isTrue,
          );
          File(project.file('test/generated_behavior_test.dart'))
              .writeAsStringSync(_runtimeTests(provider));
          File(project.file('test/contract_test.dart'))
              .writeAsStringSync(_contractTests(provider));
          (await executeCommand('flutter', [
            'pub',
            'get',
          ], project.root)).requireSuccess('fixture pub get');
          (await executeCommand('flutter', [
            'test',
            '--reporter',
            'expanded',
          ], project.root)).requireSuccess('generated behavior tests');
          await transaction.apply(
            FeatureLifecycle(project).renameMove(
              name: 'auth',
              kind: GenerationKind.feature,
              newName: 'account',
              destination: 'lib/modules',
            ),
          );
          (await executeCommand('flutter', [
            'test',
            '--reporter',
            'expanded',
          ], project.root)).requireSuccess('refactored app behavior');
          // Repair a missing binding, while preserving the original file around it.
          final diFile = File(project.file('lib/app/di/injection.dart'));
          final diEditor = AstEditor(diFile.readAsStringSync())
            ..removeRegistrations({'AccountCubit'});
          diFile.writeAsStringSync(diEditor.source);
          await transaction.apply(ProjectDoctor(project).inspect().plan);
          File(project.file('test/contract_test.dart')).deleteSync();
          File(project.file('test/generated_behavior_test.dart')).deleteSync();
          await sourceOnly(
            generator.remove(name: 'account', kind: GenerationKind.feature),
          );
          await sourceOnly(
            generator.remove(
              name: 'card_cubit',
              kind: GenerationKind.component,
            ),
          );
          // Rebuild an already-generated project after both removal kinds.
          // This catches dangling imports and stale Freezed/Retrofit outputs.
          await transaction.apply(
            generator.remove(name: 'home', kind: GenerationKind.feature),
          );
          expect(
            Directory(project.file('lib/features/auth')).existsSync(),
            isFalse,
          );
          expect(
            Directory(project.file('lib/features/home')).existsSync(),
            isFalse,
          );
          expect(
            Directory(
              project.file('lib/modules/shop/catalog/subfeatures/card_cubit'),
            ).existsSync(),
            isFalse,
          );
          if (provider == ApiProvider.retrofit) {
            final main = project.read('lib/main_dev.dart');
            await transaction.apply(
              planPlatformFlavors(project, {'android', 'ios', 'macos'}),
              build: false,
            );
            expect(project.read('lib/main_dev.dart'), main);
            expect(
              File(
                project.file(
                  'ios/Runner.xcodeproj/xcshareddata/xcschemes/dev.xcscheme',
                ),
              ).existsSync(),
              isTrue,
            );
            expect(
              File(project.file('android/app/flavorizr.gradle.kts'))
                  .existsSync(),
              isTrue,
            );
            expect(
              File(
                project.file(
                  'macos/Runner.xcodeproj/xcshareddata/xcschemes/dev.xcscheme',
                ),
              ).existsSync(),
              isTrue,
            );
          }
          if (provider == ApiProvider.dio) {
            expect(
              project.read('pubspec.yaml'),
              contains('path: packages/local_fixture'),
            );
            expect(
              (loadYaml(project.read('pubspec.lock'))
                  as Map)['packages']['local_fixture']['description']['path'],
              'packages/local_fixture',
            );
            expect(
              project.read('.dart_tool/package_config.json'),
              isNot(contains('.cleany/cache/stage_')),
            );
          }
          File(project.file('lib/core/utils/user_note.dart'))
              .writeAsStringSync('const userNote = 42;\n');
          await transaction.apply(ProjectMaintenance(project).reset());
          expect(generator.readRegistry()['features'], isEmpty);
          final backup =
              generator.readRegistry()['last_reset_backup'] as String;
          expect(
            project.read('$backup/lib/core/utils/user_note.dart'),
            contains('userNote = 42'),
          );
        } finally {
          directory.deleteSync(recursive: true);
        }
      },
      timeout: const Timeout(Duration(minutes: 15)),
      skip: Platform.environment['CLEANY_FLUTTER_INTEGRATION'] != 'true',
    );
  }
}

String _runtimeTests(ApiProvider provider) =>
    '''
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:generated_app/app/config/app_config.dart';
import 'package:generated_app/app/config/app_environment.dart';
import 'package:generated_app/app/config/flavor_config.dart';
import 'package:generated_app/app/di/injection.dart';
import 'package:generated_app/app/composition/feature_pages.dart';
import 'package:generated_app/components/legacy_badge/cubit/legacy_badge_cubit.dart';
import 'package:generated_app/components/legacy_badge/widgets/legacy_badge_widget.dart';
import 'package:generated_app/core/state/use_case_state.dart';
import 'package:generated_app/features/auth/domain/usecases/refresh_auth.dart';
import 'package:generated_app/features/auth/domain/usecases/clear_auth.dart';
import 'package:generated_app/modules/shop/catalog/domain/usecases/refresh_catalog.dart';
import 'package:generated_app/modules/shop/catalog/domain/usecases/clear_catalog.dart';
import 'package:generated_app/core/errors/failure.dart';
import 'package:generated_app/core/network/failure_mapper.dart';
import 'package:generated_app/core/network/dio/dio_client.dart';
import 'package:generated_app/core/localization/generated/app_localizations.dart';
import 'package:generated_app/app/app.dart';
import 'package:generated_app/app/router/app_router.dart';
${provider == ApiProvider.retrofit ? "import 'package:generated_app/core/network/retrofit/auth_api.dart';" : ''}
import 'package:generated_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:generated_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:generated_app/features/auth/domain/entities/auth_entity.dart';
import 'package:generated_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:generated_app/features/auth/domain/usecases/get_auth.dart';
import 'package:generated_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:generated_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:generated_app/modules/shop/catalog/domain/entities/catalog_entity.dart';
import 'package:generated_app/modules/shop/catalog/domain/repositories/catalog_repository.dart';
import 'package:generated_app/modules/shop/catalog/domain/usecases/get_catalog.dart';
import 'package:generated_app/modules/shop/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:generated_app/modules/shop/catalog/presentation/bloc/catalog_event.dart';
import 'package:generated_app/modules/shop/catalog/presentation/bloc/catalog_state.dart';
import 'package:generated_app/modules/shop/catalog/subfeatures/card_cubit/cubit/card_cubit_cubit.dart';
import 'package:generated_app/modules/shop/catalog/subfeatures/card_bloc/bloc/card_bloc_bloc.dart';
import 'package:generated_app/modules/shop/catalog/subfeatures/card_bloc/bloc/card_bloc_event.dart';
import 'package:generated_app/modules/shop/catalog/subfeatures/card_none/card_none_widget.dart';

class FakeRemote extends AuthRemoteDataSource {
  FakeRemote() : super(${provider == ApiProvider.retrofit ? 'AuthApi(Dio())' : 'Dio()'});
  Map<String, dynamic> json = {'id': '42'};
  Object? error;
  @override
  Future<Map<String, dynamic>> refreshAuth() async => fetch();
  @override
  Future<void> clearAuth() async {
    final exception = error;
    if (exception != null) throw exception;
  }
  @override
  Future<Map<String, dynamic>> fetch() async {
    final exception = error;
    if (exception != null) throw exception;
    return json;
  }
}

class FakeRefreshAuthRepository extends FakeAuthRepository {
  FakeRefreshAuthRepository() { result = const Success(AuthEntity(id: 'refreshed')); }
  int calls = 0;
  @override
  Future<Result<AuthEntity, Failure>> refreshAuth() async {
    calls++;
    return pending == null ? result : await pending!.future;
  }
}

class FakeClearAuthRepository extends FakeAuthRepository {
  @override
  Future<Result<void, Failure>> clearAuth() async => const Success<void, Failure>(null);
}

class FakeRefreshCatalogRepository extends FakeCatalogRepository {
  Completer<Result<CatalogEntity, Failure>>? pending;
  int calls = 0;
  @override
  Future<Result<CatalogEntity, Failure>> refreshCatalog() async {
    calls++;
    return pending == null ? const Success(CatalogEntity(id: 'updated')) : await pending!.future;
  }
}

class FakeClearCatalogRepository extends FakeCatalogRepository {
  @override
  Future<Result<void, Failure>> clearCatalog() async => const Success<void, Failure>(null);
}

class FakeAuthRepository implements AuthRepository {
  Result<AuthEntity, Failure> result = const Success(AuthEntity(id: '42'));
  Completer<Result<AuthEntity, Failure>>? pending;
  @override
  Future<Result<AuthEntity, Failure>> fetch() async => pending?.future ?? result;
  @override
  Future<Result<AuthEntity, Failure>> refreshAuth() async => const Error(UnexpectedFailure('Not configured.'));
  @override
  Future<Result<void, Failure>> clearAuth() async => const Error(UnexpectedFailure('Not configured.'));
}

class FakeCatalogRepository implements CatalogRepository {
  Result<CatalogEntity, Failure> result = const Success(CatalogEntity(id: '99'));
  @override
  Future<Result<CatalogEntity, Failure>> fetch() async => result;
  @override
  Future<Result<CatalogEntity, Failure>> refreshCatalog() async => const Error(UnexpectedFailure('Not configured.'));
  @override
  Future<Result<void, Failure>> clearCatalog() async => const Error(UnexpectedFailure('Not configured.'));
}

class StubAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) async {
    lastRequest = options;
    return ResponseBody.fromString('{"id":"api"}', 200,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
  }
  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('generated App immediately shows Arabic welcome with RTL', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('ar')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final router = createRouter(GetIt.asNewInstance());
    await tester.pumpWidget(App(router: router));
    await tester.pumpAndSettle();
    final greeting = find.text('مرحبًا');
    expect(greeting, findsOneWidget);
    expect(Directionality.of(tester.element(greeting)), TextDirection.rtl);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });

  testWidgets('official localizations support English and Arabic RTL', (tester) async {
    for (final language in ['en', 'ar']) {
      late BuildContext captured;
      await tester.pumpWidget(MaterialApp(
        locale: Locale(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(builder: (context) {
          captured = context;
          return Text(AppLocalizations.of(context).welcome);
        }),
      ));
      await tester.pumpAndSettle();
      expect(find.text(language == 'ar' ? 'مرحبًا' : 'Welcome'), findsOneWidget);
      expect(Directionality.of(captured), language == 'ar' ? TextDirection.rtl : TextDirection.ltr);
    }
  });

  test('loads flavor YAML and validates HTTPS and missing configuration', () async {
    final flavor = await FlavorConfig.load(AppEnvironment.dev);
    expect(flavor.environment, AppEnvironment.dev);
    expect(AppConfig.fromEnvironment(AppEnvironment.prod,
      fallbackBaseUrl: 'https://example.com').apiBaseUrl, 'https://example.com');
    expect(() => AppConfig.fromEnvironment(AppEnvironment.prod,
      fallbackBaseUrl: 'http://example.com'), throwsStateError);
    expect(() => AppConfig.fromEnvironment(AppEnvironment.dev), throwsStateError);
  });

  test('real API adapter preserves raw JSON and limits token injection to trusted origin', () async {
    final adapter = StubAdapter();
    final dio = createDio('https://example.com', tokenProvider: () async => 'session-token');
    dio.httpClientAdapter = adapter;
    final source = AuthRemoteDataSource(${provider == ApiProvider.retrofit ? 'AuthApi(dio)' : 'dio'});
    expect(await source.fetch(), {'id': 'api'});
    expect(adapter.lastRequest?.headers['Authorization'], 'Bearer session-token');
    await dio.get<dynamic>('https://other.example/data');
    expect(adapter.lastRequest?.headers['Authorization'], isNull);
    dio.close();
  });

  test('repository maps JSON to Entity and maps exceptions exactly once', () async {
    final remote = FakeRemote();
    final repository = AuthRepositoryImpl(remote);
    (await repository.fetch()).when((value) => expect(value.id, '42'),
      (_) => fail('expected entity'));
    const business = BusinessFailure('Account is locked.');
    remote.error = business;
    (await repository.fetch()).when((_) => fail('expected failure'),
      (failure) => expect(identical(failure, business), isTrue));
    remote.error = null;
    remote.json = {'id': 42};
    (await repository.fetch()).when((_) => fail('expected failure'),
      (failure) => expect(failure, isA<ValidationFailure>()));
    final request = RequestOptions(path: '/auth');
    expect(mapFailure(DioException(requestOptions: request,
      type: DioExceptionType.connectionError)), isA<NetworkFailure>());
    expect(mapFailure(DioException(requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: request, statusCode: 401))),
      isA<UnauthorizedFailure>());
  });

  test('Cubit emits loading and entity success or failure', () async {
    final repository = FakeAuthRepository();
    final cubit = AuthCubit(GetAuth(repository));
    final states = <AuthState>[];
    final subscription = cubit.stream.listen(states.add);
    await cubit.load();
    await Future<void>.delayed(Duration.zero);
    expect(states, [const AuthState.loading(), const AuthState.success(AuthEntity(id: '42'))]);
    repository.result = const Error(UnauthorizedFailure());
    await cubit.load();
    await Future<void>.delayed(Duration.zero);
    expect(states.last, isA<AuthFailure>());
    await subscription.cancel();
    await cubit.close();
  });

  test('Cubit does not emit after disposal or duplicate in-flight requests', () async {
    final repository = FakeAuthRepository();
    final pending = Completer<Result<AuthEntity, Failure>>();
    repository.pending = pending;
    final cubit = AuthCubit(GetAuth(repository));
    final load = cubit.load();
    await cubit.load();
    await cubit.close();
    pending.complete(const Success(AuthEntity(id: '42')));
    await load;
    await cubit.load();
  });

  test('Bloc emits loading and entity success or failure', () async {
    final repository = FakeCatalogRepository();
    final bloc = CatalogBloc(GetCatalog(repository));
    final success = bloc.stream.firstWhere((s) => s is CatalogSuccess);
    bloc.add(const CatalogEvent.requested());
    expect(await success, const CatalogState.success(CatalogEntity(id: '99')));
    repository.result = const Error(NetworkFailure());
    final failure = bloc.stream.firstWhere((s) => s is CatalogFailure);
    bloc.add(const CatalogEvent.requested());
    expect(await failure, isA<CatalogFailure>());
    await bloc.close();
  });

  test('DI has one app scope, singleton repositories and owned controllers', () async {
    final container = GetIt.asNewInstance();
    await configureDependencies(container, const AppConfig(
      environment: AppEnvironment.dev, apiBaseUrl: 'https://example.com'));
    expect(identical(container<AuthRepository>(), container<AuthRepository>()), isTrue);
    final first = container<AuthCubit>();
    final second = container<AuthCubit>();
    expect(identical(first, second), isFalse);
    await first.close();
    await second.close();
    await disposeDependencies(container);
    expect(container.isRegistered<Dio>(), isFalse);
  });

  test('additional repositories reuse Model/Entity and preserve Result when reporting fails', () async {
    final remote = FakeRemote();
    var reports = 0;
    final repository = AuthRepositoryImpl(remote, reportError: (_, _) {
      reports++;
      throw StateError('reporter unavailable');
    });
    expect((await repository.refreshAuth()).tryGetSuccess(), const AuthEntity(id: '42'));
    const business = BusinessFailure('Operation rejected.');
    remote.error = business;
    expect(identical((await repository.refreshAuth()).tryGetError(), business), isTrue);
    expect(reports, 0);
    remote.error = StateError('technical failure');
    expect((await repository.refreshAuth()).tryGetError(), isA<UnexpectedFailure>());
    expect(reports, 1);
    remote.error = null;
    remote.json = {'id': 42};
    expect((await repository.refreshAuth()).tryGetError(), isA<ValidationFailure>());
    // Completion actions do not try to parse an Entity from an ignored body.
    expect((await AuthRepositoryImpl(remote).clearAuth()).isSuccess(), isTrue);
  });

  test('Cubit actions have typed independent progress, preserve main loads and close safely', () async {
    final refresh = FakeRefreshAuthRepository()
      ..pending = Completer<Result<AuthEntity, Failure>>();
    final cubit = AuthCubit(GetAuth(FakeAuthRepository()),
      refreshAuthUseCase: RefreshAuth(refresh), clearAuthUseCase: ClearAuth(FakeClearAuthRepository()));
    final running = cubit.refreshAuth();
    expect(cubit.state.refreshAuthStatus, isA<UseCaseLoading<AuthEntity>>());
    await cubit.refreshAuth();
    expect(refresh.calls, 1);
    await cubit.clearAuth();
    expect(cubit.state.clearAuthStatus, const UseCaseState<void>.success(null));
    await cubit.load();
    expect(cubit.state, isA<AuthSuccess>());
    expect(cubit.state.refreshAuthStatus, isA<UseCaseLoading<AuthEntity>>());
    expect(cubit.state.clearAuthStatus, isA<UseCaseSuccess<void>>());
    refresh.pending!.complete(const Success(AuthEntity(id: 'refreshed')));
    await running;
    expect((cubit.state.refreshAuthStatus as UseCaseSuccess<AuthEntity>).value.id, 'refreshed');
    expect(cubit.state.clearAuthStatus, isA<UseCaseSuccess<void>>());
    refresh.pending = null;
    refresh.result = const Error(NetworkFailure());
    await cubit.refreshAuth();
    expect((cubit.state.refreshAuthStatus as UseCaseFailure<AuthEntity>).failure, isA<NetworkFailure>());
    refresh.pending = Completer<Result<AuthEntity, Failure>>();
    final pendingAction = cubit.refreshAuth();
    await cubit.close();
    refresh.pending!.complete(const Success(AuthEntity(id: 'late')));
    await pendingAction;
    await cubit.refreshAuth();
  });

  test('Bloc action events preserve concurrent actions through primary state changes', () async {
    final repository = FakeRefreshCatalogRepository()
      ..pending = Completer<Result<CatalogEntity, Failure>>();
    final bloc = CatalogBloc(GetCatalog(FakeCatalogRepository()),
      refreshCatalogUseCase: RefreshCatalog(repository), clearCatalogUseCase: ClearCatalog(FakeClearCatalogRepository()));
    final loading = bloc.stream.firstWhere((s) => s.refreshCatalogStatus is UseCaseLoading<CatalogEntity>);
    bloc.add(const CatalogEvent.refreshCatalogRequested());
    bloc.add(const CatalogEvent.refreshCatalogRequested());
    await loading;
    final cleared = bloc.stream.firstWhere((s) => s.clearCatalogStatus is UseCaseSuccess<void>);
    bloc.add(const CatalogEvent.clearCatalogRequested());
    await cleared;
    final main = bloc.stream.firstWhere((s) => s is CatalogSuccess);
    bloc.add(const CatalogEvent.requested());
    await main;
    expect(bloc.state.refreshCatalogStatus, isA<UseCaseLoading<CatalogEntity>>());
    expect(bloc.state.clearCatalogStatus, isA<UseCaseSuccess<void>>());
    expect(repository.calls, 1);
    final completed = bloc.stream.firstWhere((s) => s.refreshCatalogStatus is UseCaseSuccess<CatalogEntity>);
    repository.pending!.complete(const Success(CatalogEntity(id: 'updated')));
    await completed;
    expect((bloc.state.refreshCatalogStatus as UseCaseSuccess<CatalogEntity>).value.id, 'updated');
    expect(bloc.state.clearCatalogStatus, isA<UseCaseSuccess<void>>());
    await bloc.close();
  });

  test('central DI wires new actions; unconnected backends return Failure without guessing HTTP', () async {
    final container = GetIt.asNewInstance();
    await configureDependencies(container, const AppConfig(environment: AppEnvironment.dev, apiBaseUrl: 'https://example.com'));
    final cubit = container<AuthCubit>();
    expect(cubit.refreshAuthUseCase, isNotNull);
    expect(cubit.clearAuthUseCase, isNotNull);
    await cubit.refreshAuth();
    expect((cubit.state.refreshAuthStatus as UseCaseFailure<AuthEntity>).failure, isA<UnexpectedFailure>());
    final bloc = container<CatalogBloc>();
    final failed = bloc.stream.firstWhere((s) => s.clearCatalogStatus is UseCaseFailure<void>);
    bloc.add(const CatalogEvent.clearCatalogRequested());
    await failed;
    await cubit.close(); await bloc.close();
    await disposeDependencies(container);
  });

  test('manual controllers remain compatible and report unavailable uninjected actions', () async {
    final cubit = AuthCubit(GetAuth(FakeAuthRepository()));
    await cubit.refreshAuth();
    expect(cubit.state.refreshAuthStatus, isA<UseCaseFailure<AuthEntity>>());
    await cubit.load();
    expect(cubit.state, isA<AuthSuccess>());
    await cubit.close();
  });

  test('component actions after disposal are ignored consistently', () async {
    final cubit = CardCubitCubit();
    cubit.update(2);
    await cubit.close();
    cubit.update(3);
    final bloc = CardBlocBloc();
    await bloc.close();
    bloc.add(const CardBlocEvent.requested());
  });

  testWidgets('legacy component widget paths retain provider wiring and disposal', (tester) async {
    final container = GetIt.asNewInstance();
    await configureDependencies(container, const AppConfig(environment: AppEnvironment.dev, apiBaseUrl: 'https://example.com'));
    await tester.pumpWidget(MaterialApp(home: FeaturePages.legacyBadge(container)));
    final cubit = tester.element(find.byType(LegacyBadgeWidget)).read<LegacyBadgeCubit>();
    cubit.update(7);
    await tester.pump();
    expect(find.text('7'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(cubit.isClosed, isTrue);
    await disposeDependencies(container);
  });

  testWidgets('component without state builds without DI', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CardNoneWidget()));
    expect(find.byType(CardNoneWidget), findsOneWidget);
  });
}
''';

String _contractTests(ApiProvider provider) =>
    '''
import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
${provider == ApiProvider.retrofit ? "import 'package:generated_app/core/network/retrofit/orders_api.dart';" : ''}
${provider == ApiProvider.retrofit ? "import 'package:generated_app/core/network/retrofit/search_api.dart';" : ''}
${provider == ApiProvider.retrofit ? "import 'package:generated_app/core/network/retrofit/home_api.dart';" : ''}
import 'package:generated_app/features/search/data/datasources/search_remote_data_source.dart';
import 'package:generated_app/features/search/data/repositories/search_repository_impl.dart';
import 'package:generated_app/features/search/domain/entities/search_request.dart';
import 'package:generated_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:generated_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:generated_app/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:generated_app/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:generated_app/features/orders/domain/entities/orders_request.dart';

class ContractAdapter implements HttpClientAdapter {
  RequestOptions? request;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) async {
    request = options;
    if (options.path == '/get/home') {
      return ResponseBody.fromString('{"home":"Welcome"}', 200,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
    }
    if (options.path == '/home') {
      return ResponseBody.fromString('{"home":"Welcome","favourite":["one"],"age":42}', 200,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
    }
    return ResponseBody.fromString('{"order_id":17,"title":"Ready","active":null,"created_at":"2026-10-31T00:00:00.000Z","tags":["a"]}',
      200, headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
  }
  @override
  void close({bool force = false}) {}
}
void main() {
  test('compact CLI response fields map JSON to a typed entity', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    addTearDown(dio.close);
    final adapter = ContractAdapter();
    dio.httpClientAdapter = adapter;
    final source = HomeRemoteDataSource(${provider == ApiProvider.retrofit ? 'HomeApi(dio)' : 'dio'});
    final result = await HomeRepositoryImpl(source).fetch();
    result.when((entity) {
      expect(entity.userName, 'Welcome');
      expect(entity.favourite, ['one']);
      expect(entity.age, 42);
    }, (_) => fail('Expected typed home entity'));
  });
  test('custom GET contract preserves JSON query keys and omits nullable values', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    addTearDown(dio.close);
    final adapter = ContractAdapter();
    dio.httpClientAdapter = adapter;
    final source = SearchRemoteDataSource(${provider == ApiProvider.retrofit ? 'SearchApi(dio)' : 'dio'});
    final repository = SearchRepositoryImpl(source);
    final result = await repository.fetch(request: const SearchRequest(idUser: 'user-42'));
    result.when((entity) => expect(entity.home, 'Welcome'), (_) => fail('Expected home entity'));
    expect(adapter.request?.method, 'GET');
    expect(adapter.request?.path, '/get/home');
    expect(adapter.request?.queryParameters, {'keyUser': 'user-42'});
    final nullable = await repository.fetch(request: const SearchRequest());
    nullable.when((entity) => expect(entity.home, 'Welcome'), (_) => fail('Expected home entity'));
    expect(adapter.request?.queryParameters, isEmpty);
  });
  test('custom POST contract maps typed request and response without leaking transport to Domain', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    final adapter = ContractAdapter();
    dio.httpClientAdapter = adapter;
    final source = OrdersRemoteDataSource(${provider == ApiProvider.retrofit ? 'OrdersApi(dio)' : 'dio'});
    final repository = OrdersRepositoryImpl(source);
    final result = await repository.fetch(request: OrdersRequest(reference: 'client', amount: 2,
      since: DateTime.utc(2026, 10, 31)));
    result.when((entity) {
      expect(entity.orderId, 17);
      expect(entity.title, 'Ready');
      expect(entity.active, isNull);
      expect(entity.createdAt, DateTime.utc(2026, 10, 31));
      expect(entity.tags, ['a']);
    }, (_) => fail('Expected typed entity'));
    expect(adapter.request?.method, 'POST');
    expect(adapter.request?.path, '/v1/orders');
    expect(adapter.request?.data, {'client_reference': 'client', 'amount': 2,
      'since': '2026-10-31T00:00:00.000Z'});
    dio.close();
  });
}
''';
