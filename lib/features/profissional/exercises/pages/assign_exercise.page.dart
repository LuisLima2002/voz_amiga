import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:voz_amiga/features/profissional/exercises/models/assignment_data.dart';
import 'package:voz_amiga/features/profissional/exercises/models/patient.model.dart';
import 'package:voz_amiga/features/profissional/exercises/pages/widgets/assign_form.w.dart';
import 'package:voz_amiga/features/profissional/exercises/services/assign_exercise.service.dart';
import 'package:voz_amiga/infra/log/logger.dart';
import 'package:voz_amiga/utils/toastr.dart';

class AssignExercisePage extends StatefulWidget {
  final String exerciseId;
  const AssignExercisePage({
    super.key,
    required this.exerciseId,
  });

  @override
  State<AssignExercisePage> createState() => _AssignExercisePageState();
}

class _AssignExercisePageState extends State<AssignExercisePage> {
  final _filterController = TextEditingController();
  // String _filterByState = "";
  final _checked = <String, bool>{};
  Timer? _debounce;
  final _numberOfPostsPerRequest = 10;

  final _pagingController = PagingController<int, Patient>(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
    _filterController.addListener(() {
      if (_debounce?.isActive ?? false) {
        _debounce?.cancel();
      }
      _debounce = Timer(const Duration(milliseconds: 500), () {
        Future.sync(() => _pagingController.refresh());
      });
    });
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _filterController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    logger.d('fetch');
    try {
      final (error, patients) = await AssignExerciseService.getPatients(
        exerciseId: widget.exerciseId,
        filter: _filterController.text,
        page: pageKey,
        pageSize: _numberOfPostsPerRequest,
      );

      if (patients != null) {
        final isLastPage =
            patients.total <= (patients.itensPerPage * patients.page);
        if (error != null) {
          _pagingController.error = error;
        } else {
          if (isLastPage) {
            _pagingController.appendLastPage(patients.result);
          } else {
            final nextPageKey = pageKey + 1;
            _pagingController.appendPage(patients.result, nextPageKey);
          }
        }
      } else if (error != null) {
        _pagingController.error = error;
      }
    } catch (e) {
      logger.e(e);
      _pagingController.error = e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _body(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onAssign();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        clipBehavior: Clip.antiAlias,
        shape: const CircleBorder(),
        child: const Icon(Icons.assignment_add),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: <Widget>[
                Flexible(
                  // flex: 8,
                  child: TextFormField(
                    controller: _filterController,
                    decoration: const InputDecoration(
                      hintText: 'Busque por nome',
                    ),
                  ),
                ),
                // Flexible(
                //   flex: 2,
                //   child: DropdownButtonFormField(
                //     decoration: const InputDecoration(
                //         contentPadding: EdgeInsets.symmetric(horizontal: 5)),
                //     hint: const Text("Estado"),
                //     items: {
                //       'Atribuído',
                //       'Concluído',
                //       'Finalizado',
                //     }
                //         .map(
                //           (String unit) => DropdownMenuItem<String>(
                //             value: unit,
                //             child: Text(unit),
                //           ),
                //         )
                //         .toList(),
                //     onChanged: (value) => setState(() {
                //       switch (value) {
                //         case "Nome":
                //           _filterByState = "name";
                //           break;
                //         case "Nome do responsável":
                //           _filterByState = "nameResponsible";
                //           break;
                //         case "Data de nascimento":
                //           _filterByState = "birthdate";
                //           break;
                //         default:
                //           _filterByState = "";
                //           break;
                //       }
                //       PatientsService.pagingController.refresh();
                //     }),
                //   ),
                // )
              ],
            ),
          ),
          PagedListView<int, Patient>.separated(
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return SizedBox(
                height: 0.5,
                child: ColoredBox(
                  color: Colors.grey[300]!,
                ),
              );
            },
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Patient>(
              itemBuilder: _tile,
              noItemsFoundIndicatorBuilder: (context) {
                return const Center(
                  child: Text(
                    "Não há nenhum Paciente",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 55, 170, 223),
                    ),
                  ),
                );
              },
              firstPageErrorIndicatorBuilder: (context) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.dangerous,
                      color: Color(0xFF770000),
                      size: 35,
                    ),
                    const Text(
                      "Algo deu errado!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF770000),
                      ),
                    ),
                    const Text(
                      "Tenta mais tarde",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF770000),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _pagingController.refresh();
                      },
                      icon: const Icon(Icons.replay_outlined),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, Patient item, int index) {
    logger.d('asd');
    return CheckboxListTile(
      onChanged: (v) {
        setState(() {
          _checked[item.id] = v ?? false;
        });
      },
      value: _checked[item.id] ?? false,
      title: Text(
        item.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  void _onAssign() {
    final patients = _selectedPatiens;
    if (patients.isEmpty) {
      _warnNoPatientsSelected();
    } else {
      showDialog<AssignmentData>(
        context: context,
        builder: (modalContext) {
          return AssignExerviseForm(
            exerciseId: widget.exerciseId,
            patients: patients,
            onAssign: (data) {
              modalContext.pop(data);
            },
            onCancel: () {
              modalContext.pop(null);
            },
          );
        },
      ).then((result) async {
        if (result != null) {
          result.patientsIds = patients;
          final error = await AssignExerciseService.assign(
            widget.exerciseId,
            result,
          );
          if (error == null) {
            if (mounted) {
              Toastr.success(context, 'Salvo com sucesso!');
              _pagingController.refresh();
            }
          }
        }
      });
    }
  }

  List<String> get _selectedPatiens {
    return _checked.entries
        .where(
          (e) => e.value,
        )
        .map<String>(
          (e) => e.key,
        )
        .toList();
  }

  void _warnNoPatientsSelected() {
    showDialog(
      context: context,
      builder: (innerContext) {
        return AlertDialog(
          alignment: Alignment.center,
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 35,
          ),
          title: const Text('Aviso!'),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
          content: const Text('Selecione ao menos 1(um) paciente'),
          actions: [
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(innerContext).pop();
              },
            )
          ],
        );
      },
    );
  }
}
