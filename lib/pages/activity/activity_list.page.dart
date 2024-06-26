import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:voz_amiga/dto/activity.dto.dart';
import 'package:voz_amiga/infra/services/activities.service.dart';
import 'package:voz_amiga/shared/consts.dart';
import 'package:voz_amiga/utils/platform_utils.dart';
import 'package:voz_amiga/utils/string_utils.dart';

class ActivityListPage extends StatefulWidget {
  const ActivityListPage({super.key});

  @override
  State<ActivityListPage> createState() => _ActivityListPageState();
}

class _ActivityListPageState extends State<ActivityListPage> {
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
          context.push(RouteNames.newActivity).then((_) {
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
      if (isLastPage) {
        _pagingController.appendLastPage(activities.result);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(activities.result, nextPageKey);
      }
    }
    // } catch (e) {
    // print("error --> $e");
    // _pagingController.error = e;
    // }
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
        ],
      ),
    );
  }

  @pragma('vm:prefer-inline')
  Widget _buildTile(BuildContext context, ActivityDTO item, int index) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            backgroundColor: Colors.blueAccent,
            label: 'Editar',
            icon: Icons.edit_outlined,
            onPressed: (context) {
              context.push(RouteNames.editActivity(item.id)).then((_) {
                print('fresh');
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
  Widget _tile(BuildContext context, ActivityDTO item) {
    final leadingImage = switch (item.mimeType.split('/')[0]) {
      'text' => const Icon(Icons.abc_sharp),
      'image' => const Icon(Icons.image_outlined),
      'video' => const Icon(Icons.video_collection_outlined),
      _ => const Icon(Icons.question_mark_rounded),
    };

    return ListTile(
      onTap: () {
        context.push(RouteNames.activity(item.id)).then((_) {
          print('fresh');
          Future.sync(() => _pagingController.refresh());
        });
      },
      leading: CircleAvatar(
        radius: 30,
        child: leadingImage,
      ),
      trailing: _trailing(context),
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
