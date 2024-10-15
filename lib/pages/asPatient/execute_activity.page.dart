import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:voz_amiga/dto/activity.dto.dart';
import 'package:voz_amiga/dto/exercise.dto.dart';
import 'package:voz_amiga/infra/services/activities.service.dart';
import 'package:voz_amiga/infra/services/assignedExercises.service.dart';
import 'package:voz_amiga/infra/services/exercises.service.dart';
import 'package:voz_amiga/shared/client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voz_amiga/shared/consts.dart';

class ExecuteActivityPage extends StatefulWidget {
  final String id;
  const ExecuteActivityPage({super.key, required this.id});

  @override
  State<ExecuteActivityPage> createState() => _ExecuteActivityPageState();
}

class _ExecuteActivityPageState extends State<ExecuteActivityPage> {
  late VideoPlayerController _videoController;
  int _activityIndex = 0;
  bool _isInitialized = false;
  bool _pauseVisible = true;
  bool _isLoading = true;
  Exercise? _exercise;
  ActivityDTO? _activity;
  String? _error;
  XFile? videoFile;
  bool mock = false;

  @override
  void initState() {
    super.initState();
    ExercisesService.getExercise(widget.id).then((response) {
      setState(() {
        if (response.$1 != null) {
          _error = response.$1.toString();
          _isLoading = false;
        } else {
          _exercise = response.$2;
          _loadActivity(_exercise!.activities[_activityIndex].id);
        }
      });
    });
  }

  Future<void> _loadActivity(String id) async {
    setState((){
      _isInitialized = false;
      _isLoading = false;
    });
    ActivitiesService.getActivity(id).then((response) {
      setState(() {
        if (response.$1 != null) {
          _error = response.$1.toString();
        } else {
          _activity = response.$2;
          _initializeVideoPlayer(id);
        }
        _isLoading = false;
      });
    });
  }

  Future<void> _nextActivity() async {
    _activityIndex++;
    if (_exercise!.activities.length == _activityIndex) {
      await showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return AlertDialog(
            content: const Text('Exercício concluído!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go(RouteNames.activityPatientList);
                },
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
    } else {
      videoFile = null;
      _loadActivity(_exercise!.activities[_activityIndex].id);
    }
  }

  Future<void> _initializeVideoPlayer(String id) async {
    try {
      final uri = ApiClient.getUri(
        'activity/${id.replaceAll('-', '')}/media',
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
      print("Error initializing video player: $e");
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
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Exercício: ${_exercise!.title}",
                    style: const TextStyle(
                      fontSize: 35,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const Divider(
                    height: 10,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                    color: Colors.grey,
                  ),
                  Text(
                    "Atividade ${_activityIndex + 1}: ${_activity!.title}",
                    style: const TextStyle(
                      fontSize: 25,
                    ),
                  ),
                  _player,
                  const SizedBox(height: 15),
                  const Text(
                    "Descrição",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _activity!.description,
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
        _actions
      ],
    );
  }

  Widget get _actions {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 15),
            child: ElevatedButton(
              onPressed: () async {
                try {
                  videoFile =
                      await ImagePicker().pickVideo(source: ImageSource.camera);

                  if (videoFile != null) {
                    setState(() {
                      print("camera is not null");
                    });
                  } else {
                    print("camera is null");
                  }
                } catch (e) {
                  print("Error: $e");
                }
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Icon(Icons.camera_alt_rounded),
            ),
          ),
          (videoFile != null)
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: ElevatedButton(
                    onPressed: () async {
                      setState((){_isLoading=true;});
                      if (await AssignedExercisesService.saveActivityAttempt(
                              AssignedExercisesService.id,
                              activityId: _activity!.id,
                              file: videoFile,
                              done: _exercise!.activities.length == _activityIndex+1) ==
                          200) {
                        setState((){_isLoading=false;});
                        _nextActivity();
                      } else {
                        setState((){_isLoading=false;});
                        await showDialog(
                          // ignore: use_build_context_synchronously
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              alignment: Alignment.center,
                              icon: const Icon(Icons.dangerous,
                                  color: Colors.red, size: 35),
                              title: const Text(
                                  'Ocorreu um erro durante o salvamento!'),
                              titleTextStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                              content: const Text("Tente novamente"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Ok'),
                                ),
                              ],
                            );
                          },
                        );
                        print("Error saving the attempt");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Icon(Icons.done),
                  ),
                )
              : const SizedBox()
        ]),
        (videoFile != null || mock)
            ? const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  "Vídeo gravado com sucesso",
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ))
            : const SizedBox(),
      ],
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
}
