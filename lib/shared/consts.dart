import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voz_amiga/shared/app.routes.dart';

class RouteNames {
  static const String login = '/login';
  static const String home = '/';
  static const String activityList = '/activity';
  static const String exercisesList = '/exercises';
  static const String newActivity = '/activity/new/form';
  static String editActivity(String id) => '/activity/$id/form';
  static String activity(String id) => '/activity/$id';
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
