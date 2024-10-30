import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../app_export.dart';

class ImitationScreen extends AbstractScreen {
  ImitationScreen({super.key}) : super(Routes.imitation);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<ImitationScreen>
    with LessonMixin, ListeningMixin, VideoPlayerMixin {
  final ValueNotifier<VideoIntry?> _videoData = ValueNotifier(null);
  final List<VideoIntry> _captions = [];
  final ValueNotifier<bool> _captionMode = ValueNotifier(false);
  final PageController _pageController = PageController();

  @override
  void initState() {
    _pageController.addListener(
      () => controller.slideIndex.value = (_pageController.page ?? 0).round(),
    );
    controller.slideIndex.addListener(_onSlideChange);
    initializeController();
    super.initState();
  }

  void _onSlideChange() {
    _playYoutube(controller.currentSlide);
  }

  void _nextSlide() => _pageController.nextPage(
      duration: Duration(milliseconds: 300), curve: Curves.easeInOut);

  @override
  Widget contentBuilder(double paddingTop) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(height: 100.d),
        ValueListenableBuilder(
          valueListenable: _videoData,
          builder: (context, value, child) {
            return value == null ? SizedBox() : youtubePlayer();
          },
        ),
        SizedBox(
          height: 450.d,
          child: PageView.builder(
            controller: _pageController,
            itemCount: controller.currentSerie.children.length,
            itemBuilder: (context, index) => _slideRenderer(
              controller.currentSerie.children[index] as ParentContent,
            ),
          ),
        ),
        SizedBox(height: 100.d),
      ],
    );
  }

  Widget _slideRenderer(ParentContent slide) {
    final first = slide.children.first as Talk;
    return Container(
      margin: EdgeInsets.all(30.d),
      padding: EdgeInsets.all(30.d),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: first.type == ContentType.station
              ? TColors.transparent
              : TColors.primary0,
          border: Border.all(color: TColors.primary20, width: 2.d),
          borderRadius: BorderRadius.all(Radius.circular(20.d))),
        _captionSlideBuilder()
      },
    );
  }

  }

  Widget _captionSlideBuilder() {
    return ValueListenableBuilder(
      valueListenable: _captionMode,
      builder: (context, value, child) {
        return Column(
          children: [
            _captionBuilder(value),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _captionButton("reset", TColors.transparent, onPress: () {
                  final v = _videoData.value!;
                  youtubeController?.load(v.id, startAt: v.start, endAt: v.end);
                }),
                _captionButton(
                    "cc", value ? TColors.primary90 : TColors.transparent,
                    onPress: () => _captionMode.value = !_captionMode.value),
              ],
            )
          ],
        );
      },
    );
  }

  Widget _captionBuilder(bool captionMode) {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: caption,
        builder: (context, value, child) {
          if (captionMode) {
            if (value == null) return SizedBox();
            return Text(
              value.targetValue.simplify(),
              // textAlign: TextAlign.center,
              style: TStyles.big,
            );
          } else {
            return LoaderWidget(AssetType.vector, "ear");
          }
        },
      ),
    );
  }

  Widget _captionButton(String icon, Color color, {Function()? onPress}) {
    return Widgets.button(
      context,
      width: 56.d,
      height: 40.d,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(30.d)),
        border: Border.all(color: TColors.primary20, width: 2.d),
      ),
      padding: EdgeInsets.symmetric(vertical: 11.d, horizontal: 16.d),
      child: Asset.load<SvgPicture>(icon),
      onPressed: onPress,
    );
  }

  Future<void> _playYoutube(ParentContent slide) async {
    final youtubeContents = controller.currentSlide.children
        .where((c) => c.type == ContentType.youtube);
    _captions.clear();
    if (youtubeContents.isEmpty) {
      _videoData.value = null;
      return;
    }
    _videoData.value = VideoIntry.parse(youtubeContents.first.targetValue);

    final list =
        slide.children.where((c) => c.type == ContentType.caption).toList();
    for (var caption in list) {
      var seconds = _getMilliSeconds(caption.nativeValue);
      _captions.add(VideoIntry(
        "",
        _captions.lastOrNull != null ? _captions.last.end ?? 0 : 0,
        seconds,
      )..data = caption);
    }
    if (youtubeController == null) {
      playYoutube(_videoData.value!);
      youtubeController!.addListener(() {
        _setCurrentCaption();
        if (youtubeController!.value.playerState == PlayerState.ended) {
          _nextSlide();
        }
      });
    } else {
      youtubeController?.load(_videoData.value!.id,
          startAt: _videoData.value!.start, endAt: _videoData.value?.end);
    }
  }

  void _setCurrentCaption() {
    final milliseconds = youtubeController!.value.position.inMilliseconds;
    for (var caption in _captions) {
      if (caption.start <= milliseconds && (caption.end ?? 0) > milliseconds) {
        this.caption.value = caption.data;
        return;
      }
    }
  }

  int _getMilliSeconds(String time) {
    final times = time.split("，");
    final digits = times.first.split(":");
    final duration = Duration(
      hours: int.parse(digits[0]),
      minutes: int.parse(digits[1]),
      seconds: int.parse(digits[2]),
      milliseconds: int.parse(times[1]),
    );
    return duration.inMilliseconds;
  }

}
