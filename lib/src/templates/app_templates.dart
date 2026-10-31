/// Fixed shared template module.
Map<String, String> appTemplates() => {
  'lib/app/app.dart': '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/localization/generated/app_localizations.dart';
import '../core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({required this.router, super.key});
  final GoRouter router;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    routerConfig: router,
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    debugShowCheckedModeBanner: false,
  );
}
''',
  'lib/app/bootstrap.dart': '''
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'app.dart';
import 'config/app_config.dart';
import 'config/app_environment.dart';
import 'config/flavor_config.dart';
import 'di/injection.dart';
import 'router/app_router.dart';

Future<void> bootstrap(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = GetIt.asNewInstance();
  var stage = 'loading public flavor configuration';
  try {
    final flavor = await FlavorConfig.load(environment);
    stage = 'validating API_BASE_URL';
    final config = AppConfig.fromEnvironment(environment, fallbackBaseUrl: flavor.apiBaseUrl);
    stage = 'configuring application services';
    await configureDependencies(container, config);
    stage = 'creating the router';
    final router = createRouter(container);
    runApp(_ApplicationLifetime(container: container, disposeRouter: router.dispose, child: App(router: router)));
  } catch (error, stackTrace) {
    // Startup diagnostics identify the failing stage without printing config values.
    FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stackTrace,
      library: 'app.bootstrap', context: ErrorDescription('Startup failed while \$stage in \${environment.name}.')));
    try { await container.reset(dispose: true); } catch (cleanupError, cleanupStack) {
      FlutterError.reportError(FlutterErrorDetails(exception: cleanupError, stack: cleanupStack,
        library: 'app.bootstrap', context: ErrorDescription('Cleaning up after startup failure.')));
    }
    Error.throwWithStackTrace(error, stackTrace);
  }
}

// The application owns its router and services. BlocProvider owns each factory
// controller. Repositories and Dio live until the application root is disposed.
class _ApplicationLifetime extends StatefulWidget {
  const _ApplicationLifetime({required this.container, required this.child, required this.disposeRouter});
  final GetIt container;
  final Widget child;
  final VoidCallback disposeRouter;
  @override
  State<_ApplicationLifetime> createState() => _ApplicationLifetimeState();
}

class _ApplicationLifetimeState extends State<_ApplicationLifetime> {
  @override
  void dispose() {
    widget.disposeRouter();
    unawaited(widget.container.reset(dispose: true).catchError((Object error, StackTrace stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stackTrace,
        library: 'app.bootstrap', context: ErrorDescription('Disposing application services.')));
    }));
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => widget.child;
}
''',
  'lib/app/config/app_environment.dart': '''
enum AppEnvironment { dev, uat, prod }
''',
  'lib/app/config/app_config.dart': r'''
import 'app_environment.dart';

class AppConfig {
  const AppConfig({required this.environment, required this.apiBaseUrl});
  final AppEnvironment environment;
  final String apiBaseUrl;

  factory AppConfig.fromEnvironment(AppEnvironment environment, {String fallbackBaseUrl = ''}) {
    const override = String.fromEnvironment('API_BASE_URL');
    final baseUrl = override.isEmpty ? fallbackBaseUrl : override;
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || !uri.hasAuthority ||
        !{'http', 'https'}.contains(uri.scheme) ||
        uri.userInfo.isNotEmpty || uri.hasQuery || uri.hasFragment ||
        (environment != AppEnvironment.dev && uri.scheme != 'https')) {
      throw StateError('Provide a valid API_BASE_URL; UAT and prod require HTTPS.');
    }
    return AppConfig(environment: environment, apiBaseUrl: baseUrl);
  }
}
''',
  'lib/app/di/injection.dart': '''
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../config/app_config.dart';
import '../../core/network/dio/dio_client.dart';

// One composition root. Application services live in an explicit app scope.
// Repositories are lazy singletons; presentation controllers are factories.
Future<void> configureDependencies(GetIt container, AppConfig config) async {
  container.pushNewScope(scopeName: 'app');
  try {
    container.registerSingleton<AppConfig>(config);
    container.registerLazySingleton<Dio>(
      () => createDio(config.apiBaseUrl), dispose: (dio) => dio.close(force: true));
    registerFeatureDependencies(container);
  } catch (_) {
    await container.popScope();
    rethrow;
  }
}

void registerFeatureDependencies(GetIt container) {}

Future<void> disposeDependencies(GetIt container) => container.popScope();
''',
  'lib/app/composition/feature_pages.dart': '''
// Presentation factories are wired here, keeping the router independent of
// controllers and data-layer implementation details.
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import '../../core/localization/generated/app_localizations.dart';

class FeaturePages {
  FeaturePages._();
  static Widget placeholder(GetIt container) => Builder(
    builder: (context) => Center(child: Text(AppLocalizations.of(context).welcome)),
  );
}
''',
  'lib/app/router/app_router.dart': '''
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../composition/feature_pages.dart';
import 'route_names.dart';

GoRouter createRouter(GetIt container) => GoRouter(
  routes: buildRoutes(container),
  errorBuilder: (context, state) => const Scaffold(
    body: Center(child: Text('Page not found')),
  ),
);

List<RouteBase> buildRoutes(GetIt container) => [
  GoRoute(path: RouteNames.root, builder: (context, state) => FeaturePages.placeholder(container)),
];
''',
  'lib/app/router/route_names.dart': '''
class RouteNames {
  RouteNames._();
  static const root = '/';
}
''',
};
