import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voz_amiga/dto/assignedExercise.dto.dart';
import 'package:voz_amiga/infra/services/assignedExercises.service.dart';
import 'package:voz_amiga/shared/consts.dart';
import 'package:intl/intl.dart';

class AssignedExercisesPatientListPage extends StatefulWidget {
  const AssignedExercisesPatientListPage({super.key});

  @override
  State<AssignedExercisesPatientListPage> createState() =>
      _AssignedExercisesPatientListPageState();
}

class _AssignedExercisesPatientListPageState
    extends State<AssignedExercisesPatientListPage> {
  List<AssignedExerciseDTO> _exercises = List.empty();

  @override
  void initState() {
    super.initState();
    AssignedExercisesService.getExercises().then((value) => {
          setState(() {
            _exercises = value.$2.result;
          })
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _checkStatusOfExercise(AssignedExerciseDTO ae){    
    if(ae.lastAttemptAt==null) return false;
    
    switch (ae.frequencyType) {
      case 0:
          return true;
      case 1:
          if(isSameDay(ae.lastAttemptAt!, DateTime.now())) return true;
          break;
      default:
        break;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _body(context),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     context.go(RouteNames.newActivity);
      //   },
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      //   foregroundColor: Theme.of(context).colorScheme.onPrimary,
      //   clipBehavior: Clip.antiAlias,
      //   shape: const CircleBorder(),
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  Widget _body(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(() => AssignedExercisesService.getExercises(
              // filter: "",
              // page: 0,
              // pageSize: 10,
              )
          .then((value) => setState(() {
                _exercises = value.$2.result;
              }))),
      child: ListView.builder(
          itemCount: _exercises.length,
          itemBuilder: (_, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              color: Colors.deepPurpleAccent,
              child: ListTile(
                  onTap: () {
                    showDialog<String>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content:  SizedBox(
                            height: 100,
                            width: 300,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Você deseja começar o exercício? ' ,
                                  maxLines: null,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 23,
                                  ),
                                ),
                                Text(_checkStatusOfExercise(_exercises[index]) ? " Esse exercício já foi feito" : "",style: const TextStyle(fontSize: 12))
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, 'start');
                              },
                              child: const Text(
                                'Sim',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.deepPurple),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Não',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ).then(
                      (value) {
                        if (value == 'start') {
                          AssignedExercisesService.id = _exercises[index].id;
                          context.push(RouteNames.executeActivity(
                              _exercises[index].exercise.id));
                        }
                      },
                    );
                  },
                  // leading: CircleAvatar(
                  //   radius: 30,
                  //   child: leadingImage,
                  // ),
                  // trailing: _trailing(context),
                  title: Text(
                    _exercises[index].exercise.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                  leading: _checkStatusOfExercise(_exercises[index])
                      ? const Icon(Icons.done)
                      : null,
                  iconColor: Colors.white,
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _checkStatusOfExercise(_exercises[index])
                          ? const Text(
                              "Exercício Feito",
                              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                            )
                          : const SizedBox(),
                      Row(
                        children: [
                          Text(
                            _exercises[index].exercise.description,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(color: Colors.white60),
                          ),
                          Expanded(
                            child: Text(
                              DateFormat("dd/MM/yyyy").format(_exercises[index].expectedConclusion),
                              textAlign: TextAlign.end,
                              maxLines: 2,
                              style: const TextStyle(color: Colors.white60),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
            );
          }),
    );
  }
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
         date1.month == date2.month &&
         date1.day == date2.day;
}

bool isSameMonth(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
         date1.month == date2.month &&
         date1.day == date2.day;
}

bool isSameYear(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
         date1.month == date2.month &&
         date1.day == date2.day;
}
