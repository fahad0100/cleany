// Defines navigation paths and connects routes to presentation factories.
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../composition/feature_pages.dart';
import 'route_names.dart';

/// Defines navigation paths and connects routes to presentation factories.
GoRouter createRouter(GetIt container) => GoRouter(
  routes: buildRoutes(container),
  errorBuilder: (context, state) =>
      const Scaffold(body: Center(child: Text('Page not found'))),
);

/// Defines navigation paths and connects routes to presentation factories.
List<RouteBase> buildRoutes(GetIt container) => [
  GoRoute(
    path: RouteNames.root,
    builder: (context, state) => FeaturePages.placeholder(container),
  ),

  GoRoute(
    path: RouteNames.probe,
    builder: (context, state) => FeaturePages.probe(container),
  ),
];
