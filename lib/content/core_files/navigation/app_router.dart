String appRoutesFile() {
  return '''
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'routers.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const Placeholder(), // SplashScreen
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: \${state.uri}')),
    ),
  );
}
''';
}
