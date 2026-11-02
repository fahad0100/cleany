// Navigation delegates controller construction to the application composition root.
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../core/storage/session_store.dart';
import '../../features/carts/domain/entities/cart_draft.dart';
import '../config/store_preferences.dart';
import '../store_shell.dart';
import '../composition/feature_pages.dart';
import 'route_names.dart';

GoRouter createRouter(GetIt container) => GoRouter(
  initialLocation: RouteNames.products,
  routes: buildRoutes(container),
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text(state.error?.message ?? 'Page not found')),
  ),
);
List<RouteBase> buildRoutes(GetIt container) => [
  GoRoute(path: RouteNames.root, redirect: (_, _) => RouteNames.products),
  ShellRoute(
    builder: (context, state, child) => StoreShell(
      location: state.uri.path,
      preferences: container<StorePreferences>(),
      session: container<SessionStore>(),
      child: child,
    ),
    routes: [
      GoRoute(
        path: RouteNames.products,
        builder: (_, _) => FeaturePages.products(container),
      ),
      GoRoute(
        path: RouteNames.carts,
        builder: (_, state) => FeaturePages.carts(
          container,
          draft: state.extra is CartDraft ? state.extra as CartDraft : null,
        ),
      ),
      GoRoute(
        path: RouteNames.users,
        builder: (_, _) => FeaturePages.users(container),
      ),
      GoRoute(
        path: RouteNames.auth,
        builder: (_, _) => FeaturePages.auth(container),
      ),
    ],
  ),
];
