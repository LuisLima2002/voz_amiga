import 'package:flutter/material.dart';

class MainLoginForm extends StatefulWidget {
  final Function loginFunction;
  final Function changeForm;

  const MainLoginForm(
      {super.key, required this.loginFunction, required this.changeForm});

  @override
  State<MainLoginForm> createState() => _MainLoginFormState();
}

class _MainLoginFormState extends State<MainLoginForm> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TextFormField(
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
            labelText: "Email",
            labelStyle: TextStyle(color: Color(0xFF6D6D6D))),
      ),
      TextFormField(
        autofocus: true,
        obscureText: true,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
            labelText: "Senha",
            labelStyle: TextStyle(color: Color(0xFF6D6D6D))),
      ),
      const SizedBox(
        height: 50,
      ),
      ElevatedButton(
        onPressed: () {
          widget.loginFunction();
        },
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            "Entrar",
            style: TextStyle(fontSize: 25),
          ),
        ),
      ),
      const SizedBox(height: 20),
      TextButton(
        onPressed: () {
          widget.changeForm();
        },
        child: const Text(
          "Sou paciente",
          style: TextStyle(color: Colors.black87),
        ),
      ),
    ]);
  }
}
