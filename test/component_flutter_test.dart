import 'dart:io';

import 'package:cleany/cleany.dart';
import 'package:cleany/src/registry.dart';
import 'package:test/test.dart';

/// Builds only generated components in a minimal Flutter widget-test project.
void main() {
  test(
    'generated components own independent Cubit/Bloc lifetimes without DI',
    () async {
      final source = Directory.systemTemp.createTempSync('cleany_components_');
      final runtime = Directory.systemTemp.createTempSync(
        'cleany_component_ui_',
      );
      try {
        const pubspec = '''
name: component_fixture
environment:
  sdk: ^3.13.0
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^9.1.1
  freezed_annotation: ^3.1.0
dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.10.4
  freezed: ^3.2.3
flutter:
  uses-material-design: true
''';
        File('${source.path}/pubspec.yaml').writeAsStringSync(pubspec);
        final project = Project(source.path);
        final generator = Generator(project);
        await GenerationTransaction(project).apply(
          generator.initialize(appId: 'com.example.components'),
          install: false,
          build: false,
          analyze: false,
        );
        File('${runtime.path}/pubspec.yaml').writeAsStringSync(pubspec);
        for (final mode in StateManagement.values) {
          final plan = generator.generate(
            name: 'card_${mode.name}',
            kind: GenerationKind.component,
            state: mode,
          );
          expect(plan.files.keys, isNot(contains('lib/app/di/injection.dart')));
          expect(
            plan.files.keys,
            isNot(contains('lib/app/composition/feature_pages.dart')),
          );
          for (final entry in plan.files.entries) {
            if (!entry.key.startsWith('lib/components/')) continue;
            File('${runtime.path}/${entry.key}')
              ..parent.createSync(recursive: true)
              ..writeAsBytesSync(entry.value.after!);
          }
        }
        for (final path in [
          'lib/core/state/use_case_state.dart',
          'lib/core/errors/failure.dart',
        ]) {
          File('${runtime.path}/$path')
            ..parent.createSync(recursive: true)
            ..writeAsStringSync(project.read(path));
        }
        File('${runtime.path}/test/components_test.dart')
          ..parent.createSync(recursive: true)
          ..writeAsStringSync(_widgetTests);
        Future<void> run(String executable, List<String> arguments) async {
          final result = await executeCommand(
            executable,
            arguments,
            runtime.path,
          );
          print(result.output);
          result.requireSuccess('$executable ${arguments.join(' ')}');
        }

        await run('flutter', ['pub', 'get']);
        await run('dart', ['run', 'build_runner', 'build']);
        // Reproduce the reported failure in a real analyzer, then apply a
        // normal generation plan through isolated transaction validation.
        final runtimeProject = Project(runtime.path);
        File(
            runtimeProject.file(
              'lib/components/verify_login/verify_login_widget.dart',
            ),
          )
          ..parent.createSync(recursive: true)
          ..writeAsStringSync(_requiredPhoneWidget);
        File(runtimeProject.file('lib/app/composition/feature_pages.dart'))
          ..parent.createSync(recursive: true)
          ..writeAsStringSync(_legacyComposition);
        File(runtimeProject.file(registryPath))
          ..parent.createSync(recursive: true)
          ..writeAsStringSync(
            prettyJson({
              'version': registryVersion,
              'api_provider': 'dio',
              'features': [
                {
                  'name': 'verify_login',
                  'path': 'lib/components/verify_login',
                  'kind': 'component',
                  'state': 'none',
                  'component_layout': 'flat',
                  'files': [],
                  'integrations': [],
                },
              ],
            }),
          );
        final before = await executeCommand('flutter', [
          'analyze',
          '--no-pub',
        ], runtime.path);
        expect(before.succeeded, isFalse);
        expect(
          '${before.output}\n${before.error}',
          contains('missing_required_argument'),
        );
        print(
          'Confirmed original missing_required_argument for required phone.',
        );
        final fix = Generator(runtimeProject).generate(
          name: 'next_card',
          kind: GenerationKind.component,
          state: StateManagement.none,
        );
        expect(
          fix.read('lib/app/composition/feature_pages.dart'),
          isNot(contains('verifyLogin(')),
        );
        expect(
          fix.files.containsKey(
            'lib/components/verify_login/verify_login_widget.dart',
          ),
          isFalse,
        );
        await GenerationTransaction(
          runtimeProject,
          context: OperationContext(
            onProgress: (event) => print(event.command ?? event.stage),
          ),
        ).apply(fix, build: false);
        expect(
          runtimeProject.read(
            'lib/components/verify_login/verify_login_widget.dart',
          ),
          _requiredPhoneWidget,
        );
        await run('flutter', ['analyze', '--no-pub']);
        await run('flutter', ['test', '--no-pub', 'test/components_test.dart']);
      } finally {
        source.deleteSync(recursive: true);
        runtime.deleteSync(recursive: true);
      }
    },
    skip: Platform.environment['CLEANY_FLUTTER_INTEGRATION'] != 'true',
    timeout: const Timeout(Duration(minutes: 8)),
  );
}

