import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voz_amiga/dto/professional.dto.dart';
import 'package:voz_amiga/infra/services/professionals.service.dart';
import 'package:voz_amiga/shared/consts.dart';

class ProfessionalViewerPage extends StatefulWidget {
  final String id;

  const ProfessionalViewerPage({super.key, required this.id});

  @override
  State<ProfessionalViewerPage> createState() => _ProfessionalViewerPageState();
}

class _ProfessionalViewerPageState extends State<ProfessionalViewerPage> {
  Future<(dynamic, ProfessionalDTO?)>? _professionalFuture;

  @override
  void initState() {
    super.initState();
    _professionalFuture = ProfessionalsService.getProfessional(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder<(dynamic, ProfessionalDTO?)>(
        future: _professionalFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final (error, professional) = snapshot.data!;
            if (professional == null) {
              return Center(child: Text('Error: $error'));
            }
            return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15),
                    _textField("Nome", professional.name),
                    const SizedBox(height: 15),
                    _textField("Código de acesso", professional.email),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                          ),
                          onPressed: () async {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    alignment: Alignment.center,
                                    icon: const Icon(Icons.dangerous,
                                        color: Colors.deepPurpleAccent,
                                        size: 35),
                                    title: const Text(
                                        'Você tem certeza que deseja resetar a senha do profissional ?'),
                                    titleTextStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                    content:
                                        const Text("Essa ação é irreversível"),
                                    actions: [
                                      TextButton(
                                        child: const Text(
                                          'Resetar',
                                          style: TextStyle(
                                            color: Colors.deepPurpleAccent,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          _resetPassword();
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
                                });
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "Resetar Senha",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    alignment: Alignment.center,
                                    icon: const Icon(Icons.dangerous,
                                        color: Colors.red, size: 35),
                                    title: const Text(
                                        'Você tem certeza que deseja deletar esse paciente ?'),
                                    titleTextStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                    content:
                                        const Text("Essa ação é irreversível"),
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
                                });
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "Deletar Profissional",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ));
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
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

  Future<void> _resetPassword() async {
    try {
      var newPassword = await ProfessionalsService.resetPassword(id: widget.id);
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
    } catch (e) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return AlertDialog(
            alignment: Alignment.center,
            icon: const Icon(Icons.dangerous, color: Colors.red, size: 35),
            title: const Text('Ocorreu um erro ao resetar a senha!'),
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

  Future<void> _delete() async {
    try {
      if (await ProfessionalsService.delete(id: widget.id) != 200) {
        throw Error();
      } else {
        if (mounted) {
          context.go(RouteNames.professionalsList);
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
