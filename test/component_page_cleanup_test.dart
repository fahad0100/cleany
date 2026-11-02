import 'dart:convert';
import 'dart:io';

import 'package:cleany/cleany.dart';
import 'package:cleany/src/ast_editor.dart';
import 'package:cleany/src/registry.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late Project project;
  late Generator generator;
  const pages = 'lib/app/composition/feature_pages.dart';
  const widget = 'lib/components/verify_login/verify_login_widget.dart';
  Future<void> apply(GenerationPlan plan) async {
    await GenerationTransaction(project)
        .apply(plan, install: false, build: false, analyze: false);
  }

  Future<void> legacy({
    bool local = false,
    String? factory,
    String? widgetImport,
  }) async {
    await apply(
      generator.generate(
        name: 'verify_login',
        kind: GenerationKind.component,
        state: StateManagement.none,
      ),
    );
    // Real customization: required input is supplied by the containing feature.
    File(project.file(widget)).writeAsStringSync('''
import 'package:flutter/widgets.dart';
class VerifyLoginWidget extends StatelessWidget {
  const VerifyLoginWidget({super.key, required this.phone});
  final String phone;
  @override
  Widget build(BuildContext context) => Text(phone);
}
''');
    final registry = generator.readRegistry();
    final entry = (registry['features'] as List).single;
    if (!local) entry.remove('component_scope');
    final editor = AstEditor(project.read(pages))
      ..addImports([
        widgetImport ??
            '../../components/verify_login/verify_login_widget.dart',
      ])
      ..addMembers(
        'FeaturePages',
        factory ?? 'static Widget verifyLogin(GetIt container) => const VerifyLoginWidget();',
      );
    File(project.file(pages)).writeAsStringSync(editor.source);
    entry['integrations'] = [
      {
        'path': pages,
        'node': 'FeaturePages.verifyLogin',
        'owner': 'verify_login',
        'sha256': contentDigest(
          utf8.encode(editor.integrationNodes()['FeaturePages.verifyLogin']!),
        ),
      },
    ];
    File(project.file(registryPath)).writeAsStringSync(prettyJson(registry));
  }

  setUp(() async {
    directory = Directory.systemTemp.createTempSync('cleany_component_pages_');
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
    await apply(generator.initialize(appId: 'com.example.fixture'));
  });
  tearDown(() => directory.deleteSync(recursive: true));

  for (final local in [false, true]) {
    test(
      'generation removes stale component factory before validation (local=$local)',
      () async {
        await legacy(local: local);
        final customized = project.read(widget);
        final plan = generator.generate(
          name: 'next_card',
          kind: GenerationKind.component,
          state: StateManagement.none,
        );
        expect(plan.files.keys, contains(pages)); // Visible in the review plan.
        expect(plan.read(pages), isNot(contains('VerifyLoginWidget')));
        expect(plan.read(pages), isNot(contains('verifyLogin(')));
        expect(plan.read(pages), contains('placeholder(GetIt container)'));
        expect(plan.files.containsKey(widget), isFalse);
        await apply(plan);
        expect(project.read(widget), customized);
        final entry = (generator.readRegistry()['features'] as List).first;
        expect(
          (entry['integrations'] as List).any(
            (node) => node['node'] == 'FeaturePages.verifyLogin',
          ),
          isFalse,
        );
        final report = ProjectDoctor(project).inspect();
        expect(report.plan.files, isEmpty);
      },
    );
  }

  test(
    'Doctor removes the legacy default call and does not regenerate it',
    () async {
      await legacy();
      final customized = project.read(widget);
      final repair = ProjectDoctor(project).inspect().plan;
      expect(repair.read(pages), isNot(contains('VerifyLoginWidget')));
      await apply(repair);
      expect(project.read(widget), customized);
      expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
      File(project.file(registryPath)).deleteSync();
      await apply(ProjectDoctor(project).inspect().plan);
      expect(project.read(pages), isNot(contains('VerifyLoginWidget')));
      expect(ProjectDoctor(project).inspect().plan.files, isEmpty);
    },
  );

  test('a placeholder argument workaround is also removed', () async {
    await legacy(
      factory: "static Widget verifyLogin(GetIt container) => const VerifyLoginWidget(phone: '');",
    );
    await apply(ProjectDoctor(project).inspect().plan);
    expect(project.read(pages), isNot(contains('verifyLogin(')));
  });

  for (final state in [StateManagement.cubit, StateManagement.bloc]) {
    test(
      'removes the old typed ${state.name} provider wrapper and unused imports',
      () async {
        await legacy();
        final type = state == StateManagement.cubit
            ? 'VerifyLoginCubit'
            : 'VerifyLoginBloc';
        final registry = generator.readRegistry();
        (registry['features'] as List).single['state'] = state.name;
        File(project.file(registryPath))
            .writeAsStringSync(prettyJson(registry));
        final editor = AstEditor(project.read(pages))
          ..removeMembers('FeaturePages', {'verifyLogin'});
        editor.addImports([
          'package:flutter_bloc/flutter_bloc.dart',
          '../../components/verify_login/${state.name}/verify_login_${state.name}.dart',
        ]);
        editor.addMembers('FeaturePages', '''
static Widget verifyLogin(GetIt container) => BlocProvider<$type>(
  create: (_) => container<$type>(), child: const VerifyLoginWidget(),
);
''');
        File(project.file(pages)).writeAsStringSync(editor.source);
        final plan = generator.generate(
          name: 'next_card',
          kind: GenerationKind.component,
          state: StateManagement.none,
        );
        expect(plan.read(pages), isNot(contains('verifyLogin(')));
        expect(plan.read(pages), isNot(contains('flutter_bloc')));
        expect(plan.read(pages), isNot(contains('verify_login')));
      },
    );
  }

  test(
    'keeps custom factories that explicitly forward required inputs',
    () async {
      await legacy(
        factory: 'static Widget verifyLogin(GetIt container, {required String phone}) => VerifyLoginWidget(phone: phone);',
      );
      final before = project.read(pages);
      final report = ProjectDoctor(project).inspect();
      expect(report.plan.files.containsKey(pages), isFalse);
      await apply(report.plan);
      expect(project.read(pages), before);
    },
  );

  test(
    'keeps a shared import used by an unrelated real feature factory',
    () async {
      await legacy();
      final editor = AstEditor(project.read(pages))
        ..addMembers(
          'FeaturePages',
          "static Widget loginPage(GetIt container) => const VerifyLoginWidget(phone: 'from-feature');",
        );
      File(project.file(pages)).writeAsStringSync(editor.source);
      final plan = generator.generate(
        name: 'next_card',
        kind: GenerationKind.component,
        state: StateManagement.none,
      );
      expect(plan.read(pages), contains('loginPage(GetIt container)'));
      expect(
        plan.read(pages),
        contains(
          "import '../../components/verify_login/verify_login_widget.dart';",
        ),
      );
      expect(plan.read(pages), isNot(contains('verifyLogin(GetIt container)')));
    },
  );

  test('supports package imports with aliases', () async {
    await legacy();
    File(project.file(pages)).writeAsStringSync(
      project
          .read(pages)
          .replaceAll(
            "import '../../components/verify_login/verify_login_widget.dart';",
            "import 'package:fixture_app/components/verify_login/verify_login_widget.dart' as component;",
          )
          .replaceAll(
            'const VerifyLoginWidget()',
            'const component.VerifyLoginWidget()',
          ),
    );
    final plan = generator.generate(
      name: 'next_card',
      kind: GenerationKind.component,
      state: StateManagement.none,
    );
    expect(plan.read(pages), isNot(contains('verify_login')));
    expect(plan.read(pages), isNot(contains('verifyLogin(')));
  });

  test(
    'retains other public helpers imported from the component library',
    () async {
      await legacy();
      File(project.file(widget)).writeAsStringSync(
        '${project.read(widget)}\nconst loginLabel = "Login";\n',
      );
      final editor = AstEditor(project.read(pages))
        ..addMembers(
          'FeaturePages',
          'static Widget loginPage(GetIt container) => const Text(loginLabel);',
        );
      File(project.file(pages)).writeAsStringSync(editor.source);
      final plan = generator.generate(
        name: 'next_card',
        kind: GenerationKind.component,
        state: StateManagement.none,
      );
      expect(plan.read(pages), contains('verify_login_widget.dart'));
      expect(plan.read(pages), contains('Text(loginLabel)'));
      expect(plan.read(pages), isNot(contains('verifyLogin(')));
    },
  );
}
