// libs
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voz_amiga/pages/activity/activity_form.page.dart';
import 'package:voz_amiga/pages/exercises/exercises_list.page.dart';
import 'package:voz_amiga/pages/home.page.dart';
// other
import 'package:voz_amiga/shared/consts.dart';
// pages
import 'package:voz_amiga/pages/activity/activity_list.page.dart';
import 'package:voz_amiga/pages/navigation_container.page.dart';
import 'package:voz_amiga/pages/login.page.dart';

class AppRouteConfig {
  static final rootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'GlobalNavigationKey',
  );

  static GoRouter getRouterConfig() {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: RouteNames.activityList,
      routes: _getAplicationRoutes(),
    );
  }

  static List<RouteBase> _getAplicationRoutes() {
    final innerPagesKey = GlobalKey<NavigatorState>(
      debugLabel: 'homePageNavigation',
    );
    final activitiesPageKey = GlobalKey<NavigatorState>(
      debugLabel: 'activitiesPageNavigation',
    );
    final exercisesPageKey = GlobalKey<NavigatorState>(
      debugLabel: 'exercisesPageNavigation',
    );

    return [
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return NavigationContainer(
            title: state.topRoute?.name ?? 'Voz Amiga',
            navigationShell: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: innerPagesKey,
            routes: [
              GoRoute(
                name: 'Home',
                path: RouteNames.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: activitiesPageKey,
            routes: [
              GoRoute(
                name: 'Atividades',
                path: RouteNames.activityList,
                pageBuilder: (context, state) {
                  return const NoTransitionPage(child: ActivityListPage());
                },
                routes: [
                  GoRoute(
                    name: 'Nova Atividade',
                    path: ':id',
                    builder: (context, state) => const ActivityFormPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: exercisesPageKey,
            routes: [
              GoRoute(
                name: 'Exercícios',
                path: RouteNames.exercisesList,
                builder: (context, state) => const ExercisesListPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        name: 'Login',
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
    ];
  }
}
