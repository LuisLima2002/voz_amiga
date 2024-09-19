import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voz_amiga/infra/services/login.service.dart';
import 'package:voz_amiga/shared/consts.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                MenuItemButton(
                    onPressed: () {
                      context.go(RouteNames.changePassword);
                    },
                    child: const Text("Redefinir Senha"))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                MenuItemButton(
                  onPressed: () {
                    _deleteExercise(context);
                  },
                  child: const Text(
                    "Sair?",
                    style: TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _deleteExercise(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const SizedBox(
            height: 100,
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tem certeza?',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 23,
                  ),
                ),
                Text(
                  'Você realmente deseja sair do app?',
                  maxLines: null,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'Kill it');
              },
              child: const Text(
                'Sim',
                style: TextStyle(fontSize: 15, color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Não',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    ).then(
      (value) {
        if (value == 'Kill it') {
          LoginService.saiFora().then((v) {
            context.goNamed('Login');
          });
        }
      },
    );
  }
}
