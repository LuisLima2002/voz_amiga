import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voz_amiga/dto/activity.dto.dart';
import 'package:voz_amiga/infra/services/activities.service.dart';
import 'package:voz_amiga/shared/consts.dart';
import 'package:voz_amiga/utils/string_utils.dart';

class ActivityPatientListPage extends StatefulWidget {
  const ActivityPatientListPage({super.key});

  @override
  State<ActivityPatientListPage> createState() =>
      _ActivityPatientListPageState();
}

class _ActivityPatientListPageState extends State<ActivityPatientListPage> {
  List<ActivityDTO> _activities = List.empty();

  @override
  void initState() {
    super.initState();
    ActivitiesService.getActivities(
      filter: "",
      page: 0,
      pageSize: 10,
    ).then((value) => {
          setState(() {
            _activities = value.$2.result;
          })
        });
  }

  @override
  void dispose() {
    super.dispose();
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
      onRefresh: () => Future.sync(() => ActivitiesService.getActivities(
            filter: "",
            page: 0,
            pageSize: 10,
          ).then((value) => setState(() {
                _activities = value.$2.result;
              }))),
      child: ListView.builder(
          itemCount: _activities.length,
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
                        content: const SizedBox(
                          height: 100,
                          width: 300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Você deseja começar a atividade?',
                                maxLines: null,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 23,
                                ),
                              ),
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
                        context.push(
                            RouteNames.executeActivity(_activities[index].id));
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
                  _activities[index].title.capitalize(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white),
                ),
                subtitle: Text(
                  _activities[index].description.capitalize(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white60),
                ),
              ),
            );
          }),
    );
  }
}
