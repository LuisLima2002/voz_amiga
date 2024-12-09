import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voz_amiga/features/profissional/exercises/models/assignment_data.dart';

class AssignExerviseForm extends StatefulWidget {
  final VoidCallback onCancel;
  final void Function(AssignmentData) onAssign;

  const AssignExerviseForm({
    super.key,
    required this.onCancel,
    required this.onAssign,
  });

  @override
  State<AssignExerviseForm> createState() => _AssignExerviseFormState();
}

class _AssignExerviseFormState extends State<AssignExerviseForm> {
  late String? _frequencyType;
  late Map<String, TextEditingController> _controllers;
  final _dateFormater = DateFormat('dd/MM/yyyy');
  final _formKey = GlobalKey<FormState>(debugLabel: 'assignForm');
  @override
  void initState() {
    super.initState();
    _frequencyType = 'Once';
    _controllers = {
      'frequency': TextEditingController(text: '1'),
      'expectedConclusion': TextEditingController(),
    };
  }

  @override
  void dispose() {
    _controllers.forEach((k, v) {
      v.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      child: _body(),
    );
  }

  @pragma('vm:prefer-inline')
  Widget _body() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: [
                  const Text(
                    'Defina os paramêtros para realizar o exercício!',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _frequencyTypeSelect,
                  const SizedBox(height: 10),
                  _frequencyField,
                  const SizedBox(height: 10),
                  _dateField
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.onCancel();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 146, 48, 31),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  ElevatedButton(
                    onPressed: () {
                      _finished();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'Atribur',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  get _frequencyTypeSelect {
    return DropdownButtonFormField<String>(
      autofocus: false,
      value: _frequencyType,
      items: const [
        DropdownMenuItem(
          value: 'Once',
          child: Text("Nº de Vezes"),
        ),
        DropdownMenuItem(
          value: 'Daily',
          child: Text("Diária"),
        ),
        DropdownMenuItem(
          value: 'Monthly',
          child: Text("Mensal"),
        ),
        DropdownMenuItem(
          value: 'Annually',
          child: Text("Anual"),
        ),
      ],
      validator: (value) {
        if (value == null) {
          return "Obrigatório!";
        }
        return null;
      },
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 5),
        hintText: "",
        labelText: "Tipo de frequencia",
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
      onChanged: (String? value) {
        setState(() {
          _frequencyType = value ?? 'Once';
        });
      },
    );
  }

  get _dateField {
    return TextFormField(
      autofocus: false,
      readOnly: true,
      controller: _controllers['expectedConclusion'],
      onTap: () {
        showDatePicker(
          context: context,
          firstDate: DateTime.timestamp().add(
            const Duration(days: 1),
          ),
          lastDate: DateTime.timestamp().add(
            const Duration(days: 3650),
          ),
        ).then((date) {
          if (date != null) {
            _controllers['expectedConclusion']!.text =
                _dateFormater.format(date);
          }
        }).catchError((_) {});
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Obrigatório!";
        }
        final date = _dateFormater.tryParse(value);
        if (date == null) {
          return "Precisa ser uma data!";
        }
        if (date.compareTo(DateTime.now()) < 0) {
          return "Impossível terminar no passado";
        }
        return null;
      },
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 4),
        hintText: "Até quando deve ser realizada",
        labelText: "Data de término",
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

  get _frequencyField {
    return TextFormField(
      autofocus: false,
      controller: _controllers['frequency'],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Obrigatório!";
        }
        final freq = int.tryParse(value, radix: 10);
        if (freq == null) {
          return "Apenas números";
        }
        if (freq < 1) {
          return "Mín. uma vez";
        }
        return null;
      },
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 4),
        hintText: "Quantas vezes deve ser repetido!",
        labelText: "Frequência",
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

  void _finished() {
    if (_formKey.currentState!.validate()) {
      final ret = AssignmentData(
        frequency: int.parse(
          _controllers['frequency']!.text,
        ),
        frequencyType: _frequencyType!,
        expectedConclusion: _dateFormater.parse(
          _controllers['expectedConclusion']!.text,
        ),
      );

      widget.onAssign(ret);
    }
  }
}
