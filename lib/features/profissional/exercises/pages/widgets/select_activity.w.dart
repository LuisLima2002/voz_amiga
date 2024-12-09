import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:voz_amiga/dto/activity.dto.dart';
import 'package:voz_amiga/features/profissional/activity/services/activities.service.dart';
import 'package:voz_amiga/features/profissional/exercises/services/exercises.service.dart';
import 'package:voz_amiga/utils/platform_utils.dart';
import 'package:voz_amiga/utils/string_utils.dart';
import 'package:voz_amiga/utils/toastr.dart';

class SelectActivity extends StatefulWidget {
  final String exerciseId;
  final List<String> activities;

  const SelectActivity({
    super.key,
    required this.exerciseId,
    required this.activities,
  });

  @override
  State<SelectActivity> createState() => _SelectActivityState();
}

class _SelectActivityState extends State<SelectActivity> {
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
    return Dialog(
      elevation: 0,
      child: _body(context),
    );
  }

  final _numberOfPostsPerRequest = 25;

  final PagingController<int, ActivityDTO> _pagingController =
      PagingController(firstPageKey: 0);

  Future<void> _fetchPage(int pageKey) async {
    // try {
    final (error, activities) = await ActivitiesService.getActivities(
      filter: _filterController.text,
      page: pageKey,
      pageSize: _numberOfPostsPerRequest,
    );
    final isLastPage =
        activities.total <= (activities.itensPerPage * activities.page);
    if (error != null) {
      _pagingController.error = error;
    } else {
      var result = activities.result
          .where((a) => !widget.activities.contains(a.id))
          .toList();
      if (isLastPage) {
        _pagingController.appendLastPage(result);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(result, nextPageKey);
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 1,
                ),
              ),
            ),
            child: const Center(
              child: Text(
                'Selecione atividades para esse exercício',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              bottom: 10,
              top: 5,
            ),
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
              child: PagedListView<int, ActivityDTO>.separated(
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 0.5,
                    child: ColoredBox(
                      color: Colors.grey[300]!,
                    ),
                  );
                },
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<ActivityDTO>(
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
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.black12,
                  width: 1,
                ),
              ),
            ),
            child: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Fechar',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @pragma('vm:prefer-inline')
  Widget _buildTile(BuildContext context, ActivityDTO item, int index) {
    return _tile(context, item);
  }

  @pragma('vm:prefer-inline')
  Widget _tile(BuildContext context, ActivityDTO item) {
    final leadingImage = switch (item.mimeType.split('/')[0]) {
      'text' => const Icon(Icons.abc_sharp),
      'image' => const Icon(Icons.image_outlined),
      'video' => const Icon(Icons.video_collection_outlined),
      _ => const Icon(Icons.question_mark_rounded),
    };

    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        child: leadingImage,
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
  Widget? _trailing(BuildContext context, ActivityDTO activity) {
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
                    ExercisesService.addActivityToExercise(
                      exerciseId: widget.exerciseId,
                      activityId: activity.id,
                    ).then((_) {
                      Toastr.success(context, 'Adicionado com sucesso');
                      widget.activities.add(activity.id);
                      _pagingController.refresh();
                    });
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          )
        : null;
  }
}
