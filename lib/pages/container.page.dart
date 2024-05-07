import 'package:flutter/material.dart';
import 'package:voz_amiga/pages/login.page.dart';
import 'package:voz_amiga/pages/newPaciente.page.dart';

class ContainerPage extends StatefulWidget {
  const ContainerPage({super.key});

  @override
  State<ContainerPage> createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> {
  bool isLogged = false;

  void changeLogState(isLogged) {
    setState(() {
      this.isLogged = isLogged;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLogged
        ? const NewPacientePage()
        : LoginPage(changeLogState: changeLogState);
  }
}
