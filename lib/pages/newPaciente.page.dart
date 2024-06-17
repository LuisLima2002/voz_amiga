import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:voz_amiga/shared/client.dart';

class NewPacientePage extends StatefulWidget {
  const NewPacientePage({super.key});

  @override
  State<NewPacientePage> createState() => _NewPacientePageState();
}

class _NewPacientePageState extends State<NewPacientePage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataNascimentoController =
      TextEditingController();
  final TextEditingController _diagnosticoController = TextEditingController();
  final TextEditingController _contatoEmergenciaController =
      TextEditingController();
  final TextEditingController _cpfPacienteController = TextEditingController();
  final TextEditingController _nomeResponsavelController =
      TextEditingController();
  final TextEditingController _cpfResponsavelController =
      TextEditingController();

  ApiClient? client;

  @override
  void initState() {
    super.initState();
    client = Provider.of<ApiClient>(context, listen: false);
  }

  void onAdd() {}

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
              const Text(
                "Novo Paciente",
                style: TextStyle(fontSize: 50),
                textAlign: TextAlign.center,
              ),
              TextFormField(
                autofocus: true,
                controller: _nomeController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    labelText: "Nome do paciente",
                    labelStyle: TextStyle(color: Color(0xFF6D6D6D))),
              ),
              TextField(
                readOnly: true,
                controller: _dataNascimentoController,
                decoration: const InputDecoration(
                  labelText: "Data de nascimento",
                  labelStyle: TextStyle(color: Color(0xFF6D6D6D)),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    _dataNascimentoController.text =
                        DateFormat('dd/MM/yyyy').format(pickedDate);
                  }
                },
                child: const Text('Select date'),
              ),
              TextFormField(
                autofocus: true,
                controller: _diagnosticoController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    labelText: "Diagnóstico médico do paciente",
                    labelStyle: TextStyle(color: Color(0xFF6D6D6D))),
              ),
              TextFormField(
                autofocus: true,
                controller: _contatoEmergenciaController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Contato de emergência",
                  labelStyle: TextStyle(color: Color(0xFF6D6D6D)),
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  TelefoneInputFormatter()
                ],
              ),
              TextFormField(
                autofocus: true,
                controller: _cpfPacienteController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    labelText: "CPF do paciente",
                    labelStyle: TextStyle(color: Color(0xFF6D6D6D))),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  CpfInputFormatter(),
                ],
              ),
              TextFormField(
                autofocus: true,
                controller: _nomeResponsavelController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    labelText: "Nome do responsável",
                    labelStyle: TextStyle(color: Color(0xFF6D6D6D))),
              ),
              TextFormField(
                autofocus: true,
                controller: _cpfResponsavelController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    labelText: "CPF do responsável",
                    labelStyle: TextStyle(color: Color(0xFF6D6D6D))),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  CpfInputFormatter(),
                ],
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: onAdd,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Adicionar",
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _dataNascimentoController.dispose();
    _diagnosticoController.dispose();
    _contatoEmergenciaController.dispose();
    _cpfPacienteController.dispose();
    _nomeResponsavelController.dispose();
    _cpfResponsavelController.dispose();
    super.dispose();
  }
}
