import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:voz_amiga/dto/ActivityAttemptDTO.dto.dart';
import 'package:voz_amiga/dto/activity.dto.dart';
import 'package:voz_amiga/features/profissional/activity/services/activities.service.dart';
import 'package:voz_amiga/infra/services/assignedExercises.service.dart';
import 'package:voz_amiga/shared/client.dart';
import 'package:image_picker/image_picker.dart';

class PatientActivityAttemptsViewerPage extends StatefulWidget {
  final String assignedExerciseId;
  final String activityId;
  const PatientActivityAttemptsViewerPage(
      {super.key, required this.assignedExerciseId, required this.activityId});

  @override
  State<PatientActivityAttemptsViewerPage> createState() =>
      _PatientActivityAttemptsViewerPageState();
}

class _PatientActivityAttemptsViewerPageState
    extends State<PatientActivityAttemptsViewerPage> {
  VideoPlayerController? _videoController;
  int _attemptIndex = 0;
  bool _isInitialized = false;
  bool _pauseVisible = true;
  bool _isLoading = true;
  List<ActivityAttemptDTO>? _activityAttempts;
  ActivityDTO? _activity;
  String? _error;
  XFile? videoFile;
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = <String, TextEditingController>{
      'comment': TextEditingController(),
      'rating': TextEditingController()
    };

    ActivitiesService.getActivity(widget.activityId).then((response) {
      setState(() {
        if (response.$1 != null) {
          _error = response.$1.toString();
        } else {
          _activity = response.$2;
        }
      });
    });
    AssignedExercisesService.getActivityAttempts(
            widget.assignedExerciseId, widget.activityId)
        .then((response) {
      setState(() {
        if (response.$1 != null) {
          _error = response.$1.toString();
        } else {
          _activityAttempts = response.$2;
          if (_activityAttempts!.isNotEmpty) {
            _initializeVideoPlayer(_activityAttempts![_attemptIndex].id);
          } else {
            _isInitialized = true;
            _error = null;
            _videoController = null;
          }
        }
        _isLoading = false;
      });
    });
  }

  Future<void> _loadAttempt(String id) async {
    setState(() {
      _isInitialized = false;
      _isLoading = false;
      _initializeVideoPlayer(_activityAttempts![_attemptIndex].id);
    });
  }

  Future<void> _nextAttempt() async {
    _attemptIndex++;
    if (_activityAttempts!.length == _attemptIndex) {
      _attemptIndex--;
    } else {
      videoFile = null;
      if (_activityAttempts!.isNotEmpty) {
        _loadAttempt(_activityAttempts![_attemptIndex].id);
      }
    }
  }

  Future<void> _previousAttempt() async {
    _attemptIndex--;
    if (_attemptIndex < 0) {
      _attemptIndex = 0;
    } else {
      videoFile = null;
      if (_activityAttempts!.isNotEmpty) {
        _loadAttempt(_activityAttempts![_attemptIndex].id);
      }
    }
  }

  Future<void> _initializeVideoPlayer(String id) async {
    try {
      _controllers["comment"]!.text = _activityAttempts![_attemptIndex].comment;
      _controllers["rating"]!.text =
          _activityAttempts![_attemptIndex].rating.toString();
      final uri = ApiClient.getUri(
        'assignedexercises/attempt/${id.replaceAll('-', '')}/media',
      );
      _videoController = VideoPlayerController.networkUrl(
        uri,
        httpHeaders: {
          // 'Authorization': 'Bearer ${widget.id}',
        },
      );

      await _videoController!.initialize();
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

  Future<void> _save() async {
    try {
      var res = await AssignedExercisesService.update(
          activityAttempt: ActivityAttemptDTO(
              id: _activityAttempts![_attemptIndex].id,
              createAt: _activityAttempts![_attemptIndex].createAt,
              comment: _controllers["comment"]!.text,
              rating: int.parse(_controllers["rating"]!.text)));
      if (res > 0) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return AlertDialog(
              alignment: Alignment.center,
              icon: const Icon(Icons.info,
                  color: Colors.deepPurpleAccent, size: 35),
              title: const Text('Salvo com sucesso!'),
              titleTextStyle: const TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
              actions: [
                TextButton(
                  child: const Text(
                    'Ok',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
      } else {
        throw Error();
      }
    } catch (e) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return AlertDialog(
            alignment: Alignment.center,
            icon: const Icon(Icons.dangerous, color: Colors.red, size: 35),
            title: const Text('Ocorreu um erro durante o salvamento!'),
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

  @override
  void dispose() {
    if (_videoController != null) {
      _videoController!.dispose();
    }
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
    return _activityAttempts!.isEmpty
        ? const Center(
            child: Text("Essa atividade não tem nenhuma tentativa"),
          )
        : Column(
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
                        Row(
                          children: [
                            Text(
                              "Tentativa ${_attemptIndex + 1}",
                              style: const TextStyle(
                                fontSize: 35,
                                color: Colors.deepPurple,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Data: ${DateFormat('dd/MM/yyyy').format(_activityAttempts![_attemptIndex].createAt)}",
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        _player,
                        const SizedBox(height: 15),
                        const Text(
                          "Descrição da atividade",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _activity!.description,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black54),
                        ),
                        TextField(
                          maxLines: null,
                          controller: _controllers["comment"],
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            labelText: "Comentários",
                            labelStyle: TextStyle(color: Color(0xFF6D6D6D)),
                          ),
                        ),
                        TextField(
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9]?$|^10$'))
                          ],
                          controller: _controllers["rating"],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Avaliação (0-10)",
                            labelStyle: TextStyle(color: Color(0xFF6D6D6D)),
                          ),
                        )
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(children: [
        Expanded(
          child: (_attemptIndex > 0)
              ? ElevatedButton(
                  onPressed: _previousAttempt,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(0),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Icon(Icons.arrow_left, size: 45),
                )
              : const SizedBox(),
        ),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: _save,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "Salvar",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ),
        Expanded(
            child: (_activityAttempts!.length - 1 > _attemptIndex)
                ? ElevatedButton(
                    onPressed: _nextAttempt,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(0),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Icon(
                      Icons.arrow_right,
                      size: 45,
                    ),
                  )
                : const SizedBox()),
      ]),
    );
  }

  Timer? _cancel;
  Widget get _player {
    var onStack = <Widget>[
      AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
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
          child: VideoPlayer(_videoController!),
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
                if (_videoController!.value.isPlaying) {
                  _videoController!.pause();
                  _pauseVisible = true;
                  _cancel?.cancel();
                } else {
                  _videoController!.play();
                  _pauseVisible = false;
                }
              });
            },
            backgroundColor: const Color(0xFFFFFFFF),
            foregroundColor: Colors.black,
            clipBehavior: Clip.antiAlias,
            shape: const CircleBorder(),
            child: _videoController!.value.isPlaying
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
