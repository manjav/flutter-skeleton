import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lifetalk/app_export.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

mixin VideoPlayerMixin<S extends AbstractScreen> on AbstractScreenState<S> {
  VideoPlayerController? videoController;
  YoutubePlayerController? youtubeController;

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

  VideoPlayerController? playYoutube(String url) {
    final uri = Uri.parse(url);
    youtubeController = YoutubePlayerController(
      initialVideoId: uri.pathSegments.last,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        startAt: int.parse(uri.queryParameters["start"] ?? "0"),
        endAt: uri.queryParameters.containsKey("end")
            ? int.parse(uri.queryParameters["end"]!)
            : null,
        enableCaption: false,
        hideControls: true,
        hideThumbnail: true,
      ),
    );

    return videoController;
  }

  Widget youtubePlayer({double? borderRadius}) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 0)),
      child: YoutubePlayer(
        controller: youtubeController!,
        controlsTimeOut: Duration(milliseconds: 1),
        topActions: [Widgets.rect(color: TColors.pink, width: 11, height: 33)],
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.amber,
        progressColors: const ProgressBarColors(
          playedColor: Colors.amber,
          handleColor: Colors.amberAccent,
        ),
      ),
    );
  }

  @override
  void dispose() {
    videoController?.dispose();
    youtubeController?.dispose();
    super.dispose();
  }
}
