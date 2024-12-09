import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:voz_amiga/features/profissional/exercises/services/exercises.service.dart';
import 'package:voz_amiga/shared/consts.dart';
import 'package:voz_amiga/utils/toastr.dart';

class ExerciseFormPage extends StatefulWidget {
  final String? id;
  const ExerciseFormPage({super.key, this.id = 'new'});

  @override
  State<ExerciseFormPage> createState() => _ExerciseFormPageState();
}

class _ExerciseFormPageState extends State<ExerciseFormPage> {
  late Map<String, TextEditingController> _controllers;
  final _formKey = GlobalKey<FormState>(debugLabel: 'exerciseForm');

  @override
  void initState() {
    super.initState();
    _controllers = <String, TextEditingController>{
      'title': TextEditingController(),
      'description': TextEditingController(),
      'points': TextEditingController(),
    };
    if (widget.id != 'new') {
      ExercisesService.getExercise(widget.id!).then((result) {
        if (result.$1 != null) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(result.$1),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text('Ok'),
                  ),
                ],
              );
            },
          );
        } else if (result.$2 != null) {
          final activity = result.$2!;
          setState(() {
            _controllers = <String, TextEditingController>{
              'title': TextEditingController(text: activity.title),
              'description': TextEditingController(text: activity.description),
              'points': TextEditingController(text: activity.points.toString()),
            };
          });
        }
      });
    } else {
      _controllers = <String, TextEditingController>{
        'title': TextEditingController(),
        'description': TextEditingController(),
        'points': TextEditingController(),
      };
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
              // Title
              _titleFormField,
              const SizedBox(height: 10),
              // Points
              _pointsFormField,
              const SizedBox(height: 10),
              // Description
              _descriptionFormField,
              // confirm
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
        var res = widget.id == 'new'
            ? await ExercisesService.save(
                title: _controllers['title']!.text,
                description: _controllers['description']!.text,
                points: int.parse(_controllers['points']!.text),
              )
            : await ExercisesService.update(
                widget.id!,
                title: _controllers['title']!.text,
                description: _controllers['description']!.text,
                points: int.parse(_controllers['points']!.text),
              );
        if (mounted) {
          Toastr.success(context, 'Salvo!');
          context.go(RouteNames.exercise(res));
        }
        setState(() {
          _formKey.currentState?.reset();
          _controllers.forEach((k, v) {
            _controllers[k]!.text = '';
          });
        });
      } catch (e) {
        if (mounted) {
          showDialog(
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
  }

  Widget get _titleFormField {
    return TextFormField(
      autofocus: true,
      controller: _controllers['title'],
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
        contentPadding: EdgeInsets.symmetric(horizontal: 4),
        hintText: "Título do exercício",
        labelText: "Título",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 15,
        ),
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget get _descriptionFormField {
    return TextFormField(
      autofocus: true,
      controller: _controllers['description'],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Obrigatório!";
        }
        if (value.length < 3) {
          return "Ao menos 3 caracteres";
        }
        if (value.length > 150) {
          return "No máximo 150 caracteres";
        }
        return null;
      },
      keyboardType: TextInputType.text,
      minLines: 1,
      maxLines: null,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.only(
          left: 4,
          right: 4,
          bottom: 4,
        ),
        labelText: "Descrição",
        hintText: "Uma breve descrição do que se trata a atividade!",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 15,
        ),
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget get _pointsFormField {
    return TextFormField(
      autofocus: true,
      controller: _controllers['points'],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Obrigatório!";
        }
        final pts = int.tryParse(value, radix: 10);
        if (pts == null) {
          return "Número inválido";
        }
        if (pts <= 0) {
          return "Maior que zero";
        }

        return null;
      },
      keyboardType: const TextInputType.numberWithOptions(),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      minLines: 1,
      maxLines: 1,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.only(
          left: 4,
          right: 4,
          bottom: 4,
        ),
        labelText: "Pontos por conclusão",
        hintText: "O número de acordo com a dificuldade",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 15,
        ),
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
      ),
    );
  }
}
