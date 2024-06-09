import 'package:flutter/material.dart';
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
          context.go(RouteNames.activity(0));
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
    try {
      final (error, activities) = await ActivitiesService.getActivities();
      final isLastPage = activities.length < _numberOfPostsPerRequest;
      if (error != null) {
        _pagingController.error = error;
      } else {
        if (isLastPage) {
          _pagingController.appendLastPage(activities);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(activities, nextPageKey);
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
      child: PagedListView<int, ActivityDTO>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<ActivityDTO>(
          itemBuilder: _buildTile,
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, ActivityDTO item, int index) {
    final leadingImage = switch (item.mimeType.split('/')[0]) {
      'text' => const Icon(Icons.abc_sharp),
      'image' => const Icon(Icons.image_outlined),
      'video' => const Icon(Icons.video_collection_outlined),
      _ => const Icon(Icons.question_mark_rounded),
    };
    final trailing = MediaQuery.of(context).screenType == ScreenType.tablet ||
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

    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        child: leadingImage,
      ),
      trailing: trailing,
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
}
