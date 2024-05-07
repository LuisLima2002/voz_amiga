import 'package:flutter/material.dart';

class PacienteLoginForm extends StatefulWidget {
  final Function loginFunction;
  final Function changeForm;
  const PacienteLoginForm(
      {super.key, required this.loginFunction, required this.changeForm});

  @override
  State<PacienteLoginForm> createState() => _PacienteLoginFormState();
}

class _PacienteLoginFormState extends State<PacienteLoginForm> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TextFormField(
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
            labelText: "Código",
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
          "Sou profissional de saúde",
          style: TextStyle(color: Colors.black87),
        ),
      ),
    ]);
  }
}
