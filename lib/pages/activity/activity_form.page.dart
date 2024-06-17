import 'package:async/async.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
// import 'package:voz_amiga/components/video_player.dart';
import 'package:voz_amiga/infra/services/activities.service.dart';

class ActivityFormPage extends StatefulWidget {
  final String? id;
  const ActivityFormPage({super.key, this.id = '0'});

  @override
  State<ActivityFormPage> createState() => _ActivityFormPageState();
}

class _ActivityFormPageState extends State<ActivityFormPage> {
  late Map<String, TextEditingController> _controllers;
  final _formKey = GlobalKey<FormState>(debugLabel: 'activityForm');
  late bool _fileError;
  PlatformFile? _file;
  @override
  void initState() {
    super.initState();
    _fileError = false;
    _controllers = <String, TextEditingController>{
      'title': TextEditingController(),
      'description': TextEditingController(),
      'points': TextEditingController(),
    };
  }

  @override
  void dispose() {
    _controllers.forEach((k, c) {
      c.dispose();
    });
    _fileError = false;
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
              const SizedBox(height: 10),
              _file == null
                  ? _fileError
                      ? const SizedBox(
                          height: 20,
                          child: Text(
                            "Precisa selecionar um arquivo",
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      : const SizedBox(height: 1)
                  : _selectedFile,
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
                        _fileError = false;
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
                    child: Icon(Icons.upload_sharp),
                  ),
                ),
              ),
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
    if (_file == null) {
      setState(() {
        _fileError = true;
      });
    }
    if (_formKey.currentState!.validate() && _file != null) {
      try {
        var res = await ActivitiesService.save(
          title: _controllers['title']!.text,
          description: _controllers['description']!.text,
          points: int.parse(_controllers['points']!.text),
          file: _file!,
        );
        if (res > 0) {
          setState(() {
            _formKey.currentState?.reset();
            _controllers.forEach((k, v) {
              _controllers[k]!.text = '';
            });
            _file = null;
            _fileError = false;
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

  Widget get _selectedFile {
    final mimeType = lookupMimeType(_file!.path.toString());
    Icon fileIcon = switch (mimeType?.split('/')[0]) {
      'video' => const Icon(Icons.video_library_outlined),
      'image' => const Icon(Icons.photo_outlined),
      _ => const Icon(Icons.question_mark_sharp)
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            fileIcon,
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
