import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voz_amiga/shared/app.routes.dart';

class RouteNames {
  static const String login = '/login';
  static const String home = '/';

  static String newExercise = '/exercise/new/form';
  static String editExercise(String id) => '/exercise/$id/form';
  static String assignExercise(String id) => '/exercise/$id/assign';
  static String exercise(String id) => '/exercise/$id';

  static const String activityList = '/activity';
  static const String exercisesList = '/exercise';
  static const String newActivity = '/activity/new/form';
  static const String patientsList = '/patient';
  static const String newPatient = '/patient/new/form';
  static const String professionalsList = '/professional';
  static const String newProfessional = '/professional/new/form';
  static const String settings = '/settings';
  static const String changePassword = '/settings/changePassword';
  static String editProfessional(String id) => '/professional/$id/form';
  static String professional(String id) => '/professional/$id';
  static String editPatient(String id) => '/patient/$id/form';
  static String assignedExercise(String id, String idAssignedExercise) =>
      '/patient/$id/AssignedExercise/$idAssignedExercise';
  static String activityAttempts(
          String id, String idAssignedExercise, String idActivityAttempt) =>
      '/patient/$id/AssignedExercise/$idAssignedExercise/$idActivityAttempt';
  static String patient(String id) => '/patient/$id';
  static String patientReports(String id) => '/patient/$id/reports';
  static String patientFrequencyReport(String id) =>
      '/patient/$id/frequencyReport';
  static String editActivity(String id) => '/activity/$id/form';
  static String assignActivity(String id) => '/activity/$id/assign';
  static String activity(String id) => '/activity/$id';

  static const String homePatient = '/patientView/home';
  static const String settingsPatient = '/patientView/settings';
  static const String exercisesPatientList = '/patientView/exercisePatient';
  static String executeExercise(String id) =>
      '/patientView/exercisePatient/$id';
}

AppBar createAppBar({
  required BuildContext context,
  String title = 'Voz Amiga',
  Widget? leading,
}) {
  return AppBar(
    automaticallyImplyLeading: false,
    leading: leading,
    title: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    actions: [_menu()],
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
  );
}

class AppBarMenu {
  final String label;
  final Widget icon;
  final VoidCallback Function(BuildContext) action;

  AppBarMenu({required this.label, required this.icon, required this.action});
}

Widget _menu() {
  final menu = <AppBarMenu>[
    AppBarMenu(
      label: 'Configurações',
      icon: const Icon(Icons.settings),
      action: (BuildContext context) {
        return () {};
      },
    ),
    AppBarMenu(
      label: 'Logout',
      icon: const Icon(Icons.exit_to_app_outlined),
      action: (BuildContext context) {
        return () {
          AppRouteConfig.rootNavigatorKey.currentContext
              ?.pushReplacementNamed('Login'); // clear last appstate
          // AppRouteConfig.rootNavigatorKey.
        };
      },
    ),
  ];

  return MenuAnchor(
    builder: (
      BuildContext context,
      MenuController controller,
      Widget? child,
    ) {
      return IconButton(
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
        icon: const Icon(Icons.more_vert_sharp),
        tooltip: 'Opções',
      );
    },
    menuChildren: List<Builder>.generate(
      menu.length,
      (int i) => Builder(builder: (context) {
        return MenuItemButton(
          onPressed: menu[i].action(context),
          leadingIcon: menu[i].icon,
          child: Text(
            menu[i].label,
          ),
        );
      }),
    ),
  );
}

// ignore: constant_identifier_names
const String SHARED_LOGGED = 'SHARED_LOGGED';
// ignore: constant_identifier_names
const String SHARED_USER = 'SHARED_USER';
// ignore: constant_identifier_names
const String SHARED_PASSWORD = 'SHARED_PASSWORD';
