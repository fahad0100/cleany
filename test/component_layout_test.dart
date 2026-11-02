import 'dart:convert';
import 'dart:io';

import 'package:cleany/cleany.dart';
import 'package:cleany/src/ast_editor.dart';
import 'package:cleany/src/registry.dart';
import 'package:cleany/src/templates/feature_templates.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late Project project;
  late Generator generator;
  Future<void> source(GenerationPlan plan) =>
      GenerationTransaction(project)
          .apply(plan, install: false, build: false, analyze: false);
  setUp(() async {
    directory = Directory.systemTemp.createTempSync('cleany_component_layout_');
    project = Project(directory.path);
    File(project.file('pubspec.yaml')).writeAsStringSync(
      'name: fixture_app\nenvironment:\n  sdk: ^3.13.0\ndependencies:\n  flutter:\n    sdk: flutter\n',
    );
    generator = Generator(project);
    await source(generator.initialize(appId: 'com.example.fixture'));
  });
  tearDown(() => directory.deleteSync(recursive: true));

  for (final mode in StateManagement.values) {
    test(
      'flat ${mode.name} component survives repair, discovery, rename/move and removal',
      () async {
        final routes = project.read('lib/app/router/app_router.dart');
        final plan = generator.generate(
          name: 'user_card',
          state: mode,
          kind: GenerationKind.component,
        );
        const widget = 'lib/components/user_card/user_card_widget.dart';
        expect(plan.files.containsKey(widget), isTrue);
        expect(
          plan.files.keys.any((path) => path.contains('/widgets/')),
          isFalse,
        );
        expect(
          plan.files.keys.any(
            (path) => path.contains('/domain/') || path.contains('/data/'),
          ),
          isFalse,
        );
        expect(plan.files.containsKey('lib/app/di/injection.dart'), isFalse);
        expect(
          plan.files.containsKey('lib/app/composition/feature_pages.dart'),
          isFalse,
        );
        expect(
          plan.files.containsKey('lib/app/router/route_names.dart'),
          isFalse,
        );
        final originalDi = project.read('lib/app/di/injection.dart');
        final originalPages = project.read(
          'lib/app/composition/feature_pages.dart',
        );
        if (mode != StateManagement.none) {
          expect(
            plan.read(widget),
            contains("import '${mode.name}/user_card_${mode.name}.dart'"),
          );
          expect(plan.read(widget), isNot(contains("import '../")));
          final controller = mode == StateManagement.bloc
              ? 'UserCardBloc'
              : 'UserCardCubit';
          expect(
            plan.read(widget),
            contains('create: (context) => $controller()'),
          );
          expect(plan.read(widget), contains('child: Builder('));
          expect(
            plan.read(widget),
            contains('final _ = context.read<$controller>();'),
          );
        }
        await source(plan);
        expect(project.read('lib/app/router/app_router.dart'), routes);
        expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
        File(project.file(widget)).deleteSync();
        final repair = ProjectDoctor(project).inspect().plan;
        expect(repair.files.keys, contains(widget));
        expect(
          repair.files.keys.any((path) => path.contains('/widgets/')),
          isFalse,
        );
        await source(repair);
        File(project.file(registryPath)).deleteSync();
        await source(ProjectDoctor(project).inspect().plan);
        final entry = (generator.readRegistry()['features'] as List).single;
        expect(entry['component_layout'], 'flat');
        expect(entry['state'], mode.name);
        expect(entry['component_scope'], 'local');
        expect(entry['integrations'], isEmpty);
        await source(
          FeatureLifecycle(project).renameMove(
            name: 'user_card',
            kind: GenerationKind.component,
            newName: 'profile_card',
            destination: 'lib/shared/components',
          ),
        );
        expect(
          File(
            project.file(
              'lib/shared/components/profile_card/profile_card_widget.dart',
            ),
          ).existsSync(),
          isTrue,
        );
        expect(
          project.read('lib/app/composition/feature_pages.dart'),
          originalPages,
        );
        expect(project.read('lib/app/di/injection.dart'), originalDi);
        expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
        await source(
          generator.remove(
            name: 'profile_card',
            kind: GenerationKind.component,
          ),
        );
        expect(project.read('lib/app/di/injection.dart'), originalDi);
        expect(
          project.read('lib/app/composition/feature_pages.dart'),
          originalPages,
        );
        expect(
          project.read('lib/app/composition/feature_pages.dart'),
          isNot(contains('ProfileCardWidget')),
        );
      },
    );

    test(
      'legacy ${mode.name} component retains its widgets directory during Doctor repair and discovery',
      () async {
        await source(
          generator.generate(
            name: 'card',
            state: mode,
            kind: GenerationKind.component,
          ),
        );
        final registry = generator.readRegistry();
        final entry = (registry['features'] as List).single;
        final legacy = featureTemplates(
          name: 'card',
          path: 'lib/components/card',
          package: 'fixture_app',
          kind: GenerationKind.component,
          state: mode,
          provider: ApiProvider.retrofit,
          legacyComponentWidgets: true,
          localComponentScope: false,
          singleState: false,
        );
        final conversion = GenerationPlan(project)
          ..delete('lib/components/card/card_widget.dart');
        for (final file in legacy.entries) {
          conversion.write(file.key, file.value);
        }
        entry.remove('component_layout');
        entry.remove('component_scope');
        entry['template_version'] = '2.0.0';
        if (mode != StateManagement.none) entry['state_style'] = 'union';
        entry['files'] = [
          for (final file in legacy.entries)
            artifactRecord(file.key, utf8.encode(file.value), 'card'),
        ];
        conversion.write(
          'lib/app/composition/feature_pages.dart',
          project
              .read('lib/app/composition/feature_pages.dart')
              .replaceAll(
                '/card/card_widget.dart',
                '/card/widgets/card_widget.dart',
              ),
        );
        conversion.write(registryPath, jsonEncode(registry));
        generator.reconcileIntegrations(conversion, []);
        await source(conversion);
        expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
        const path = 'lib/components/card/widgets/card_widget.dart';
        File(project.file(path)).deleteSync();
        await source(ProjectDoctor(project).inspect().plan);
        expect(File(project.file(path)).existsSync(), isTrue);
        expect(
          File(project.file('lib/components/card/card_widget.dart'))
              .existsSync(),
          isFalse,
        );
        File(project.file(registryPath)).deleteSync();
        await source(ProjectDoctor(project).inspect().plan);
        expect(
          (generator.readRegistry()['features'] as List)
              .single['component_layout'],
          'widgets',
        );
        expect(
          project.read('lib/app/composition/feature_pages.dart'),
          isNot(contains('/card/widgets/card_widget.dart')),
        );
        expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
      },
    );
  }

  test(
    'flat components named widgets are recovered even inside a widgets parent',
    () async {
      await source(
        generator.generate(
          name: 'widgets',
          kind: GenerationKind.component,
          state: StateManagement.none,
          path: 'lib/shared/widgets',
        ),
      );
      File(project.file(registryPath)).deleteSync();
      await source(ProjectDoctor(project).inspect().plan);
      final entry = (generator.readRegistry()['features'] as List).single;
      expect(entry['path'], 'lib/shared/widgets/widgets');
      expect(entry['component_layout'], 'flat');
      expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
    },
  );

  test(
    'components inside a feature are discovered as nested flat components',
    () async {
      await source(
        generator.generate(name: 'home', state: StateManagement.cubit),
      );
      await source(
        generator.generate(
          name: 'card',
          state: StateManagement.none,
          kind: GenerationKind.component,
          parent: 'home',
        ),
      );
      File(project.file(registryPath)).deleteSync();
      await source(ProjectDoctor(project).inspect().plan);
      final component = (generator.readRegistry()['features'] as List)
          .firstWhere((entry) => entry['name'] == 'card');
      expect(component['path'], 'lib/features/home/subfeatures/card');
      expect(component['parent'], 'home');
      expect(component['component_layout'], 'flat');
      expect(component['component_scope'], 'local');
    },
  );

  test('previous flat components keep external providers during repair and recovery', () async {
    await source(
      generator.generate(
        name: 'badge',
        kind: GenerationKind.component,
        state: StateManagement.bloc,
      ),
    );
    final registry = generator.readRegistry();
    final entry = (registry['features'] as List).single;
    entry.remove('component_scope');
    entry['state_style'] = 'union';
    final previousFiles = featureTemplates(
      name: 'badge',
      path: 'lib/components/badge',
      package: 'fixture_app',
      kind: GenerationKind.component,
      state: StateManagement.bloc,
      provider: ApiProvider.retrofit,
      localComponentScope: false,
      singleState: false,
    );
    final conversion = GenerationPlan(project);
    for (final file in previousFiles.entries) {
      conversion.write(file.key, file.value);
    }
    entry['files'] = [
      for (final file in previousFiles.entries)
        artifactRecord(file.key, utf8.encode(file.value), 'badge'),
    ];
    conversion.write(registryPath, jsonEncode(registry));
    // Previous releases registered the controller externally. Keep an existing
    // registration, but never synthesize a component page during repair.
    final di = AstEditor(project.read('lib/app/di/injection.dart'))
      ..addImports([
        'package:fixture_app/components/badge/bloc/badge_bloc.dart',
      ])
      ..addStatements(
        'registerFeatureDependencies',
        'container.registerFactory<BadgeBloc>(() => BadgeBloc());',
      );
    conversion.write('lib/app/di/injection.dart', di.source);
    generator.reconcileIntegrations(conversion, []);
    await source(conversion);
    const widget = 'lib/components/badge/badge_widget.dart';
    File(project.file(widget)).deleteSync();
    await source(ProjectDoctor(project).inspect().plan);
    expect(project.read(widget), isNot(contains('return BlocProvider(')));
    expect(
      project.read('lib/app/di/injection.dart'),
      contains('registerFactory<BadgeBloc>'),
    );
    File(project.file(registryPath)).deleteSync();
    await source(ProjectDoctor(project).inspect().plan);
    expect(
      (generator.readRegistry()['features'] as List).single['component_scope'],
      'external',
    );
    expect(
      project.read('lib/app/composition/feature_pages.dart'),
      isNot(contains('static Widget badge(')),
    );
    expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
  });

  test('Doctor removes a missing local component without requiring central ownership', () async {
    await source(
      generator.generate(
        name: 'card',
        kind: GenerationKind.component,
        state: StateManagement.cubit,
      ),
    );
    final originalDi = project.read('lib/app/di/injection.dart');
    final originalPages = project.read(
      'lib/app/composition/feature_pages.dart',
    );
    Directory(project.file('lib/components/card')).deleteSync(recursive: true);
    await source(ProjectDoctor(project).inspect().plan);
    expect(generator.readRegistry()['features'], isEmpty);
    expect(project.read('lib/app/di/injection.dart'), originalDi);
    expect(
      project.read('lib/app/composition/feature_pages.dart'),
      originalPages,
    );
  });
}
