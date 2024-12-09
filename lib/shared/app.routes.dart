// libs

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voz_amiga/features/profissional/activity/pages/assign_activity.page.dart';
import 'package:voz_amiga/pages/asPatient/execute_activity.page.dart';
import 'package:voz_amiga/pages/asPatient/settings_patient.page.dart';
import 'package:voz_amiga/features/profissional/exercises/pages/assign_exercise.page.dart';
import 'package:voz_amiga/features/profissional/exercises/pages/exercise_form.page.dart';
import 'package:voz_amiga/features/profissional/exercises/pages/exercise_viewer.dart';
import 'package:voz_amiga/infra/services/login.service.dart';
import 'package:voz_amiga/pages/asPatient/profile.page.dart';
import 'package:voz_amiga/pages/patients/patient_activity_attempt_viewer.page.dart';
import 'package:voz_amiga/pages/patients/patient_assigned_exercise_viewer.page.dart';
import 'package:voz_amiga/pages/patients/patient_form.page.dart';
import 'package:voz_amiga/pages/patients/patient_frequency_report.dart';
import 'package:voz_amiga/pages/patients/patient_viewer.dart';
import 'package:voz_amiga/pages/patients/patients_list.page.dart';
import 'package:voz_amiga/pages/patients/patient_reports.page.dart';
import 'package:voz_amiga/pages/professionals/professional_form.page.dart';
import 'package:voz_amiga/pages/professionals/professional_viewer.dart';
import 'package:voz_amiga/pages/professionals/professionals_list.page.dart';
import 'package:voz_amiga/pages/settings/changePassword.page.dart';
import 'package:voz_amiga/pages/settings/settings.page.dart';
// other
import 'package:voz_amiga/shared/consts.dart';
// pages
import 'package:voz_amiga/features/profissional/activity/pages/activity_list.page.dart';
import 'package:voz_amiga/pages/navigation_container.page.dart';
import 'package:voz_amiga/pages/login.page.dart';
import 'package:voz_amiga/features/profissional/activity/pages/activity_form.page.dart';
import 'package:voz_amiga/pages/asPatient/exercises_patient_list.page.dart';
import 'package:voz_amiga/features/profissional/activity/pages/activity_viewer.dart';
import 'package:voz_amiga/features/profissional/exercises/pages/exercises_list.page.dart';
import 'package:voz_amiga/pages/home.page.dart';

