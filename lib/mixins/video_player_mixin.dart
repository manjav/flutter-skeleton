import 'package:flutter/material.dart';
import 'package:lifetalk/app_export.dart';
import 'package:video_player/video_player.dart';

mixin VideoPlayerMixin<S extends AbstractScreen> on AbstractScreenState<S> {
  VideoPlayerController _controller = VideoPlayerController.networkUrl(Uri.parse(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'));

  Future<void> playVideo(Talk talk) async {
    if (talk.type != ContentType.video) return;
    _controller = VideoPlayerController.networkUrl(
        Uri.parse("${LoaderWidget.baseURL}/videos/${talk.targetValue}.mp4"));
    await _controller.initialize();
    _controller.play();
  }

  Widget videoBuilder(LessonController lessonController, Talk talk) {
    return ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: _controller,
        builder: (context, value, child) {
          if (!value.isInitialized) {
            return Widgets.rect(color: TColors.primary0);
          }
          var isEnable = value.duration.compareTo(value.position) <= 0;
          // print(
          //     "+++++++++++++++++ ${value.duration.compareTo(value.position)}");

          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20.d)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
                  isEnable
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
                      : const SizedBox()
                ],
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
