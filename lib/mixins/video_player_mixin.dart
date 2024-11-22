import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lifetalk/app_export.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

mixin VideoPlayerMixin<S extends AbstractScreen> on AbstractScreenState<S> {
  VideoPlayerController? videoController;

  Future<VideoPlayerController?> playVideo(Talk talk) async {
    if (talk.type != ContentType.video) return null;
    final file =
        serviceLocator<LessonAssets>().get("${talk.targetValue}.mp4") as File;
    videoController = VideoPlayerController.file(file);
    await videoController?.initialize();
    videoController?.play();
    return videoController;
  }

  Future<void> stopVideo() => videoController!.pause();

  Widget videoBuilder(LessonController lessonController) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: videoController!,
      builder: (context, value, child) {
        if (!value.isInitialized) {
          return Widgets.rect(color: TColors.primary0);
        }
        var isEnable = value.duration.compareTo(value.position) <= 0;
        if (isEnable) {
          Timer(
            Duration(milliseconds: 100),
            () => lessonController.changeContent(1),
          );
        }
        return AspectRatio(
          aspectRatio: videoController!.value.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20.d)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(videoController!),
                /* isEnable
                    ? Positioned.fill(
                        child: Widgets.rect(
                          color: TColors.black40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.replay,
                                  size: 40.d,
                                  color: TColors.primary10,
                                ),
                                onPressed: () => _controller.play(),
                              ),
                              SizedBox(width: 56.d),
                              IconButton(
                                icon: Icon(
                                  Icons.skip_next,
                                  size: 40.d,
                                  color: TColors.primary10,
                                ),
                                onPressed: () =>
                                    lessonController.changeContent(1),
                              ),
                            ],
                          ),
                        ),
                      )
                    :  */
                const SizedBox()
              ],
            ),
          ),
        );
      },
    );
  }

  Widget youtubePlayer({double? borderRadius, bool showProgressbar = false}) {
    var entry = serviceLocator<MediaService>().entry!;
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 0)),
      child: Stack(
        children: [
          YoutubePlayer(
            controller: serviceLocator<MediaService>().youtubeController!,
            controlsTimeOut: Duration(milliseconds: 1),
          ),
          showProgressbar
              ? Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 5.d,
                  child: Widgets.rect(color: TColors.black40),
                )
              : SizedBox(),
          showProgressbar
              ? StreamBuilder(
                  stream: entry.onPositionChanged,
                  builder: (context, snapshot) {
                    return Positioned(
                        left: 0,
                        bottom: 0,
                        height: 5.d,
                        width: entry.positionRatio * DeviceInfo.size.width,
                        child: Widgets.rect(color: TColors.orange));
                  },
                )
              : SizedBox(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }
}
