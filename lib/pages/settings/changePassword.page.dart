import 'package:flutter/material.dart';
import 'package:voz_amiga/infra/services/professionals.service.dart';

class ChangePassowrdPage extends StatefulWidget {
  const ChangePassowrdPage({super.key});

  @override
  State<ChangePassowrdPage> createState() => _ChangePassowrdPageState();
}

class _ChangePassowrdPageState extends State<ChangePassowrdPage> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'changePasswordForm');
  bool _isPasswordChanged= false;
  late Map<String, TextEditingController> _controllers;
  @override
  void initState() {
    super.initState();
    _controllers = <String, TextEditingController>{
      'password': TextEditingController(),
      'newPassword': TextEditingController()
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 15),
              _passwordField,
              const SizedBox(height: 10),
              _newPasswordField,
              const SizedBox(height: 10),
              _isPasswordChanged ? const Text("Senha redefinida com sucesso") : const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  onPressed: () async {
                    await _changePassword();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Redefinir senha",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

    Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
          var response = await ProfessionalsService.changePassword(
              password: _controllers['password']!.text,
              newPassword: _controllers['newPassword']!.text);
          if (response.statusCode == 200) {
            setState(() {
              _formKey.currentState?.reset();
              _controllers.forEach((k, v) {
                _controllers[k]!.text = '';
              });
              _isPasswordChanged=true;
            });
          } else {
            throw ErrorDescription(response.body);
          }
      } catch (e) {
        _isPasswordChanged=true;
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return AlertDialog(
              alignment: Alignment.center,
              icon: const Icon(Icons.dangerous, color: Colors.red, size: 35),
              title: const Text('Ocorreu um erro durante a redefinição!'),
              titleTextStyle: const TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
              // content: Text(e.toString()),
              actions: [
                TextButton(
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
      }
    }
  }

  Widget get  _passwordField {
    return TextFormField(
      autofocus: true,
      controller: _controllers["password"],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Obrigatório!";
        }
        return null;
      },
      obscureText: true,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        labelText: "Senha atual",
        labelStyle: TextStyle(
          color: Color(0xFF6D6D6D),
        ),
      ),
    );
  }

   Widget get  _newPasswordField {
    return TextFormField(
      autofocus: true,
      controller: _controllers["newPassword"],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Obrigatório!";
        }
        return null;
      },
      obscureText: true,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        labelText: "Nova senha",
        labelStyle: TextStyle(
          color: Color(0xFF6D6D6D),
        ),
      ),
    );
  }
}
