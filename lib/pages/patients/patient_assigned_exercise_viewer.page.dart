import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:voz_amiga/dto/activityOfExercise.dto.dart';
import 'package:voz_amiga/dto/assignedExercise.dto.dart';
import 'package:voz_amiga/infra/services/assignedExercises.service.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:voz_amiga/shared/consts.dart';

class PatientAssignedExerciseViewerPage extends StatefulWidget {
  final String idPatient;
  final String idAssignedExercise;

  const PatientAssignedExerciseViewerPage(
      {super.key, required this.idPatient, required this.idAssignedExercise});

  @override
  State<PatientAssignedExerciseViewerPage> createState() =>
      _PatientAssignedExerciseViewerPageState();
}

class _PatientAssignedExerciseViewerPageState
    extends State<PatientAssignedExerciseViewerPage> {
  Future<(dynamic, AssignedExerciseDTO?)>? _assignedExerciseFuture;

  @override
  void initState() {
    super.initState();
    _assignedExerciseFuture =
        AssignedExercisesService.getAssignedExercise(widget.idAssignedExercise);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<(dynamic, AssignedExerciseDTO?)>(
        future: _assignedExerciseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final (error, assignedExercise) = snapshot.data!;
            if (assignedExercise == null) {
              return Center(child: Text('Error: $error'));
            }
            return RefreshIndicator(
              onRefresh: () => Future.sync(() => _assignedExerciseFuture =
                  AssignedExercisesService.getAssignedExercise(
                      widget.idAssignedExercise)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        children: <Widget>[
                          Text(
                            assignedExercise.exercise!.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(
                                  DateFormat("yyyy-MM-dd'T'HH:mm:ss")
                                      .parse(assignedExercise.assignedAt)),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          )
                        ],
                      ),
                    ),
                    const Text(
                      "Atividades do exercício",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount:
                              assignedExercise.exercise!.activities.length,
                          itemBuilder: (_, index) {
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              color: Colors.deepPurpleAccent,
                              child: ListTile(
                                onTap: () {
                                  context.go(RouteNames.activityAttempts(
                                      widget.idPatient,
                                      widget.idAssignedExercise,
                                      assignedExercise
                                          .exercise!.activities[index].id));
                                },
                                title: Text(
                                  assignedExercise
                                      .exercise!.activities[index].name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white),
                                ),
                              ),
                            );
                          }),
                    )
                  ]),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildExerciseTile(
      BuildContext context, ActivityOfExerciseDTO item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      color: Colors.deepPurpleAccent,
      child: ListTile(
        onTap: () {},
        // leading: CircleAvatar(
        //   radius: 30,
        //   child: leadingImage,
        // ),
        // trailing: _trailing(context),
        title: Text(
          item.name,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        leading: null,
        // iconColor: Colors.white,
        // subtitle: Text(
        //   DateFormat('dd/MM/yyyy').format(item.assignedAt),
        //   style: const TextStyle(
        //       fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        // ),
      ),
    );
  }
}
