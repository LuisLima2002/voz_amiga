import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:voz_amiga/dto/activity.dto.dart';
import 'package:voz_amiga/infra/log/logger.dart';
import 'package:voz_amiga/features/profissional/activity/services/activities.service.dart';
import 'package:voz_amiga/shared/client.dart';
import 'package:voz_amiga/shared/consts.dart';

class ActivityViewerPage extends StatefulWidget {
  final String id;
  const ActivityViewerPage({
    super.key,
    required this.id,
  });

  @override
  State<ActivityViewerPage> createState() => _ActivityViewerPageState();
}

class _ActivityViewerPageState extends State<ActivityViewerPage> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;
  bool _pauseVisible = true;
  bool _isLoading = true;
  ActivityDTO? _activity;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    ActivitiesService.getActivity(widget.id).then((response) {
      setState(() {
        if (response.$1 != null) {
          _error = response.$1.toString();
        } else {
          _activity = response.$2;
        }
        _isLoading = false;
      });
    });
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      final uri = ApiClient.getUri(
        'activity/${widget.id.replaceAll('-', '')}/media',
      );
      _videoController = VideoPlayerController.networkUrl(
        uri,
        httpHeaders: {
          // 'Authorization': 'Bearer ${widget.id}',
        },
      );

      await _videoController.initialize();
      setState(() {
        _isInitialized = true;
        _error = null;
      });
    } catch (e) {
      logger.e("Error initializing video player: $e");
      setState(() {
        _isInitialized = true;
        _error = 'Não foi possível carregar o vídeo';
      });
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading || !_isInitialized
        ? const Center(child: CircularProgressIndicator())
        : _error == null
            ? _details
            : Center(
                child: Text(_error ?? "Erro inesperado"),
              );
  }

  Widget get _details {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      // mainAxisSize: MainAxisSize.min,
      children: [
        _player,
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Título",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _activity!.title,
                    style: const TextStyle(
                      fontSize: 25,
                    ),
                  ),
                  const Text(
                    "Descrição",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _activity!.description,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        _actions,
      ],
    );
  }

  Widget get _actions {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
      child: Row(
        // alignment: MainAxisAlignment.center,
        // buttonMinWidth: double.infinity,
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: ElevatedButton(
              onPressed: () {
                context.push(RouteNames.assignActivity(widget.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: const ContinuousRectangleBorder(),
              ),
              child: const Column(
                children: [
                  Icon(Icons.person_add_alt_1),
                  Text('Atribuir'),
                ],
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: ElevatedButton(
              onPressed: () {
                _deleteActivity();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: const ContinuousRectangleBorder(),
              ),
              child: const Column(
                children: [
                  Icon(Icons.delete_forever),
                  Text('Excluir'),
                ],
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: ElevatedButton(
              onPressed: () {
                context.go(RouteNames.assignActivity(widget.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: const ContinuousRectangleBorder(),
              ),
              child: const Column(
                children: [
                  Icon(Icons.person_add_alt_1),
                  Text('Atribuir'),
                ],
              ),
            ),
          ),
          Flexible(
            child: ElevatedButton(
              onPressed: () {
                context.push(RouteNames.editActivity(widget.id));
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                minimumSize: const Size.fromHeight(20),
                backgroundColor: Colors.transparent,
                shape: const ContinuousRectangleBorder(),
              ),
              child: const Column(
                children: [
                  Icon(Icons.edit),
                  Text('Editar'),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Timer? _cancel;
  Widget get _player {
    var onStack = <Widget>[
      AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _pauseVisible = true;
              _cancel = Timer(
                const Duration(seconds: 1, milliseconds: 500),
                () {
                  setState(() {
                    _pauseVisible = false;
                  });
                },
              );
            });
          },
          child: VideoPlayer(_videoController),
        ),
      ),
    ];
    if (_pauseVisible) {
      onStack.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                if (_videoController.value.isPlaying) {
                  _videoController.pause();
                  _pauseVisible = true;
                  _cancel?.cancel();
                } else {
                  _videoController.play();
                  _pauseVisible = false;
                }
              });
            },
            backgroundColor: const Color(0xFFFFFFFF),
            foregroundColor: Colors.black,
            clipBehavior: Clip.antiAlias,
            shape: const CircleBorder(),
            child: _videoController.value.isPlaying
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
          ),
        ],
      ));
    }
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      height: 250,
      width: double.infinity,
      child: Center(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: onStack,
        ),
      ),
    );
  }

  _deleteActivity() {
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
                  'Você realmente deseja excluir essa atividade?',
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
                Navigator.pop(context, 'Kill it');
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
          ActivitiesService.delete(widget.id).then(
            (res) {
              showDialog(
                context: context,
                barrierColor: const Color(0x55000000),
                builder: (context) {
                  return AlertDialog(
                    content: SizedBox(
                      height: 200,
                      width: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Excluido!',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Ok',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ).then((v) {
                Navigator.pop(context);
              });
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