class AppRouteConfig {
  static final rootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'GlobalNavigationKey',
  );

  static GoRouter getRouterConfig() {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: RouteNames.home,
      routes: _getAplicationRoutes(),
      redirect: (context, state) async {
        final res = await LoginService().isLoggedIn();
        if (res.token == null) {
          return RouteNames.login;
        } else if (res.isPatient &&
            !state.fullPath!.contains("/patientView/")) {
          return RouteNames.homePatient;
        } else if (!res.isPatient &&
            state.fullPath!.contains("/patientView/")) {
          return RouteNames.home;
        }
        return null;
      },
    );
  }

  static List<RouteBase> _getAplicationRoutes() {
    final innerPagesKey = GlobalKey<NavigatorState>(
      debugLabel: 'homePageNavigation',
    );
    final innerPatientPagesKey = GlobalKey<NavigatorState>(
      debugLabel: 'homePatientPageNavigation',
    );
    final activitiesPageKey = GlobalKey<NavigatorState>(
      debugLabel: 'activitiesPageNavigation',
    );
    final activitiesPatientPageKey = GlobalKey<NavigatorState>(
      debugLabel: 'activitiesPatientPageNavigation',
    );
    final exercisesPageKey = GlobalKey<NavigatorState>(
      debugLabel: 'exercisesPageNavigation',
    );
    final pacientsPageKey = GlobalKey<NavigatorState>(
      debugLabel: 'pacientsPageNavigation',
    );
    final professionalsPageKey = GlobalKey<NavigatorState>(
      debugLabel: 'profissionalsPageNavigation',
    );

    final settingsPageKey = GlobalKey<NavigatorState>(
      debugLabel: 'settingsPageNavigation',
    );

    return [
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return NavigationContainer(
            title: state.topRoute?.name ?? 'Home Paciente',
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
              )
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
                    path: ':id/assign',
                    name: 'Atribuir Atividade',
                    builder: (context, state) {
                      return AssignActivityPage(
                        exerciseId: state.pathParameters['id']!,
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
                routes: [
                  GoRoute(
                    name: 'Exercicio',
                    path: ':id',
                    builder: (context, state) {
                      return ExerciseViewerPage(
                        id: state.pathParameters['id']!,
                      );
                    },
                  ),
                  GoRoute(
                    path: ':id/assign',
                    name: 'Atribuir Exercício',
                    builder: (context, state) {
                      return AssignExercisePage(
                        exerciseId: state.pathParameters['id']!,
                      );
                    },
                  ),
                  GoRoute(
                    name: 'Novo Exercicio',
                    path: ':id/form',
                    builder: (context, state) {
                      return ExerciseFormPage(
                        id: state.pathParameters['id'],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: professionalsPageKey,
            routes: [
              GoRoute(
                name: 'Profissionais',
                path: RouteNames.professionalsList,
                builder: (context, state) {
                  return const ProfessionalsListPage();
                },
                routes: [
                  GoRoute(
                    name: 'Profissional',
                    path: ':id',
                    builder: (context, state) {
                      return ProfessionalViewerPage(
                        id: state.pathParameters['id']!,
                      );
                    },
                  ),
                  GoRoute(
                    name: 'Novo profissional',
                    path: ':id/form',
                    builder: (context, state) {
                      return ProfessionalFormPage(
                        id: state.pathParameters['id'],
                      );
                    },
                  ),
                ],
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
                    routes: [
                      GoRoute(
                        name: 'Exercício atribuído',
                        path: 'AssignedExercise/:idAssignedExercise',
                        routes: [
                          GoRoute(
                            name: 'Tentativas da atividade',
                            path: ':idActivityAttempt',
                            builder: (context, state) {
                              return PatientActivityAttemptsViewerPage(
                                assignedExerciseId:
                                    state.pathParameters['idAssignedExercise']!,
                                activityId:
                                    state.pathParameters['idActivityAttempt']!,
                              );
                            },
                          ),
                        ],
                        builder: (context, state) {
                          return PatientAssignedExerciseViewerPage(
                            idPatient: state.pathParameters['id']!,
                            idAssignedExercise:
                                state.pathParameters['idAssignedExercise']!,
                          );
                        },
                      ),
                      GoRoute(
                        name: 'Relatório de frequencia',
                        path: 'frequencyReport',
                        builder: (context, state) {
                          return PatientFrequencyReportPage(
                            id: state.pathParameters['id']!,
                          );
                        },
                      ),
                    ],
                    builder: (context, state) {
                      return PatientViewerPage(
                        id: state.pathParameters['id']!,
                      );
                    },
                  ),
                  GoRoute(
                    name: 'Relatorios',
                    path: ':id/reports',
                    builder: (context, state) {
                      return PatientReportsPage(
                        id: state.pathParameters['id']!,
                      );
                    },
                  ),
                  GoRoute(
                    name: 'Dados do paciente',
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
          ),
          StatefulShellBranch(
            navigatorKey: settingsPageKey,
            routes: [
              GoRoute(
                  name: 'Ajustes',
                  path: RouteNames.settings,
                  builder: (context, state) => const SettingsPage(),
                  routes: [
                    GoRoute(
                      name: 'Redefinir Senha',
                      path: "changePassword",
                      builder: (context, state) => const ChangePassowrdPage(),
                    )
                  ]),
            ],
          )
        ],
      ),
      GoRoute(
        name: 'Login',
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return NavigationPatientContainer(
            title: state.topRoute?.name ?? 'Paciente',
            navigationShell: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: innerPatientPagesKey,
            routes: [
              GoRoute(
                  name: 'Home Paciente',
                  path: RouteNames.homePatient,
                  builder: (context, state) {
                    return const HomePage();
                  })
            ],
          ),
          StatefulShellBranch(
            navigatorKey: activitiesPatientPageKey,
            routes: [
              GoRoute(
                  name: 'Exercícios Paciente',
                  path: RouteNames.exercisesPatientList,
                  builder: (context, state) {
                    return const AssignedExercisesPatientListPage();
                  },
                  routes: [
                    GoRoute(
                      name: 'Realizando Exercício',
                      path: ':id',
                      builder: (context, state) {
                        return ExecuteActivityPage(
                          id: state.pathParameters['id']!,
                        );
                      },
                    ),
                  ]),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: settingsPageKey,
            routes: [
              GoRoute(
                name: 'Ajustes Paciente',
                path: RouteNames.settingsPatient,
                builder: (context, state) => const SettingsPagePatient(),
              ),
            ],
          )
        ],
      ),
    ];
  }
}
