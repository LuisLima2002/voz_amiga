import 'package:flutter/material.dart';
import 'package:voz_amiga/dto/professional.dto.dart';
import 'package:voz_amiga/infra/services/professionals.service.dart';

class ProfessionalFormPage extends StatefulWidget {
  final String? id;
  const ProfessionalFormPage({super.key, this.id = '0'});

  @override
  State<ProfessionalFormPage> createState() => _ProfessionalFormPageState();
}

class _ProfessionalFormPageState extends State<ProfessionalFormPage> {
  final _emailRegex = RegExp(
    r"^[a-zA-Z](?:\.?[\w]+){1,}@(?:[a-zA-Z]{2,3}\.){0,2}(?:[\w]{3,20})(?:\.[a-zA-Z]{2,5}){1,2}",
  );

  ProfessionalDTO? _professionalFuture;
  late Map<String, TextEditingController> _controllers;
  final _formKey = GlobalKey<FormState>(debugLabel: 'professionalForm');
  @override
  void initState() {
    super.initState();
    _controllers = <String, TextEditingController>{
      'name': TextEditingController(),
      'email': TextEditingController()
    };
    if (widget.id != '') {
      loadProfessional();
    }
  }

  void loadProfessional() async {
    _professionalFuture =
        (await ProfessionalsService.getProfessional(widget.id!)).$2;
    if (_professionalFuture != null) {
      _controllers['name']!.text = _professionalFuture!.name;
      _controllers['email']!.text = _professionalFuture!.email;
    }
  }

  @override
  void dispose() {
    _controllers.forEach((k, c) {
      c.dispose();
    });
    super.dispose();
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
              _nameFormField,
              const SizedBox(height: 10),
              _emailFormFiel,
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  onPressed: () async {
                    await _save();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Salvar",
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

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_professionalFuture != null) {
          await ProfessionalsService.update(
              patient: ProfessionalDTO(
                  id: _professionalFuture!.id,
                  name: _controllers['name']!.text,
                  email: _controllers['email']!.text));
        } else {
          var newPassword = await ProfessionalsService.save(
              name: _controllers['name']!.text,
              email: _controllers['email']!.text);
          if (newPassword != null) {
            showDialog(
              // ignore: use_build_context_synchronously
              context: context,
              builder: (context) {
                return AlertDialog(
                  alignment: Alignment.center,
                  icon: const Icon(Icons.info,
                      color: Colors.deepPurpleAccent, size: 35),
                  title: const Text('Esta é a nova senha do Profissional'),
                  titleTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  content: Text(newPassword),
                  actions: [
                    TextButton(
                      child: const Text(
                        'Ok',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              },
            );
            setState(() {
              _formKey.currentState?.reset();
              _controllers.forEach((k, v) {
                _controllers[k]!.text = '';
              });
            });
          } else {
            throw Error();
          }
        }
      } catch (e) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return AlertDialog(
              alignment: Alignment.center,
              icon: const Icon(Icons.dangerous, color: Colors.red, size: 35),
              title: const Text('Ocorreu um erro durante o salvamento!'),
              titleTextStyle: const TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
              content: Text(e.toString()),
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

  Widget get _nameFormField {
    return TextFormField(
      autofocus: true,
      controller: _controllers['name'],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Obrigatório!";
        }
        if (value.length < 3) {
          return "Ao menos 3 caracteres";
        }
        if (value.length > 50) {
          return "No máximo caracteres";
        }
        return null;
      },
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        labelText: "Nome do Profissional",
        labelStyle: TextStyle(color: Color(0xFF6D6D6D)),
      ),
    );
  }

  Widget get _emailFormFiel {
    return TextFormField(
      autofocus: true,
      controller: _controllers['email'],
      validator: (value) {
        if (value == null || !_emailRegex.hasMatch(value)) {
          return " E-mail inválido";
        }
        return null;
      },
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        labelText: "E-mail",
        labelStyle: TextStyle(color: Color(0xFF6D6D6D)),
      ),
    );
  }
}
