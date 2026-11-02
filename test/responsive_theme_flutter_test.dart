import 'dart:io';

import 'package:cleany/cleany.dart';
import 'package:cleany/src/responsive_support.dart';
import 'package:test/test.dart';

/// Exercises the actual generated App, themes and official localization output.
void main() {
  test(
    'responsive generated themes render, resize, switch brightness and respect text scaling',
    () async {
      final source = Directory.systemTemp.createTempSync(
        'cleany_theme_source_',
      );
      final runtime = Directory.systemTemp.createTempSync(
        'cleany_theme_runtime_',
      );
      try {
        File('${source.path}/pubspec.yaml').writeAsStringSync(
          'name: theme_fixture\nenvironment:\n  sdk: ^3.13.0\ndependencies:\n  flutter:\n    sdk: flutter\n',
        );
        final plan = Generator(Project(source.path))
            .initialize(appId: 'com.example.theme');
        for (final entry in plan.files.entries) {
          if (!(entry.key == 'lib/app/app.dart' ||
              entry.key == 'l10n.yaml' ||
              entry.key == 'analysis_options.yaml' ||
              entry.key.startsWith('lib/core/theme/') ||
              entry.key.startsWith('assets/translations/'))) {
            continue;
          }
          File('${runtime.path}/${entry.key}')
            ..parent.createSync(recursive: true)
            ..writeAsBytesSync(entry.value.after!);
        }
        File('${runtime.path}/pubspec.yaml').writeAsStringSync('''
name: theme_fixture
environment:
  sdk: ^3.13.0
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: any
  sizer: 3.1.3
  go_router: ^18.0.0
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
flutter:
  generate: true
  uses-material-design: true
  assets:
    - assets/translations/
''');
        File('${runtime.path}/test/themes_test.dart')
          ..parent.createSync(recursive: true)
          ..writeAsStringSync(_runtimeTests);
        final migration = GenerationPlan(Project(runtime.path))
          ..write('lib/app/app.dart', _legacyApp);
        expect(planSizerIntegration(migration), isTrue);
        File('${runtime.path}/lib/app/legacy_app.dart').writeAsStringSync(
          migration
              .read('lib/app/app.dart')
              .replaceAll('class App ', 'class LegacyApp ')
              .replaceAll('const App(', 'const LegacyApp('),
        );
        for (final command in [
          ['pub', 'get'],
          ['gen-l10n'],
          ['analyze', '--no-pub'],
          [
            'test',
            '--no-pub',
            'test/themes_test.dart',
            '--reporter',
            'expanded',
          ],
        ]) {
          final result = await executeCommand('flutter', command, runtime.path);
          print(result.output);
          result.requireSuccess('flutter ${command.join(' ')}');
        }
      } finally {
        source.deleteSync(recursive: true);
        runtime.deleteSync(recursive: true);
      }
    },
    skip: Platform.environment['CLEANY_FLUTTER_INTEGRATION'] != 'true',
    timeout: const Timeout(Duration(minutes: 5)),
  );
}

const _runtimeTests = '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:theme_fixture/app/app.dart';
import 'package:theme_fixture/app/legacy_app.dart';
import 'package:theme_fixture/core/theme/app_colors.dart';
import 'package:theme_fixture/core/localization/generated/app_localizations.dart';

class Probe extends StatelessWidget {
  const Probe({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Theme')),
    body: SingleChildScrollView(child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(AppLocalizations.of(context).welcome, key: const ValueKey('greeting')),
        const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Card'))),
        const TextField(decoration: InputDecoration(labelText: 'Label')),
        Row(children: [ElevatedButton(onPressed: () {}, child: const Text('Continue'))]),
      ]),
    )),
  );
}

GoRouter router() => GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => const Probe())]);
ThemeData theme(WidgetTester tester) => Theme.of(tester.element(find.byType(Scaffold)));

