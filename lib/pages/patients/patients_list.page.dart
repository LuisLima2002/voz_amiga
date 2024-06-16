import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:voz_amiga/dto/patient.dto.dart';
import 'package:voz_amiga/infra/services/patients.service.dart';
import 'package:voz_amiga/shared/consts.dart';
import 'package:voz_amiga/utils/platform_utils.dart';

class PatientsListPage extends StatefulWidget {
  const PatientsListPage({super.key});

  @override
  State<PatientsListPage> createState() => _PatientsListPageState();
}

class _PatientsListPageState extends State<PatientsListPage> {
  
  final filterController  = TextEditingController();
  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
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

  final PagingController<int, PatientDTO> _pagingController =
      PagingController(firstPageKey: 0);

  Future<void> _fetchPage(int pageKey) async {
    try {
      final (error, patients) = await PatientsService.getPatients(
        filter: filterController.text,
        page: pageKey,
        pageSize: _numberOfPostsPerRequest,
      );
      final isLastPage =
          patients.total <= patients.itensPerPage * patients.page;
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
    } catch (e) {
      print("error --> $e");
      _pagingController.error = e;
    }
  }

  Widget _body(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(() => _pagingController.refresh()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: TextFormField(
              controller: filterController,
              // onChanged: (value) => {_fetchPage(0)},
              decoration: const InputDecoration(
                hintText: 'Busque por nome',
              ),
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
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<PatientDTO>(
                itemBuilder: _buildTile,
                noItemsFoundIndicatorBuilder: (context) {
                  return const Center(
                    child: Text(
                      "Algo deu errado!\nTente novamente",
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
              // context.go(RouteNames.editActivity(item.id));
            },
          ),
        ],
      ),
      child: _title(context,item),
    );
  }

   Widget _title(BuildContext context, PatientDTO item) {
    return ListTile(
      onTap: () {
        // context.go(RouteNames.activity(item.id));
      },
      trailing: _trailing(context),
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

  Widget? _trailing(BuildContext context) {
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
                  onPressed: () {},
                  icon: const Icon(
                    Icons.edit_document,
                    color: Colors.blueAccent,
                  ),
                ),
                IconButton(
                  onPressed: () {},
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

}
