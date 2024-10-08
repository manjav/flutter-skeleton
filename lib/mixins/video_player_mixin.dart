import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lifetalk/app_export.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

mixin VideoPlayerMixin<S extends AbstractScreen> on AbstractScreenState<S> {
  final VideoPlayerController _controller = VideoPlayerController.networkUrl(
      Uri.parse(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'));

  Future<void> playVideo(Talk talk) async {
    if (talk.type != ContentType.video) return;
    // final file =
    //     serviceLocator<LessonAssets>().get("${talk.targetValue}.mp4") as File;
    // _controller = VideoPlayerController.file(file);
    // await _controller.initialize();
    // _controller.play();
  }

  Future<void> stopVideo() => _controller.pause();

  Widget videoBuilder(LessonController lessonController) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: _controller,
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
          aspectRatio: _controller.value.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20.d)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
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

  Widget youtubePlayer(LessonController controller) {
    final YoutubePlayerController youtubeController = YoutubePlayerController(
      initialVideoId: 'v4zTAkLKgm4',
      flags: YoutubePlayerFlags(
        autoPlay: true,
        startAt: 10,
        endAt: 15,
        enableCaption: false,
        hideControls: true,
        hideThumbnail: true,
      ),
    );
    youtubeController.addListener(
      () {
        print(" BEHZAD ${youtubeController.value.position}");
      },
    );
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(20.d)),
      child: YoutubePlayer(
        controller: youtubeController,
        controlsTimeOut: Duration(milliseconds: 1),
        topActions: [Widgets.rect(color: TColors.pink, width: 11, height: 33)],
        onEnded: (metaData) {
          print("SSSSS $metaData");
          controller.changeContent(1);
        },
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.amber,
        progressColors: const ProgressBarColors(
          playedColor: Colors.amber,
          handleColor: Colors.amberAccent,
        ),
        onReady: () {
          // youtubeController.
          // _controller.addListener(listener);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