void main() {
  testWidgets('legacy root initializes Sizer before evaluating restored theme getters', (tester) async {
    final appRouter = GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('Legacy')))]);
    await tester.pumpWidget(LegacyApp(router: appRouter));
    await tester.pumpAndSettle();
    expect(find.byType(Sizer), findsOneWidget);
    expect(find.text('Legacy'), findsOneWidget);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).title, 'Custom title');
    expect(theme(tester).colorScheme.primary, AppColors.primaryLight);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    appRouter.dispose();
  });
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('renders requested palette and component styles in \$mode', (tester) async {
      final appRouter = router();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(App(router: appRouter, themeMode: mode));
      await tester.pumpAndSettle();
      expect(find.byType(Sizer), findsOneWidget);
      final data = theme(tester);
      final dark = mode == ThemeMode.dark;
      expect(data.useMaterial3, isTrue);
      expect(data.brightness, dark ? Brightness.dark : Brightness.light);
      expect(data.colorScheme.primary, dark ? AppColors.primaryDark : AppColors.primaryLight);
      expect(data.scaffoldBackgroundColor, dark ? AppColors.backgroundDark : AppColors.backgroundLight);
      expect(data.cardTheme.color, dark ? AppColors.surfaceDark : AppColors.surfaceLight);
      expect(data.textTheme.bodyMedium!.color, data.colorScheme.onSurface);
      expect(data.inputDecorationTheme.filled, isTrue);
      final focused = data.inputDecorationTheme.focusedBorder! as OutlineInputBorder;
      expect(focused.borderSide.color, data.colorScheme.primary);
      expect(focused.borderSide.width, 1.5);
      final target = data.elevatedButtonTheme.style!.minimumSize!.resolve({})!;
      expect(target.height, inInclusiveRange(48, 56));
      expect(target.width.isFinite, isTrue);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      appRouter.dispose();
    });
  }

  testWidgets('rebuilds responsive metrics across mobile, tablet, desktop and rotation', (tester) async {
    final appRouter = router();
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpWidget(App(router: appRouter));
    await tester.pumpAndSettle();
    final phone = theme(tester).textTheme.bodyMedium!.fontSize!;
    final phonePadding = (theme(tester).inputDecorationTheme.contentPadding! as EdgeInsets).horizontal;
    expect(Device.screenType, ScreenType.mobile);
    tester.view.physicalSize = const Size(834, 1194);
    await tester.pumpAndSettle();
    expect(Device.screenType, ScreenType.tablet);
    expect(theme(tester).textTheme.bodyMedium!.fontSize!, greaterThan(phone));
    tester.view.physicalSize = const Size(1920, 1080);
    await tester.pumpAndSettle();
    expect(Device.screenType, ScreenType.desktop);
    expect(theme(tester).textTheme.bodyMedium!.fontSize!, inInclusiveRange(14, 17.5));
    expect(theme(tester).textTheme.headlineLarge!.fontSize!, inInclusiveRange(32, 40));
    tester.view.physicalSize = const Size(844, 390);
    await tester.pumpAndSettle();
    expect(Device.orientation, Orientation.landscape);
    expect(Device.screenType, ScreenType.mobile);
    expect((theme(tester).inputDecorationTheme.contentPadding! as EdgeInsets).horizontal, greaterThan(phonePadding));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    appRouter.dispose();
  });

  testWidgets('system brightness switches palettes without replacing the router', (tester) async {
    final appRouter = router();
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpWidget(App(router: appRouter));
    await tester.pumpAndSettle();
    expect(theme(tester).brightness, Brightness.light);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(theme(tester).brightness, Brightness.dark);
    expect(appRouter.routeInformationProvider.value.uri.path, '/');
    await tester.pumpWidget(const SizedBox.shrink());
    appRouter.dispose();
  });

  testWidgets('preserves accessibility text scaling and Arabic RTL localization', (tester) async {
    final appRouter = router();
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    tester.platformDispatcher.localesTestValue = const [Locale('ar')];
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(App(router: appRouter));
    await tester.pumpAndSettle();
    final greeting = find.byKey(const ValueKey('greeting'));
    expect(find.text('مرحبًا'), findsOneWidget);
    final context = tester.element(greeting);
    expect(Directionality.of(context), TextDirection.rtl);
    expect(MediaQuery.textScalerOf(context).scale(14), 28);
    expect(theme(tester).textTheme.bodyMedium!.fontSize!, inInclusiveRange(14, 17.5));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    appRouter.dispose();
  });
}
''';

const _legacyApp = '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
class App extends StatelessWidget {
  const App({required this.router, super.key});
  final GoRouter router;
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Custom title', routerConfig: router,
    theme: AppTheme.light, themeMode: ThemeMode.light,
  );
}
''';
