import 'dart:io';
import 'dart:convert';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:cleany/cleany.dart';
import 'package:cleany/src/registry.dart';
import 'package:cleany/src/templates/feature_templates.dart';
import 'package:cleany/src/templates/use_case_templates.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late Project project;
  late Generator generator;
  Future<void> apply(GenerationPlan plan) async {
    await GenerationTransaction(project)
        .apply(plan, install: false, build: false, analyze: false);
  }

  setUp(() async {
    directory = Directory.systemTemp.createTempSync('cleany_single_state_');
    project = Project(directory.path);
    File(project.file('pubspec.yaml')).writeAsStringSync(
      'name: state_fixture\nenvironment:\n  sdk: ^3.13.0\ndependencies:\n  flutter:\n    sdk: flutter\n',
    );
    generator = Generator(project);
    await apply(generator.initialize(appId: 'com.example.state'));
  });
  tearDown(() => directory.deleteSync(recursive: true));

  int factories(String source) =>
      (parseString(content: source).unit.declarations
                  .whereType<ClassDeclaration>()
                  .single
                  .body
              as BlockClassBody)
          .members
          .whereType<ConstructorDeclaration>()
          .where((node) => node.factoryKeyword != null)
          .length;

  for (final kind in GenerationKind.values) {
    for (final mode in [StateManagement.cubit, StateManagement.bloc]) {
      test(
        '${kind.name}/${mode.name} creates and repairs one composed State',
        () async {
          final plan = generator.generate(
            name: 'sample',
            kind: kind,
            state: mode,
          );
          final root = kind == GenerationKind.feature
              ? 'lib/features/sample/presentation'
              : 'lib/components/sample';
          final state = '$root/${mode.name}/sample_state.dart';
          final controller = '$root/${mode.name}/sample_${mode.name}.dart';
          final ui = kind == GenerationKind.feature
              ? '$root/pages/sample_page.dart'
              : '$root/sample_widget.dart';
          final type = kind == GenerationKind.feature ? 'SampleEntity' : 'int';
          expect(factories(plan.read(state)), 1);
          expect(plan.read(state), contains('const factory SampleState({'));
          expect(
            plan.read(state),
            contains('UseCaseState<$type> sampleStatus'),
          );
          for (final field in ['initialState', 'successState', 'errorState']) {
            expect(plan.read(state), isNot(contains('$field,')));
          }
          expect(plan.read(controller), contains('super(const SampleState())'));
          expect(plan.read(controller), contains('state.copyWith('));
          expect(plan.read(ui), contains('state.sampleStatus.when('));
          expect(plan.read(ui), isNot(contains('switch (')));
          await apply(plan);
          expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
          for (final path in [state, controller, ui, useCaseStatePath]) {
            File(project.file(path)).deleteSync();
          }
          final repair = ProjectDoctor(project).inspect().plan;
          expect(factories(repair.read(state)), 1);
          expect(
            repair.read(controller),
            contains('super(const SampleState())'),
          );
          expect(repair.files, contains(useCaseStatePath));
          await apply(repair);
          expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
          File(project.file(registryPath)).deleteSync();
          await apply(ProjectDoctor(project).inspect().plan);
          final entry = (generator.readRegistry()['features'] as List).single;
          expect(entry['state_style'], 'status');
          expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
        },
      );
    }
  }

  for (final mode in [StateManagement.cubit, StateManagement.bloc]) {
    test(
      'legacy ${mode.name} unions keep their contract on repair and adding actions',
      () async {
        await apply(generator.generate(name: 'home', state: mode));
        final legacy = featureTemplates(
          name: 'home',
          path: 'lib/features/home',
          package: 'state_fixture',
          kind: GenerationKind.feature,
          state: mode,
          provider: ApiProvider.retrofit,
          singleState: false,
        );
        final conversion = GenerationPlan(project);
        for (final file in legacy.entries) {
          conversion.write(file.key, file.value);
        }
        final registry = generator.readRegistry();
        final entry = (registry['features'] as List).single;
        entry.remove('state_style');
        entry['files'] = [
          for (final file in legacy.entries)
            artifactRecord(file.key, utf8.encode(file.value), 'home'),
        ];
        conversion.write(registryPath, prettyJson(registry));
        await apply(conversion);
        await apply(ProjectDoctor(project).inspect().plan);
        final state =
            'lib/features/home/presentation/${mode.name}/home_state.dart';
        expect(
          (generator.readRegistry()['features'] as List).single['state_style'],
          'union',
        );
        File(project.file(state)).deleteSync();
        await apply(ProjectDoctor(project).inspect().plan);
        expect(factories(project.read(state)), 4);
        await apply(
          generator.addUseCase(
            feature: 'home',
            name: 'refresh_home',
            returnType: UseCaseReturnType.entity,
          ),
        );
        expect(factories(project.read(state)), 4);
        expect('refreshHomeStatus'.allMatches(project.read(state)).length, 4);
        expect(
          project.read(
            'lib/features/home/presentation/${mode.name}/home_${mode.name}.dart',
          ),
          contains('refreshHomeStatus: state.refreshHomeStatus'),
        );
        expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
      },
    );
  }

  test('new single states recreate missing shared state for an older initialized project', () async {
    File(project.file(useCaseStatePath)).deleteSync();
    final plan = generator.generate(
      name: 'card',
      kind: GenerationKind.component,
      state: StateManagement.cubit,
    );
    expect(plan.files, contains(useCaseStatePath));
    await apply(plan);
    final owned = generator.readRegistry()['project_files'] as List;
    expect(
      owned.where((record) => record['path'] == useCaseStatePath).length,
      1,
    );
    expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
  });

  for (final mode in [StateManagement.cubit, StateManagement.bloc]) {
    test('older three-field ${mode.name} states repair without mixing contracts', () async {
      await apply(generator.generate(name: 'home', state: mode));
      final previous = featureTemplates(
        name: 'home',
        path: 'lib/features/home',
        package: 'state_fixture',
        kind: GenerationKind.feature,
        state: mode,
        provider: ApiProvider.retrofit,
        splitPrimaryState: true,
      );
      final plan = GenerationPlan(project);
      for (final file in previous.entries) {
        plan.write(file.key, file.value);
      }
      final registry = generator.readRegistry();
      final entry = (registry['features'] as List).single;
      entry['state_style'] = 'single';
      entry.remove('primary_status');
      entry['files'] = [
        for (final file in previous.entries)
          artifactRecord(file.key, utf8.encode(file.value), 'home'),
      ];
      plan.write(registryPath, prettyJson(registry));
      await apply(plan);
      final state =
          'lib/features/home/presentation/${mode.name}/home_state.dart';
      final controller =
          'lib/features/home/presentation/${mode.name}/home_${mode.name}.dart';
      File(project.file(state)).deleteSync();
      File(project.file(controller)).deleteSync();
      await apply(ProjectDoctor(project).inspect().plan);
      expect(project.read(state), contains('initialState'));
      expect(project.read(controller), contains('state.initialState'));
      expect(project.read(state), isNot(contains('homeStatus')));
      await apply(
        generator.addUseCase(
          feature: 'home',
          name: 'refresh_home',
          returnType: UseCaseReturnType.entity,
        ),
      );
      expect(project.read(state), contains('refreshHomeStatus'));
      expect(project.read(state), contains('initialState'));
      expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
    });
  }

  test(
    'primary status stays stable through rename, registry recovery and repair',
    () async {
      await apply(
        generator.generate(name: 'home', state: StateManagement.bloc),
      );
      await apply(
        generator.addUseCase(
          feature: 'home',
          name: 'refresh_home',
          returnType: UseCaseReturnType.entity,
        ),
      );
      await apply(
        FeatureLifecycle(project).renameMove(
          name: 'home',
          newName: 'dashboard',
          kind: GenerationKind.feature,
        ),
      );
      File(project.file(registryPath)).deleteSync();
      await apply(ProjectDoctor(project).inspect().plan);
      final entry = (generator.readRegistry()['features'] as List).single;
      expect(entry['state_style'], 'status');
      expect(entry['primary_status'], 'homeStatus');
      const state =
          'lib/features/dashboard/presentation/bloc/dashboard_state.dart';
      const controller =
          'lib/features/dashboard/presentation/bloc/dashboard_bloc.dart';
      File(project.file(state)).deleteSync();
      File(project.file(controller)).deleteSync();
      await apply(ProjectDoctor(project).inspect().plan);
      expect(
        project.read(state),
        contains('UseCaseState<DashboardEntity> homeStatus'),
      );
      expect(project.read(state), contains('refreshHomeStatus'));
      expect(project.read(controller), contains('state.homeStatus'));
      expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
    },
  );
}
