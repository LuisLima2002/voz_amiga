import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:voz_amiga/dto/assignedExercise.dto.dart';
import 'package:voz_amiga/dto/patient.dto.dart';
import 'package:voz_amiga/infra/services/patients.service.dart';
import 'package:voz_amiga/infra/services/assignedExercises.service.dart';
import 'package:voz_amiga/shared/consts.dart';
import 'dart:async';

class PatientViewerPage extends StatefulWidget {
  final String id;

  const PatientViewerPage({super.key, required this.id});

  @override
  State<PatientViewerPage> createState() => _PatientViewerPageState();
}

class _PatientViewerPageState extends State<PatientViewerPage> {
  Future<(dynamic, PatientDTO?)>? _patientFuture;

  @override
  void initState() {
    super.initState();
    _patientFuture = PatientsService.getPatient(widget.id);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  final _numberOfPostsPerRequest = 10;

  Future<void> _fetchPage(int pageKey) async {
    try {
      final (error, assignedExercises) =
          await AssignedExercisesService.getExercisesFromPatient(
              widget.id, null, pageKey, _numberOfPostsPerRequest, null);
      final isLastPage = assignedExercises.total <=
          assignedExercises.itensPerPage * assignedExercises.page;
      if (error != null) {
        _pagingController.error = error;
      } else {
        if (isLastPage) {
          _pagingController.appendLastPage(assignedExercises.result);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(assignedExercises.result, nextPageKey);
        }
      }
    } catch (e) {
      print("error --> $e");
      _pagingController.error = e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {
              context.go(RouteNames.patientFrequencyReport(widget.id));
            },
            icon: const Icon(Icons.calendar_today),
            color: Theme.of(context).colorScheme.onPrimary,
            iconSize: 26.0, // Increases the size of the icon
            splashRadius: 36.0, // Makes the interactive area larger
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primary),
              shape: MaterialStateProperty.all(const CircleBorder()),
              padding: MaterialStateProperty.all(const EdgeInsets.all(14.0)),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          IconButton(
            onPressed: () {
              context.go(RouteNames.editPatient(widget.id));
            },
            icon: const Icon(Icons.edit),
            color: Theme.of(context).colorScheme.onPrimary,
            iconSize: 26.0, // Increases the size of the icon
            splashRadius: 36.0, // Makes the interactive area larger
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primary),
              shape: MaterialStateProperty.all(const CircleBorder()),
              padding: MaterialStateProperty.all(const EdgeInsets.all(14.0)),
            ),
          ),
          // FloatingActionButton(
          //   onPressed: () {},
          //   backgroundColor: Theme.of(context).colorScheme.primary,
          //   foregroundColor: Theme.of(context).colorScheme.onPrimary,
          //   clipBehavior: Clip.antiAlias,
          //   shape: const CircleBorder(),
          //   child: const Icon(Icons.calendar_today),
          // ),
        ],
      ),
      body: FutureBuilder<(dynamic, PatientDTO?)>(
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
            return RefreshIndicator(
              onRefresh: () => Future.sync(() => _pagingController.refresh()),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        children: <Widget>[
                          Text(
                            patient.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(
                                  DateFormat("yyyy-MM-dd'T'HH:mm:ss")
                                      .parse(patient.birthdate)),
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
                      "Atividades Atribuidas",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    Expanded(
                      child: PagedListView<int, AssignedExerciseDTO>.separated(
                        // scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 0.2);
                        },
                        pagingController: _pagingController,
                        builderDelegate:
                            PagedChildBuilderDelegate<AssignedExerciseDTO>(
                          itemBuilder: _buildExerciseTile,
                          noItemsFoundIndicatorBuilder: (context) {
                            return const Center(
                              child: Text(
                                "Não há nenhum exercício atribuído",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 55, 170, 223),
                                ),
                              ),
                            );
                          },
                          firstPageErrorIndicatorBuilder: (context) {
                            return const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.dangerous,
                                  color: Color(0xFF770000),
                                  size: 35,
                                ),
                                Text(
                                  "Algo deu errado!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Color(0xFF770000),
                                  ),
                                ),
                                Text(
                                  "Tenta mais tarde",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF770000),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
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
      BuildContext context, AssignedExerciseDTO item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      color: Colors.deepPurpleAccent,
      child: ListTile(
        onTap: () {
          context.go(RouteNames.assignedExercise(widget.id, item.id));
        },
        // leading: CircleAvatar(
        //   radius: 30,
        //   child: leadingImage,
        // ),
        // trailing: _trailing(context),
        title: Text(
          item.exercise!.title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        leading: null,
        iconColor: Colors.white,
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            item.lastAttemptAt != null
                ? const Text(
                    "Exercício Feito",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )
                : const SizedBox(),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    item.exercise!.description,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(color: Colors.white60),
                  ),
                ),
                Expanded(
                  child: Text(
                    DateFormat("dd/MM/yyyy").format(item.expectedConclusion),
                    textAlign: TextAlign.end,
                    style: const TextStyle(color: Colors.white60),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  final PagingController<int, AssignedExerciseDTO> _pagingController =
      PagingController(firstPageKey: 0);

// Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 15),
//                   _TextField("Nome", patient.name),
//                   const SizedBox(height: 15),
//                   _TextField("Código de acesso", patient.code),
//                   const SizedBox(height: 10),
//                   _TextField(
//                       "Data de nascimento",
//                       DateFormat('dd/MM/yyyy')
//                           .format(DateTime.parse(patient.birthdate))),
//                   const SizedBox(height: 10),
//                   _TextField("Contato", patient.emergencyContact),
//                   const SizedBox(height: 10),
//                   _TextField("CPF do paciente", patient.cpfPatient),
//                   const SizedBox(height: 10),
//                   _TextField("Nome do responsável", patient.nameResponsible),
//                   const SizedBox(height: 10),
//                   _TextField("CPF do responsável", patient.responsibleDocument),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                     ),
//                     onPressed: () async {
//                       showDialog(
//                           context: context,
//                           builder: (context) {
//                             return AlertDialog(
//                               alignment: Alignment.center,
//                               icon: const Icon(Icons.dangerous,
//                                   color: Colors.red, size: 35),
//                               title: const Text(
//                                   'Você tem certeza que deseja deletar esse paciente ?'),
//                               titleTextStyle: const TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 20,
//                               ),
//                               content: const Text("Essa ação é irreversível"),
//                               actions: [
//                                 TextButton(
//                                   child: const Text(
//                                     'Deletar',
//                                     style: TextStyle(
//                                       color: Colors.red,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   onPressed: () async {
//                                     Navigator.of(context).pop();
//                                     await _delete();
//                                   },
//                                 ),
//                                 TextButton(
//                                   child: const Text(
//                                     'Cancelar',
//                                     style: TextStyle(
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   onPressed: () {
//                                     Navigator.of(context).pop();
//                                   },
//                                 )
//                               ],
//                             );
//                           });
//                     },
//                     child: const Padding(
//                       padding: EdgeInsets.all(8),
//                       child: Text(
//                         "Deletar Paciente",
//                         style: TextStyle(fontSize: 20, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );

  Widget _TextField(String name, String value) {
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
    try {
      if (await PatientsService.delete(id: widget.id) != 200) {
        throw Error();
      } else {
        context.go(RouteNames.patientsList);
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
