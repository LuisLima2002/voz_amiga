import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voz_amiga/dto/exercise.dto.dart';
import 'package:voz_amiga/infra/services/exercises.service.dart';
import 'package:voz_amiga/shared/consts.dart';
import 'package:voz_amiga/utils/string_utils.dart';
import 'package:voz_amiga/utils/toastr.dart';

class ExerciseViewerPage extends StatefulWidget {
  final String id;
  const ExerciseViewerPage({
    super.key,
    required this.id,
  });

  @override
  State<ExerciseViewerPage> createState() => _ExerciseViewerPageState();
}

class _ExerciseViewerPageState extends State<ExerciseViewerPage> {
  bool _isLoading = true;
  Exercise? _exercise;
  String? _error;

  @override
  void initState() {
    super.initState();
    ExercisesService.getExercise(widget.id).then((response) {
      setState(() {
        if (response.$1 != null) {
          _error = response.$1.toString();
        } else {
          _exercise = response.$2;
        }
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error == null
            ? _details
            : Center(
                child: Text(_error ?? "Erro inesperado"),
              );
  }

  Widget get _details {
    const titleStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      // mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _exercise!.title.capitalize(),
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Descrição",
                  style: titleStyle,
                ),
                Text(
                  _exercise!.description,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                const Text(
                  'Atividades',
                  style: titleStyle,
                ),
              ],
            ),
          ),
        ),
        (_exercise?.activities?.length ?? 0) == 0
            ? const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    'Sem atividades relaciondas',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: _exercise?.activities?.length ?? 0,
                separatorBuilder: (context, i) {
                  return SizedBox(
                    height: 0.5,
                    child: ColoredBox(
                      color: Colors.grey[300]!,
                    ),
                  );
                },
                itemBuilder: (context, i) {
                  return const SizedBox();
                },
              ),
        _actions,
      ],
    );
  }

  Widget get _actions {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
      child: Row(
        // alignment: MainAxisAlignment.center,
        // buttonMinWidth: double.infinity,
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: ElevatedButton(
              onPressed: () {
                _deleteExercise();
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
        ],
      ),
    );
  }

  _deleteExercise() {
    showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const SizedBox(
            height: 100,
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tem certeza?',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 23,
                  ),
                ),
                Text(
                  'Você realmente deseja excluir esse exercício?',
                  maxLines: null,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'Kill it');
              },
              child: const Text(
                'Sim',
                style: TextStyle(fontSize: 15, color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Não',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    ).then(
      (value) {
        if (value == 'Kill it') {
          ExercisesService.delete(widget.id).then(
            (res) {
              Toastr.success(context, 'Excluido!');
              Navigator.pop(context);
            },
          ).catchError((e) {
            showDialog(
              context: context,
              builder: (context) {
                return Column(
                  children: [
                    const Text(
                      'Error',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(e),
                  ],
                );
              },
            );
          });
        }
      },
    );
  }
}
