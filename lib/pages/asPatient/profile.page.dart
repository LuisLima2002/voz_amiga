import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voz_amiga/components/app_bar.dart';

class NavigationPatientContainer extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final String title;

  const NavigationPatientContainer({
    this.title = "Luigui",
    Key? key,
    required this.navigationShell,
  }) : super(key: key ?? const ValueKey('NavigationPatientContainer'));

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final mediaData = MediaQuery.of(context);
      final isLandscape = mediaData.orientation == Orientation.landscape;
      return isLandscape
          ? _landscapeNavigation(context, constraints)
          : _portraitLayout(context);
    });
  }

  Widget _portraitLayout(BuildContext context) {
    return Scaffold(
      body:navigationShell,
      appBar: VaAppBar(
        title: title,
      ),
      bottomNavigationBar: NavigationBar(
        height: 60,
        selectedIndex: navigationShell.currentIndex,
        destinations: _destinations,
        onDestinationSelected: _goBranch,
      ),
    );
  }

  Widget _landscapeNavigation(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final Widget rail = constraints.maxWidth > 900
        ? NavigationRail(
            extended: true,
            elevation: 3,
            indicatorColor: const Color(0xFFD0D0D0),
            useIndicator: true,
            selectedIconTheme: const IconThemeData(
              color: Colors.purple,
            ),
            selectedLabelTextStyle: const TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.w700,
            ),
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
            labelType: NavigationRailLabelType.none,
            destinations: _railDestinations,
            // indicatorShape: BoxBorder(),
          )
        : NavigationRail(
            extended: false,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
            labelType: NavigationRailLabelType.all,
            destinations: _railDestinations,
          );

    return Scaffold(
      appBar: VaAppBar(
        title: title,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fixed navigation rail on the left (start)
          rail,
          const VerticalDivider(thickness: 1, width: 1),
          // Main content on the right (end)
          Expanded(
            child: navigationShell,
          ),
        ],
      ),
    );
  }

  List<NavigationRailDestination> get _railDestinations {
    return _destinations.map(
      (d) {
        return NavigationRailDestination(
          indicatorColor: Colors.grey,
          icon: d.icon,
          selectedIcon: d.selectedIcon,
          label: Text(d.label),
          disabled: !d.enabled,
        );
      },
    ).toList();
  }

  List<NavigationDestination> get _destinations {
    return const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_filled),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.task_outlined),
        selectedIcon: Icon(Icons.task_rounded),
        label: 'Atividades Paciente',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings),
        selectedIcon: Icon(Icons.settings_outlined),
        label: 'Ajustes',
      ),
      // NavigationDestination(
      //   icon: Icon(Icons.file_present),
      //   selectedIcon: Icon(Icons.file_present_outlined),
      //   label: 'Histórico',
      // ),
      // NavigationDestination(
      //   icon: Icon(Icons.settings),
      //   selectedIcon: Icon(Icons.settings_outlined),
      //   label: 'Ajustes',
      // )
    ];
  }

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
