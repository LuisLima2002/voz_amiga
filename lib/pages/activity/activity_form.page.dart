import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

class ActivityFormPage extends StatefulWidget {
  const ActivityFormPage({super.key});

  @override
  State<ActivityFormPage> createState() => _ActivityFormPageState();
}

class _ActivityFormPageState extends State<ActivityFormPage> {
  late Map<String, TextEditingController> _controllers;
  final _formKey = GlobalKey<FormState>(debugLabel: 'activityForm');
  PlatformFile? _file;
  @override
  void initState() {
    super.initState();
    _controllers = <String, TextEditingController>{
      'title': TextEditingController(),
      'description': TextEditingController(),
      'data': TextEditingController(),
      'points': TextEditingController(),
    };
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
              const SizedBox(
                width: double.infinity,
                child: Text(
                  'Nova Atividade',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 15),
              // Title
              _titleFormField,
              const SizedBox(height: 10),
              // Description
              _descriptionFormField, const SizedBox(height: 10),
              _file == null ? const SizedBox(height: 1) : _selectedFile,
              // Select File
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      allowMultiple: false,
                      type: FileType.media,
                    );
                    if (result != null) {
                      setState(() {
                        _file = result.files[0];
                      });
                    }
                  },
                  label: const Text(
                    "Selecionar video",
                    style: TextStyle(fontSize: 20),
                  ),
                  icon: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.file_present_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // ActivitiesService.save();
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Salvar",
                      style: TextStyle(fontSize: 20),
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
        hintText: "Nome da atividade",
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

  Widget get _selectedFile {
    print(lookupMimeType(_file!.path.toString()));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _file!.xFile.mimeType?.startsWith('video') ?? false
                ? const Icon(
                    Icons.videocam_rounded,
                  )
                : const Icon(
                    Icons.photo_size_select_actual_rounded,
                  ),
            Text(
              _file!.name,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () async {
            await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      "Realmente deseja remover o arquivo?",
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Sim'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _file = null;
                          });
                        },
                      ),
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
                      ),
                    ],
                    alignment: Alignment.center,
                  );
                });
            // setState(() {});
          },
          icon: const Icon(Icons.close),
          style: IconButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        )
      ],
    );
  }
}
