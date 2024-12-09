import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:voz_amiga/dto/exercise.dto.dart';
import 'package:voz_amiga/infra/log/logger.dart';
import 'package:voz_amiga/features/profissional/exercises/services/exercises.service.dart';
import 'package:voz_amiga/components/empty_search.w.dart';
import 'package:voz_amiga/components/first_try_error.w.dart';
import 'package:voz_amiga/shared/consts.dart';
import 'package:voz_amiga/utils/platform_utils.dart';
import 'package:voz_amiga/utils/string_utils.dart';
import 'package:voz_amiga/utils/toastr.dart';

class ExercisesListPage extends StatefulWidget {
  const ExercisesListPage({super.key});

  @override
  State<ExercisesListPage> createState() => _ExercisesListPageState();
}

class _ExercisesListPageState extends State<ExercisesListPage> {
  Timer? _debounce;
  final TextEditingController _filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    _filterController.addListener(() {
      if (_debounce?.isActive ?? false) {
        _debounce?.cancel();
      }
      _debounce = Timer(const Duration(milliseconds: 500), () {
        Future.sync(() => _pagingController.refresh());
      });
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
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
          context.push(RouteNames.newExercise).then((_) {
            Future.sync(() => _pagingController.refresh());
          });
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

  final PagingController<int, Exercise> _pagingController =
      PagingController(firstPageKey: 0);

  Future<void> _fetchPage(int pageKey) async {
    // try {
    final (error, exercises) = await ExercisesService.getExercises(
      filter: _filterController.text,
      page: pageKey,
      pageSize: _numberOfPostsPerRequest,
    );
    final isLastPage =
        exercises.total <= (exercises.itensPerPage * exercises.page);
    if (error != null) {
      _pagingController.error = error;
    } else {
      if (isLastPage) {
        _pagingController.appendLastPage(exercises.result);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(exercises.result, nextPageKey);
      }
    }
  }

  @pragma('vm:prefer-inline')
  Widget _body(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(() => _pagingController.refresh()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: TextFormField(
              controller: _filterController,
              autofocus: false,
              decoration: const InputDecoration(
                hintText: 'Busque por nome ou descrição..',
              ),
            ),
          ),
          SlidableAutoCloseBehavior(
            closeWhenOpened: true,
            child: Expanded(
              child: PagedListView<int, Exercise>.separated(
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 0.5,
                    child: ColoredBox(
                      color: Colors.grey[300]!,
                    ),
                  );
                },
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<Exercise>(
                  itemBuilder: _buildTile,
                  noItemsFoundIndicatorBuilder: (context) {
                    return const EmptySearch();
                  },
                  newPageErrorIndicatorBuilder: (context) {
                    return const Text('Ocorreu um erro!');
                  },
                  firstPageErrorIndicatorBuilder: (context) {
                    return const FirstTryError();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @pragma('vm:prefer-inline')
  Widget _buildTile(BuildContext context, Exercise item, int index) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            backgroundColor: Colors.blueAccent,
            label: 'Editar',
            icon: Icons.edit_outlined,
            onPressed: (context) {
              context.push(RouteNames.editExercise(item.id)).then((_) {
                logger.t('fresh');
                Future.sync(() => _pagingController.refresh());
              });
            },
          ),
        ],
      ),
      child: _tile(context, item),
    );
  }

  @pragma('vm:prefer-inline')
  Widget _tile(BuildContext context, Exercise item) {
    return ListTile(
      onTap: () {
        context.push(RouteNames.exercise(item.id)).then((_) {
          logger.t('fresh');
          Future.sync(() => _pagingController.refresh());
        });
      },
      leading: const CircleAvatar(
        radius: 30,
        child: Icon(Icons.book),
      ),
      trailing: _trailing(context, item),
      title: Text(
        item.title.capitalize(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      subtitle: Text(
        item.description.capitalize(),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  @pragma('vm:prefer-inline')
  Widget? _trailing(BuildContext context, Exercise item) {
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
                    context.push(RouteNames.editExercise(item.id)).then((_) {
                      Future.sync(() => _pagingController.refresh());
                    });
                  },
                  icon: const Icon(
                    Icons.edit_document,
                    color: Colors.blueAccent,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.push(RouteNames.assignExercise(item.id));
                  },
                  icon: const Icon(
                    Icons.assignment,
                    color: Colors.green,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _deleteExercise(item);
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

  _deleteExercise(Exercise exercise) {
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
                if (Navigator.canPop(context)) {
                  Navigator.pop(context, 'Kill it');
                }
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
          ExercisesService.delete(exercise.id).then(
            (res) {
              Toastr.success(context, 'Excluido com sucesso!');
              _pagingController.refresh();
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
