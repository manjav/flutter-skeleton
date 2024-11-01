import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_export.dart';

class ImitationScreen extends AbstractScreen {
  ImitationScreen({super.key}) : super(Routes.imitation);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<ImitationScreen>
    with LessonMixin, ListeningMixin, VideoPlayerMixin {
  final List<MediaIntry> _captions = [];
  final ValueNotifier<int> _slideUpdater = ValueNotifier(-1);
  final PageController _pageController = PageController();
  final ValueNotifier<bool> _captionMode = ValueNotifier(false);
  final ValueNotifier<MediaIntry?> _videoData = ValueNotifier(null);

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
    final slide = controller.currentSlide;
    _playYoutube(controller.currentSlide);
    slide.majority = _getSlideType(slide);
    final talk = slide.majority as Talk;
    if (slide.majority!.type == ContentType.repeat) {
      listen(talk, initialMedia: _videoData.value);
    } else if (slide.majority!.type == ContentType.wordBank) {
      serviceLocator<DictatorQuiz>().start(talk: talk);
    }
    _slideUpdater.value = controller.slideIndex.value;
  }

  Content? _getSlideType(ParentContent slide) {
    final first = slide.children.first;
    if (first.type == ContentType.station ||
        first.type == ContentType.wordBank) {
      return first;
    }
    final repeats = slide.children.where((t) => t.type == ContentType.repeat);
    if (repeats.isNotEmpty) {
      return repeats.first;
    }
    final captions = slide.children.where((t) => t.type == ContentType.caption);
    if (captions.isNotEmpty) {
      return captions.first;
    }
    return null;
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
        ListenableBuilder(
          listenable: _slideUpdater,
          builder: (context, child) {
            return SizedBox(
              height: _videoData.value == null ? 600.d : 450.d,
              child: PageView.builder(
                controller: _pageController,
                itemCount: controller.currentSerie.children.length,
                itemBuilder: (context, index) => _slideRenderer(
                  controller.currentSerie.children[index] as ParentContent,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 100.d),
      ],
    );
  }

  Widget _slideRenderer(ParentContent slide) {
    return Container(
      margin: EdgeInsets.all(30.d),
      padding: EdgeInsets.all(30.d),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: slide.majority?.type == ContentType.station
            ? TColors.transparent
            : TColors.primary0,
        border: Border.all(color: TColors.primary20, width: 2.d),
        borderRadius: BorderRadius.all(Radius.circular(20.d)),
      ),
      child: _getContent(slide),
    );
  }

  Widget _getContent(ParentContent slide) {
    if (slide.majority == null) {
      return SizedBox();
    }
    return switch (slide.majority!.type) {
      ContentType.wordBank => WordBankBox(slide.majority as Talk),
      ContentType.repeat => MicPanel(talk: slide.majority as Talk),
      ContentType.station => _stationSlideBuilder(slide.majority as Talk),
      ContentType.caption => _captionSlideBuilder(),
      _ => SizedBox(),
    };
  }

  Widget _stationSlideBuilder(Talk content) {
    final label = "station_${content.targetValue}";
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LoaderWidget(
          AssetType.vector,
          label,
          height: 170.d,
        ),
        Text(label.l(),
            style: TStyles.large.copyWith(color: TColors.primary30)),
        SizedBox(height: 60.d),
        Widgets.button(
          context,
          padding: EdgeInsets.symmetric(vertical: 14.d, horizontal: 50.d),
          color: TColors.primary90,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${label}_btn".l(), style: TStyles.bigInvert),
              SizedBox(width: 6.d),
              Asset.load<SvgPicture>("arrow_right"),
            ],
          ),
          onPressed: _nextSlide,
        ),
      ],
    );
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
                  serviceLocator<MediaService>().playYoutube(_videoData.value!);
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

  void _playYoutube(ParentContent slide) {
    _videoData.value = null;
    final youtubeContents = controller.currentSlide.children
        .where((c) => c.type == ContentType.youtube);
    _captions.clear();
    if (youtubeContents.isEmpty) {
      return;
    }
    _videoData.value =
        MediaIntry.parse(MediaType.youtube, youtubeContents.first.targetValue);

    final list =
        slide.children.where((c) => c.type == ContentType.caption).toList();
    for (var caption in list) {
      var seconds = _getMilliSeconds(caption.nativeValue);
      _captions.add(MediaIntry(
        MediaType.youtube,
        "",
        start: _captions.lastOrNull != null ? _captions.last.end ?? 0 : 0,
        end: seconds,
      )..data = caption);
    }
    if (_captions.isNotEmpty) {
      serviceLocator<MediaService>().play(_videoData.value!);
      Future.delayed(Duration(milliseconds: 100)).then(
        (s) async {
          final youtube = serviceLocator<MediaService>().youtubeController!;
          youtube.addListener(
            () {
              final milliseconds = youtube.value.position.inMilliseconds;
              for (var caption in _captions) {
                if (caption.start <= milliseconds &&
                    (caption.end ?? 0) > milliseconds) {
                  this.caption.value = caption.data;
                  return;
                }
              }
            },
          );
          // _nextSlide();
        },
      );
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

  @override
  void onListeningResult(
      QuizState state, String text, int score, Talk talk, bool repeated) {}
}
