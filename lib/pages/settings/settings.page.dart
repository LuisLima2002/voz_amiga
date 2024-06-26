import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voz_amiga/shared/consts.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(children: [ MenuItemButton(onPressed: (){ context.go(RouteNames.changePassword);}, child: const Text("Redefinir Senha"))],)
      ),
    );
  }
}