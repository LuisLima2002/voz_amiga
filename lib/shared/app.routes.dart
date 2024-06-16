// libs
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voz_amiga/pages/patients/patient_form.page.dart';
import 'package:voz_amiga/pages/patients/patient_viewer.dart';
import 'package:voz_amiga/pages/patients/patients_list.page.dart';
// other
import 'package:voz_amiga/shared/consts.dart';
// pages
import 'package:voz_amiga/pages/activity/activity_list.page.dart';
import 'package:voz_amiga/pages/navigation_container.page.dart';
import 'package:voz_amiga/pages/login.page.dart';
import 'package:voz_amiga/pages/activity/activity_form.page.dart';
import 'package:voz_amiga/pages/activity/activity_viewer.dart';
import 'package:voz_amiga/pages/exercises/exercises_list.page.dart';
import 'package:voz_amiga/pages/home.page.dart';

class AppRouteConfig {
  static final rootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'GlobalNavigationKey',
  );

  static GoRouter getRouterConfig() {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: RouteNames.newActivity,
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
    final pacientsPageKey = GlobalKey<NavigatorState>(
      debugLabel: 'pacientsPageNavigation',
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
              GoRoute(
                name: 'Home Paciente',
                path: RouteNames.homePatient,
                builder: (context, state) => const Text("Vocé está logado como paciente"),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: activitiesPageKey,
            routes: [
              GoRoute(
                name: 'Atividades',
                path: RouteNames.activityList,
                builder: (context, state) {
                  return const ActivityListPage();
                },
                routes: [
                  GoRoute(
                    name: 'Atividade',
                    path: ':id',
                    builder: (context, state) {
                      return ActivityViewerPage(
                        id: state.pathParameters['id']!,
                      );
                    },
                  ),
                  GoRoute(
                    name: 'Nova Atividade',
                    path: ':id/form',
                    builder: (context, state) {
                      return ActivityFormPage(
                        id: state.pathParameters['id'],
                      );
                    },
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
          StatefulShellBranch(
            navigatorKey: pacientsPageKey,
            routes: [
              GoRoute(
                name: 'Pacientes',
                path: RouteNames.patientsList,
                builder: (context, state) {
                  return const PatientsListPage();
                },
                routes: [
                  GoRoute(
                    name: 'Paciente',
                    path: ':id',
                    builder: (context, state) {
                      return PatientViewerPage(
                        id: state.pathParameters['id']!,
                      );
                    },
                  ),
                  GoRoute(
                    name: 'Novo paciente',
                    path: ':id/form',
                    builder: (context, state) {
                      return PatientFormPage(
                        id: state.pathParameters['id'],
                      );
                    },
                  ),
                ],
              ),
            ],
          )
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
