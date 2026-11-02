// Loads environment settings and dependencies before starting Flutter.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'app.dart';
import 'config/store_preferences.dart';
import 'config/app_config.dart';
import 'config/app_environment.dart';
import 'config/flavor_config.dart';
import 'di/injection.dart';
import 'router/app_router.dart';

/// Loads environment settings and dependencies before starting Flutter.
Future<void> bootstrap(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = GetIt.asNewInstance();
  var stage = 'loading public flavor configuration';
  try {
    final flavor = await FlavorConfig.load(environment);
    stage = 'validating API_BASE_URL';
    final config = AppConfig.fromEnvironment(
      environment,
      fallbackBaseUrl: flavor.apiBaseUrl,
    );
    stage = 'configuring application services';
    await configureDependencies(container, config);
    stage = 'creating the router';
    final router = createRouter(container);
    runApp(
      _ApplicationLifetime(
        container: container,
        disposeRouter: router.dispose,
        child: App(router: router, preferences: container<StorePreferences>()),
      ),
    );
  } catch (error, stackTrace) {
    // Startup diagnostics identify the failing stage without printing config values.
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'app.bootstrap',
        context: ErrorDescription(
          'Startup failed while $stage in ${environment.name}.',
        ),
      ),
    );
    try {
      await container.reset(dispose: true);
    } catch (cleanupError, cleanupStack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: cleanupError,
          stack: cleanupStack,
          library: 'app.bootstrap',
          context: ErrorDescription('Cleaning up after startup failure.'),
        ),
      );
    }
    Error.throwWithStackTrace(error, stackTrace);
  }
}

// The application owns its router and services. BlocProvider owns each factory
// controller. Repositories and Dio live until the application root is disposed.
/// Loads environment settings and dependencies before starting Flutter.
class _ApplicationLifetime extends StatefulWidget {
  const _ApplicationLifetime({
    required this.container,
    required this.child,
    required this.disposeRouter,
  });
  final GetIt container;
  final Widget child;
  final VoidCallback disposeRouter;
  @override
  State<_ApplicationLifetime> createState() => _ApplicationLifetimeState();
}

/// Loads environment settings and dependencies before starting Flutter.
class _ApplicationLifetimeState extends State<_ApplicationLifetime> {
  @override
  void dispose() {
    widget.disposeRouter();
    unawaited(
      widget.container.reset(dispose: true).catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'app.bootstrap',
            context: ErrorDescription('Disposing application services.'),
          ),
        );
      }),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
