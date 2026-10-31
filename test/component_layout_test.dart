import 'dart:convert';
import 'dart:io';

import 'package:cleany/cleany.dart';
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
        expect(
          plan.files.containsKey('lib/app/di/injection.dart'),
          mode != StateManagement.none,
        );
        if (mode != StateManagement.none) {
          expect(
            plan.read(widget),
            contains("import '${mode.name}/user_card_${mode.name}.dart'"),
          );
          expect(plan.read(widget), isNot(contains("import '../")));
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
          contains('components/profile_card/profile_card_widget.dart'),
        );
        expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
        await source(
          generator.remove(
            name: 'profile_card',
            kind: GenerationKind.component,
          ),
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
        );
        final conversion = GenerationPlan(project)
          ..delete('lib/components/card/card_widget.dart');
        for (final file in legacy.entries) {
          conversion.write(file.key, file.value);
        }
        entry.remove('component_layout');
        entry['template_version'] = '2.0.0';
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
          contains('/card/widgets/card_widget.dart'),
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
    },
  );
}
