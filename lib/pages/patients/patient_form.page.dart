import 'package:brasil_fields/brasil_fields.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
// import 'package:voz_amiga/components/video_player.dart';
import 'package:voz_amiga/infra/services/activities.service.dart';
import 'package:voz_amiga/infra/services/patients.service.dart';

class PatientFormPage extends StatefulWidget {
  final String? id;
  const PatientFormPage({super.key, this.id = '0'});

  @override
  State<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends State<PatientFormPage> {
  late Map<String, TextEditingController> _controllers;
  final _formKey = GlobalKey<FormState>(debugLabel: 'patientForm');
  @override
  void initState() {
    super.initState();
    _controllers = <String, TextEditingController>{
      'name': TextEditingController(),
      'birthdate': TextEditingController(),
      'emergencyContact': TextEditingController(),
      'cpfPatient': TextEditingController(),
      'nameResponsable': TextEditingController(),
      'responsibleDocument': TextEditingController(),
    };
    for (var key in _controllers.keys) {
      _controllers[key]!.text="12/12/2000";
    }
    _controllers['cpfPatient']!.text="495.636.948-48";
    _controllers['emergencyContact']!.text="(18) 9971-7185";
    _controllers['responsibleDocument']!.text="495.636.948-48";
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
              ..._birthdateFormField,
              const SizedBox(height: 10),
              _emergencyContactFormField,
              const SizedBox(height: 10),
              _cpfPatientFormField,
              const SizedBox(height: 10),
              _nameResponsableFormField,
              const SizedBox(height: 10),
              _responsibleDocumentFormField,
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
        var res = await PatientsService.save(
          name: _controllers['name']!.text,
          birthdate: _controllers['birthdate']!.text,
          emergencyContact: _controllers['emergencyContact']!.text,
          cpfPatient: _controllers['cpfPatient']!.text,
          nameResponsable: _controllers['nameResponsable']!.text,
          responsibleDocument: _controllers['responsibleDocument']!.text,

        );
        if (res > 0) {
          setState(() {
            _formKey.currentState?.reset();
            _controllers.forEach((k, v) {
              _controllers[k]!.text = '';
            });
          });
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
        labelText: "Nome do Paciente",
        labelStyle: TextStyle(color: Color(0xFF6D6D6D)),
      ),
    );
  }

    List<Widget> get _birthdateFormField {
    return [TextFormField(
                readOnly: true,
                validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Obrigatório!";
                    }
                    return null;
                  },
                controller: _controllers['birthdate'],
                decoration: const InputDecoration(
                  labelText: "Data de nascimento",
                  labelStyle: TextStyle(color: Color(0xFF6D6D6D)),
                ),
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    _controllers['birthdate']!.text =
                        DateFormat('dd/MM/yyyy').format(pickedDate);
                  }
                },
                child: const Text('Select date'),
              )];
  }

    Widget get _emergencyContactFormField {
    return TextFormField(
                autofocus: true,
                validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Obrigatório!";
                    }
                    if(value.length!=14){
                      return "Número inválido";
                    }
                    return null;
                  },
                controller: _controllers['emergencyContact'],
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Contato de emergência",
                  labelStyle: TextStyle(color: Color(0xFF6D6D6D)),
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  TelefoneInputFormatter()
                ],
              );
  }

  Widget get _cpfPatientFormField {
    return TextFormField(
                autofocus: true,
                validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Obrigatório!";
                    }
                    if(!UtilBrasilFields.isCPFValido(value)){
                      return "CPF inválido";
                    }
                    return null;
                  },
                controller: _controllers['cpfPatient'],
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    labelText: "CPF do paciente",
                    labelStyle: TextStyle(color: Color(0xFF6D6D6D))),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  CpfInputFormatter(),
                ],
              );
  }

 Widget get _nameResponsableFormField {
    return TextFormField(
      autofocus: true,
      controller: _controllers['nameResponsable'],
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
        labelText: "Nome do Responsável",
        labelStyle: TextStyle(color: Color(0xFF6D6D6D)),
      ),
    );
  }

    Widget get _responsibleDocumentFormField {
    return TextFormField(
                autofocus: true,
                validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Obrigatório!";
                    }
                    if(!UtilBrasilFields.isCPFValido(value)){
                      return "CPF inválido";
                    }
                    return null;
                  },
                controller: _controllers['responsibleDocument'],
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    labelText: "CPF do responsável",
                    labelStyle: TextStyle(color: Color(0xFF6D6D6D))),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  CpfInputFormatter(),
                ],
              );
  }
}
