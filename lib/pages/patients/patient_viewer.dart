import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:voz_amiga/dto/patient.dto.dart';
import 'package:voz_amiga/infra/log/logger.dart';
import 'package:voz_amiga/infra/services/patients.service.dart';
import 'package:voz_amiga/shared/consts.dart';

class PatientViewerPage extends StatefulWidget {
  final String id;

  const PatientViewerPage({super.key, required this.id});

  @override
  State<PatientViewerPage> createState() => _PatientViewerPageState();
}

class _PatientViewerPageState extends State<PatientViewerPage> {
  Future<(dynamic, PatientDTO?)>? _patientFuture;

  @override
  void initState() {
    super.initState();
    _patientFuture = PatientsService.getPatient(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(dynamic, PatientDTO?)>(
      future: _patientFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final (error, patient) = snapshot.data!;
          if (patient == null) {
            return Center(child: Text('Error: $error'));
          }
          return Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  _textField("Nome", patient.name),
                  const SizedBox(height: 15),
                  _textField("Código de acesso", patient.code),
                  const SizedBox(height: 10),
                  _textField(
                      "Data de nascimento",
                      DateFormat('dd/MM/yyyy')
                          .format(DateTime.parse(patient.birthdate))),
                  const SizedBox(height: 10),
                  _textField("Contato", patient.emergencyContact),
                  const SizedBox(height: 10),
                  _textField("CPF do paciente", patient.cpfPatient),
                  const SizedBox(height: 10),
                  _textField("Nome do responsável", patient.nameResponsible),
                  const SizedBox(height: 10),
                  _textField(
                    "CPF do responsável",
                    patient.responsibleDocument,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            bottomNavigationBar: _actions,
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _textField(String name, String value) {
    return TextFormField(
      initialValue: value,
      autofocus: true,
      readOnly: true,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: name,
        labelStyle: const TextStyle(color: Color(0xFF6D6D6D)),
      ),
    );
  }

  Widget get _actions {
    final buttons = [
      Flexible(
        fit: FlexFit.tight,
        child: ElevatedButton(
          onPressed: () {
            _handleDelete();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: const ContinuousRectangleBorder(),
          ),
          child: const Column(
            children: [
              Icon(Icons.delete_forever),
              Text('Excluir'),
            ],
          ),
        ),
      ),
      Flexible(
        fit: FlexFit.tight,
        child: ElevatedButton(
          onPressed: () {
            context.push(RouteNames.assignExercise(widget.id));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: const ContinuousRectangleBorder(),
          ),
          child: const Column(
            children: [
              Icon(Icons.assignment_outlined),
              Text('Atividades'),
            ],
          ),
        ),
      ),
      Flexible(
        fit: FlexFit.tight,
        child: ElevatedButton(
          onPressed: () {
            context.push(RouteNames.patientReports(widget.id));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: const ContinuousRectangleBorder(),
          ),
          child: const Column(
            children: [
              Icon(Icons.assessment),
              Text('Relatórios'),
            ],
          ),
        ),
      ),
      Flexible(
        fit: FlexFit.tight,
        child: ElevatedButton(
          onPressed: () {
            context.push(RouteNames.assignExercise(widget.id));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: const ContinuousRectangleBorder(),
          ),
          child: const Column(
            children: [
              Icon(Icons.person_add_alt_1),
              Text('Atribuir'),
            ],
          ),
        ),
      ),
      Flexible(
        child: ElevatedButton(
          onPressed: () {
            context.push(RouteNames.editExercise(widget.id));
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: const Size.fromHeight(20),
            backgroundColor: Colors.transparent,
            shape: const ContinuousRectangleBorder(),
          ),
          child: const Column(
            children: [
              Icon(Icons.edit),
              Text('Editar'),
            ],
          ),
        ),
      )
    ];
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    logger.i(isPortrait);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isPortrait ? const Color(0XFFDDDDDD) : const Color(0xFFEEEEEE),
      ),
      child: SizedBox(
        height: 50,
        child: Row(
          children: buttons,
        ),
      ),
    );
  }

  Future<void> _handleDelete() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          alignment: Alignment.center,
          icon: const Icon(Icons.dangerous, color: Colors.red, size: 35),
          title:
              const Text('Você tem certeza que deseja deletar esse paciente ?'),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
          content: const Text("Essa ação é irreversível"),
          actions: [
            TextButton(
              child: const Text(
                'Deletar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _delete();
              },
            ),
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.black,
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

  _delete() async {
    try {
      if (await PatientsService.delete(id: widget.id) != 200) {
        throw Error();
      } else {
        if (mounted) {
          context.go(RouteNames.patientsList);
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
            title: const Text('Ocorreu um erro ao deletar o paciente!'),
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
