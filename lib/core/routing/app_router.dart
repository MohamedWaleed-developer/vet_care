import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create({
    required Widget Function(BuildContext, GoRouterState)
    splashBuilder,
    required Widget Function(BuildContext, GoRouterState)
    loginBuilder,
    required Widget Function(BuildContext, GoRouterState)
    registerBuilder,
    required Widget Function(BuildContext, GoRouterState)
    homeBuilder,
  }) {
    return GoRouter(
      initialLocation: RouteNames.splash,
      routes: [
        GoRoute(
          path: RouteNames.splash,
          builder: splashBuilder,
        ),
        GoRoute(
          path: RouteNames.login,
          builder: loginBuilder,
        ),
        GoRoute(
          path: RouteNames.register,
          builder: registerBuilder,
        ),
        GoRoute(
          path: RouteNames.home,
          builder: homeBuilder,
        ),
      ],
    );
  }
}