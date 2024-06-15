import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VaVideoPlayer extends StatefulWidget {
  final String? src;
  final VoidCallback onUploadTap;

  const VaVideoPlayer({
    super.key,
    required this.src,
    required this.onUploadTap,
  });

  @override
  State<VaVideoPlayer> createState() {
    return _VaVideoPlayerState();
  }
}

class _VaVideoPlayerState extends State<VaVideoPlayer> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.src != null) {
      if (widget.src!.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.src!),
        );
      } else {
        _controller = VideoPlayerController.file(
          File(widget.src!),
        )..initialize().then((v) {
            setState(() {});
          });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.src != null) {
      if (widget.src!.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.src!),
        );
      } else {
        _controller = VideoPlayerController.file(
          File(widget.src!),
        );
      }
    }
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: _controller != null
          ? AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                fit: StackFit.expand,
                children: [
                  VideoPlayer(_controller!),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ButtonBar(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (!_controller!.value.isInitialized) {
                                _controller?.initialize().then((v) {
                                  setState(() {});
                                });
                              } else {
                                setState(() async {
                                  _controller!.value.isPlaying
                                      ? await _controller!.pause()
                                      : await _controller!.play();
                                });
                              }
                            },
                            child: const Icon(Icons.play_arrow),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            )
          : ColoredBox(
              color: const Color.fromARGB(255, 146, 146, 146),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: () {
                    widget.onUploadTap();
                  },
                  child: const Icon(
                    Icons.upload_rounded,
                    size: 35,
                  ),
                ),
              ),
            ),
    );
  }
}
