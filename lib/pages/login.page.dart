import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voz_amiga/components/mainLogin.form.dart';
import 'package:voz_amiga/components/pacienteLogin.form.dart';
import 'package:voz_amiga/shared/client.dart';

class LoginPage extends StatefulWidget {
  final Function changeLogState;

  const LoginPage({super.key, required this.changeLogState});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  ClientHttp? client;
  Widget? formToShow;

  @override
  void initState() {
    super.initState();
    client = Provider.of<ClientHttp>(context, listen: false);
    formToShow =
        PacienteLoginForm(loginFunction: login, changeForm: changeForm);
  }

  void changeForm() {
    setState(() {
      if (formToShow is PacienteLoginForm) {
        formToShow = MainLoginForm(
          loginFunction: login,
          changeForm: changeForm,
        );
      } else {
        formToShow =
            PacienteLoginForm(loginFunction: login, changeForm: changeForm);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "images/AlaskaCode.png",
                    fit: BoxFit.cover,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Voz Amiga",
                style: TextStyle(fontSize: 50),
                textAlign: TextAlign.center,
              ),
              const Text(
                "ALASKA",
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              formToShow!
            ],
          ),
        ),
      ),
    );
  }

  void login() {
    widget.changeLogState(true);
  }
}
