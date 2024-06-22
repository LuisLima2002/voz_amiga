import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:voz_amiga/dto/patient.dto.dart';
import 'package:voz_amiga/infra/services/patients.service.dart';
import 'package:voz_amiga/shared/consts.dart';

class PatientViewerPage extends StatefulWidget {
  final String id;

  const PatientViewerPage({super.key,required this.id});

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
    return SingleChildScrollView(
      child: FutureBuilder<(dynamic, PatientDTO?)>(
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  _TextField("Nome",patient.name),
                  const SizedBox(height: 15),
                  _TextField("Código de acesso",patient.code),
                  const SizedBox(height: 10),
                  _TextField("Data de nascimento",DateFormat('dd/MM/yyyy').format(DateTime.parse(patient.birthdate))),
                  const SizedBox(height: 10),
                  _TextField("Contato",patient.emergencyContact),
                  const SizedBox(height: 10),
                  _TextField("CPF do paciente",patient.cpfPatient),
                  const SizedBox(height: 10),
                  _TextField("Nome do responsável",patient.nameResponsible),
                  const SizedBox(height: 10),
                  _TextField("CPF do responsável",patient.responsibleDocument),
                  const SizedBox(height: 10),
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    showDialog(context: context, builder:  (context) {
                      return AlertDialog(
                        alignment: Alignment.center,
                        icon: const Icon(Icons.dangerous, color: Colors.red, size: 35),
                        title: const Text('Você tem certeza que deseja deletar esse paciente ?'),
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
                            onPressed:  () async {
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
                    }
                  );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Deletar Paciente",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _TextField(String name,String value) {
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

  Future<void> _delete() async {
    try{
      if(await PatientsService.delete(
          id: widget.id
        )!=200){
          throw Error();
        }else{
          context.go(RouteNames.patientsList);
        }
    }catch (e){
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