import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:voz_amiga/dto/patient.dto.dart';
import 'package:voz_amiga/infra/log/logger.dart';
import 'package:voz_amiga/infra/services/patients.service.dart';
import 'package:voz_amiga/shared/consts.dart';
import 'package:voz_amiga/utils/platform_utils.dart';

class PatientsListPage extends StatefulWidget {
  const PatientsListPage({super.key});

  @override
  State<PatientsListPage> createState() => _PatientsListPageState();
}

class _PatientsListPageState extends State<PatientsListPage> {
  final filterController = TextEditingController();
  String _orderBy = "";
  @override
  void initState() {
    super.initState();
    PatientsService.pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _body(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(RouteNames.newPatient);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        clipBehavior: Clip.antiAlias,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  final _numberOfPostsPerRequest = 10;

  Future<void> _fetchPage(int pageKey) async {
    try {
      final (error, patients) = await PatientsService.getPatients(
          filter: filterController.text,
          page: pageKey,
          pageSize: _numberOfPostsPerRequest,
          orderBy: _orderBy);
      final isLastPage =
          patients.total <= patients.itensPerPage * patients.page;
      if (error != null) {
        PatientsService.pagingController.error = error;
      } else {
        if (isLastPage) {
          PatientsService.pagingController.appendLastPage(patients.result);
        } else {
          final nextPageKey = pageKey + 1;
          PatientsService.pagingController
              .appendPage(patients.result, nextPageKey);
        }
      }
    } catch (e) {
      logger.e("error --> $e");
      PatientsService.pagingController.error = e;
    }
  }

  Widget _body(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () =>
          Future.sync(() => PatientsService.pagingController.refresh()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: <Widget>[
                Flexible(
                  flex: 2,
                  child: TextFormField(
                    controller: filterController,
                    onChanged: (text) {
                      PatientsService.pagingController.refresh();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Busque por nome',
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 5)),
                      hint: const Text("Ordenar"),
                      items: [
                        'Data de criação',
                        'Nome',
                        'Nome do responsável',
                        'Data de nascimento'
                      ]
                          .map((String unit) => DropdownMenuItem<String>(
                              value: unit, child: Text(unit)))
                          .toList(),
                      onChanged: (value) => setState(() {
                            switch (value) {
                              case "Nome":
                                _orderBy = "name";
                                break;
                              case "Nome do responsável":
                                _orderBy = "nameResponsible";
                                break;
                              case "Data de nascimento":
                                _orderBy = "birthdate";
                                break;
                              default:
                                _orderBy = "";
                                break;
                            }
                            PatientsService.pagingController.refresh();
                          })),
                )
              ],
            ),
          ),
          SlidableAutoCloseBehavior(
            closeWhenOpened: true,
            child: PagedListView<int, PatientDTO>.separated(
              shrinkWrap: true,
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 0.5,
                  child: ColoredBox(
                    color: Colors.grey[300]!,
                  ),
                );
              },
              pagingController: PatientsService.pagingController,
              builderDelegate: PagedChildBuilderDelegate<PatientDTO>(
                itemBuilder: _buildTile,
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
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, PatientDTO item, int index) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            backgroundColor: Colors.blueAccent,
            label: 'Editar',
            icon: Icons.edit_outlined,
            onPressed: (context) {
              context.go(RouteNames.editPatient(item.id));
            },
          ),
        ],
      ),
      child: _title(context, item),
    );
  }

  Widget _title(BuildContext context, PatientDTO item) {
    return ListTile(
      onTap: () {
        context.go(RouteNames.patient(item.id));
      },
      trailing: _trailing(context, item.id),
      title: Text(
        item.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      subtitle: Text(
        item.cpfPatient,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  Widget? _trailing(BuildContext context, String id) {
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
                    context.go(RouteNames.editPatient(id));
                  },
                  icon: const Icon(
                    Icons.edit_document,
                    color: Colors.blueAccent,
                  ),
                )
              ],
            ),
          )
        : null;
  }
}
