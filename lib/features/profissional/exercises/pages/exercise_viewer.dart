import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voz_amiga/dto/activityOfExercise.dto.dart';
import 'package:voz_amiga/dto/exercise.dto.dart';
import 'package:voz_amiga/infra/log/logger.dart';
import 'package:voz_amiga/features/profissional/exercises/services/exercises.service.dart';
import 'package:voz_amiga/features/profissional/exercises/pages/widgets/select_activity.w.dart';
import 'package:voz_amiga/shared/consts.dart';
import 'package:voz_amiga/utils/platform_utils.dart';
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
    _load();
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
      fontSize: 20,
      fontWeight: FontWeight.w600,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      // mainAxisSize: MainAxisSize.min,
      children: [
        // Container(
        //   height: MediaQuery.of(context).size.height * .3,
        //   decoration: const BoxDecoration(color: Colors.black),
        //   child: Center(
        //     child: Material(
        //       elevation: 1,
        //       child: Container(
        //         width: MediaQuery.of(context).size.height * .5,
        //         decoration: const BoxDecoration(
        //           color: Colors.black12,
        //         ),
        //         child: const Placeholder(
        //           child: Center(
        //             child: Text(
        //               '[WIP]',
        //               style: TextStyle(fontSize: 30),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.all(16),
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
                // Container(
                //   padding: const EdgeInsets.all(4),
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     border: Border.all(
                //       color: Colors.black12,
                //       width: 2,
                //     ),
                //     borderRadius: const BorderRadius.all(Radius.circular(4)),
                //   ),
                //   child: Text(
                //     _exercise!.description,
                //     style: const TextStyle(
                //       fontSize: 20,
                //     ),
                //   ),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Atividades',
                      style: titleStyle,
                    ),
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return SelectActivity(
                              exerciseId: _exercise!.id,
                              activities: _exercise!.activities
                                  .map((a) => a.id)
                                  .toList(),
                            );
                          },
                        ).then((_) {
                          _load();
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text(
                        'Add Atividade',
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        (_exercise?.activities.isNotEmpty == true)
            ? Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _exercise!.activities.length,
                  separatorBuilder: (context, i) {
                    return const SizedBox(
                      height: 0.5,
                      child: ColoredBox(
                        color: Colors.blueGrey,
                      ),
                    );
                  },
                  itemBuilder: (context, i) {
                    logger.t(i);
                    return _tile(context, _exercise!.activities[i]);
                  },
                ),
              )
            : const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    'Sem atividades relaciondas',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
        _actions,
      ],
    );
  }

  Widget _tile(BuildContext context, ActivityOfExerciseDTO item) {
    return ListTile(
      onTap: () {},
      leading: const CircleAvatar(
        radius: 30,
        child: Icon(Icons.task),
      ),
      trailing: _trailing(context, item),
      hoverColor: Colors.grey[200]!,
      contentPadding: const EdgeInsets.all(5),
      title: Text(
        item.name.capitalize(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  @pragma('vm:prefer-inline')
  Widget? _trailing(BuildContext context, ActivityOfExerciseDTO item) {
    return MediaQuery.of(context).screenType == ScreenType.tablet ||
            MediaQuery.of(context).screenType == ScreenType.desktop
        ? SizedBox(
            height: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    _deleteActivity(item.id);
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          )
        : null;
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
        ],
      ),
    );
  }

  void _load() {
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

  _deleteActivity(String activityId) async {
    var res = await showDialog<String>(
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
    );

    if (res == 'Kill it') {
      try {
        await ExercisesService.removeActivityFromService(
          exerciseId: _exercise!.id,
          activityId: activityId,
        );
        if (mounted) Toastr.success(context, 'Excluido com sucess');
        _load();
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return Column(
                children: [
                  const Text(
                    'Error',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(e.toString()),
                ],
              );
            },
          );
        }
      }
    }
  }
}