const _widgetTests = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:component_fixture/components/card_cubit/card_cubit_widget.dart';
import 'package:component_fixture/components/card_cubit/cubit/card_cubit_cubit.dart';
import 'package:component_fixture/components/card_cubit/cubit/card_cubit_state.dart';
import 'package:component_fixture/components/card_bloc/card_bloc_widget.dart';
import 'package:component_fixture/components/card_bloc/bloc/card_bloc_bloc.dart';
import 'package:component_fixture/components/card_bloc/bloc/card_bloc_event.dart';
import 'package:component_fixture/components/card_bloc/bloc/card_bloc_state.dart';
import 'package:component_fixture/components/card_none/card_none_widget.dart';
import 'package:component_fixture/core/state/use_case_state.dart';
import 'package:component_fixture/components/verify_login/verify_login_widget.dart';

void main() {
  testWidgets('feature UI supplies the required component phone directly', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: VerifyLoginWidget(phone: '0551234567')));
    expect(find.text('0551234567'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Cubit instances are isolated, survive rebuild and close on removal', (tester) async {
    const first = ValueKey('first');
    const second = ValueKey('second');
    Widget tree() => MaterialApp(home: Row(children: [
      CardCubitWidget(key: first), CardCubitWidget(key: second),
    ]));
    await tester.pumpWidget(tree());
    CardCubitCubit controller(Key key) => tester.element(find.descendant(
      of: find.byKey(key), matching: find.byType(BlocBuilder<CardCubitCubit, CardCubitState>),
    )).read<CardCubitCubit>();
    final one = controller(first);
    final two = controller(second);
    expect(identical(one, two), isFalse);
    one.update(7);
    await tester.pump();
    expect(find.text('7'), findsOneWidget);
    expect(two.state.cardCubitStatus, isA<UseCaseInitial<int>>());
    await tester.pumpWidget(tree());
    expect(identical(controller(first), one), isTrue);
    expect(find.text('7'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(one.isClosed, isTrue);
    expect(two.isClosed, isTrue);
    one.update(9);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bloc is provided locally, processes events and closes on removal', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CardBlocWidget()));
    final bloc = tester.element(find.byType(BlocBuilder<CardBlocBloc, CardBlocState>)).read<CardBlocBloc>();
    final updated = bloc.stream.firstWhere((state) => state.cardBlocStatus is UseCaseSuccess<int>);
    bloc.add(const CardBlocEvent.requested());
    await updated;
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(bloc.isClosed, isTrue);
    bloc.add(const CardBlocEvent.requested());
    expect(tester.takeException(), isNull);
  });

  testWidgets('component never borrows or disposes a parent controller', (tester) async {
    final parent = CardCubitCubit()..update(99);
    addTearDown(parent.close);
    await tester.pumpWidget(BlocProvider.value(
      value: parent, child: const MaterialApp(home: CardCubitWidget()),
    ));
    final local = tester.element(find.byType(BlocBuilder<CardCubitCubit, CardCubitState>)).read<CardCubitCubit>();
    expect(identical(local, parent), isFalse);
    expect(local.state.cardCubitStatus, isA<UseCaseInitial<int>>());
    expect(find.text('99'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(local.isClosed, isTrue);
    expect(parent.isClosed, isFalse);
  });

  testWidgets('stateless component builds without any provider or container', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CardNoneWidget()));
    expect(find.byType(CardNoneWidget), findsOneWidget);
    expect(find.byType(BlocProvider<CardCubitCubit>), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
''';

const _requiredPhoneWidget = '''
import 'package:flutter/widgets.dart';
class VerifyLoginWidget extends StatelessWidget {
  const VerifyLoginWidget({super.key, required this.phone});
  final String phone;
  @override
  Widget build(BuildContext context) => Text(phone);
}
''';

const _legacyComposition = '''
import 'package:flutter/widgets.dart';
import '../../components/verify_login/verify_login_widget.dart';
class GetIt {}
class FeaturePages {
  static Widget placeholder(GetIt container) => const SizedBox.shrink();
  static Widget verifyLogin(GetIt container) => const VerifyLoginWidget();
}
''';
