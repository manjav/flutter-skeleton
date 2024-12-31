import 'dart:async';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../app_export.dart';

class ImitationScreen extends AbstractScreen {
  ImitationScreen({super.key}) : super(Routes.imitation);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<ImitationScreen>
    with LessonMixin, ListeningMixin, VideoPlayerMixin {
  List<Content> _captions = [];
  final PageController _pageController = PageController();
  final ValueNotifier<int> _slideUpdater = ValueNotifier(-1);
  final ValueNotifier<bool> _captionMode = ValueNotifier(true);
  final ValueNotifier<MediaEntry?> _videoData = ValueNotifier(null);
  final ItemScrollController _captionScrollController = ItemScrollController();

  @override
  void initState() {
    final media = serviceLocator<MediaService>();
    _pageController.addListener(
      () {
        if (controller.currentSlide.majority!.type == ContentType.repeat &&
            media.youtubeController != null &&
            media.youtubeController!.value.playerState == PlayerState.playing) {
          media.youtubeController!.pause();
          media.autoStart = false;
        }
        _changePage((_pageController.page ?? 0).round());
      },
    );
    controller.serieIndex.addListener(_onSerieChange);
    controller.slideIndex.addListener(_onSlideChange);
    initializeController();
    super.initState();
  }

  void _changePage(int index) {
    if (index == controller.slideIndex.value) {
      return;
    }
    _logTrackerEvent(
        controller.slideIndex.value < index ? "bt_next" : "bt_prev");
    controller.slideIndex.value = index;
  }

  void _onSerieChange() {
    serviceLocator<MediaService>().autoStart = true;
    controller.currentSerie.majority = _getSerieType(controller.currentSerie);

    _logTrackerEvent("pv", params: {});
    Future.delayed(Duration(milliseconds: 0), _initYoutube);
  }

  void _onSlideChange() {
    if (controller.slideIndex.value < 0) return;

    final slide = controller.currentSlide;
    slide.majority = _getSlideType(slide);
    final talk = slide.majority as Talk;
    if (talk.type == ContentType.repeat) {
      listen(talk, initialMedia: talk.data);
    } else if (slide.majority!.type == ContentType.wordBank) {
      serviceLocator<DictatorQuiz>().prepare(
        talk: talk,
        initialMedia: talk.data,
        onResult: (state, text, score, repeated, data) =>
            onQiuzResult(state, text, score, talk, repeated, data),
      );
    }
    _slideUpdater.value = controller.slideIndex.value;
  }

  Content? _getSerieType(ParentContent serie) =>
      (serie.children.first as ParentContent).children.first;

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

  void _gotoSlide(bool isNext) {
    final duration = Duration(milliseconds: 100);
    if (isNext) {
      if (controller.slideIndex.value >=
          controller.currentSerie.children.length - 1) {
        controller.callCompletedMethod();
        return;
      }
      _pageController.nextPage(duration: duration, curve: Curves.easeInOut);
    } else {
      _pageController.previousPage(duration: duration, curve: Curves.easeInOut);
    }
  }

  @override
  List<Widget> appBarElementsLeft() {
    var inOnboarding = serviceLocator<AccountProvider>().inOnboarding;
    return [
      inOnboarding
          ? SizedBox(height: 52.d)
          : Widgets.button(
              context,
              width: 52.d,
              height: 52.d,
              padding: EdgeInsets.all(16.d),
              child: Asset.load<SvgPicture>("close"),
              onPressed: () {
                _logTrackerEvent("bt_close");
                onPopInvoked(true, null);
              },
            ),
      SizedBox(width: 8.d),
      progressSliderBuilder(
        DeviceInfo.size.width * (inOnboarding ? 0.9 : 0.72),
      ),
    ];
  }

  @override
  Widget contentBuilder(double paddingTop) {
    return ValueListenableBuilder(
      valueListenable: controller.serieIndex,
      builder: (context, value, child) {
        final isFirstStation = _isFirstStation();
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: paddingTop + 44.d),
            _videoData.value == null
                ? SizedBox(height: isFirstStation ? 220.d : 0)
                : youtubePlayer(
                    showProgressbar: controller.currentSlide.majority!.type ==
                        ContentType.caption),
            ListenableBuilder(
              listenable: _slideUpdater,
              builder: (context, child) {
                return Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: serviceLocator<ListenerQuiz>().state,
                    builder: (context, value, child) {
                      // print(value);
                      return PageView.builder(
                        controller: _pageController,
                        physics: value == QuizState.running
                            ? NeverScrollableScrollPhysics()
                            : RapidScrollPhysics(),
                        itemCount: controller.currentSerie.children.length,
                        itemBuilder: (context, index) => _slideRenderer(
                          controller.currentSerie.children[index]
                              as ParentContent,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: controller.slideIndex,
              builder: (context, value, child) {
                if (value < 0 || controller.currentSerie.children.length < 2) {
                  return SizedBox();
                }
                return DotsIndicator(
                  decorator: DotsDecorator(
                    size: Size.square(6.d),
                    activeSize: Size.square(8.d),
                    color: TColors.primary20,
                    activeColor: TColors.primary40,
                  ),
                  dotsCount: controller.currentSerie.children.length,
                  position: controller.slideIndex.value,
                );
              },
            ),
            SizedBox(height: 30.d),
          ],
        );
      },
    );
  }

  bool _isFirstStation() {
    return controller.currentSerie.children.length == 1 &&
        controller.currentSlide.majority!.type == ContentType.station;
  }

  Widget _slideRenderer(ParentContent slide) {
    return Widgets.rect(
      margin: EdgeInsets.all(24.d),
      padding: EdgeInsets.all(20.d),
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
      ContentType.repeat =>
        microphoneBuilder(controller, slide.majority as Talk),
      ContentType.station => _stationSlideBuilder(slide.majority as Talk),
      ContentType.caption => _captionSlideBuilder(),
      _ => SizedBox(),
    };
  }

  Widget _stationSlideBuilder(Talk content) {
    final label = "station_${content.targetValue}";
    final color = switch (content.targetValue) {
      "watch" => TColors.orange,
      "repeat" => TColors.blue,
      _ => TColors.purpule,
    };
    final icon = content.targetValue == "watch" ? "play" : "arrow_right";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LoaderWidget(AssetType.vector, label, height: 170.d),
        Text(label.l(), style: TStyles.largeDetails),
        Expanded(child: SizedBox()),
        SkinnedButton(
          color: color,
          child: Row(
            textDirection: content.targetValue == "watch"
                ? TextDirection.rtl
                : TextDirection.ltr,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${label}_btn".l(), style: TStyles.bigInvert),
              SizedBox(width: 10.d),
              Asset.load<SvgPicture>(icon, width: 20.d),
            ],
          ),
          onPressed: () async {
            _logTrackerEvent("bt_submit");
            controller.changeSlide(1);
            _pageController.jumpTo(0);
            _onSlideChange();
          },
        ),
      ],
    );
  }

  Widget _captionSlideBuilder() {
    return ValueListenableBuilder(
      valueListenable: _captionMode,
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _captionBuilder(value),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _captionButton("reset", TColors.transparent, onPress: () {
                  _logTrackerEvent("bt_reply");
                  serviceLocator<MediaService>().playYoutube(_videoData.value!);
                }),
                _captionButton(
                    "cc", value ? TColors.primary90 : TColors.transparent,
                    onPress: () {
                  _logTrackerEvent("bt_cc");
                  _captionMode.value = !_captionMode.value;
                }),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _captionBuilder(bool captionMode) {
    return Center(
      child: ValueListenableBuilder(
        valueListenable: caption,
        builder: (context, value, child) {
          if (!captionMode) {
            return LoaderWidget(AssetType.vector, "ear");
          }
          if (!(serviceLocator<Trackers>()
                  .remoteConfigs["scrollableCaptions"] ??
              false)) {
            return value == null
                ? SizedBox()
                : Text(
                    value.targetValue.simplify(),
                    style: TStyles.big,
                  );
          }
          if (value != null) {
            var index = _captions.indexOf(value);
            if (_captionScrollController.isAttached) {
              _captionScrollController.scrollTo(
                  index: index,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  alignment: 0.35);
            }
          }
          return ShaderMask(
            shaderCallback: (Rect rect) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  TColors.white,
                  TColors.transparent,
                  TColors.transparent,
                  TColors.white
                ],
                stops: [
                  0.0,
                  0.4,
                  0.5,
                  1.0
                ], // 10% purple, 80% transparent, 10% purple
              ).createShader(rect);
            },
            blendMode: BlendMode.dstOut,
            child: ScrollablePositionedList.builder(
              physics: NeverScrollableScrollPhysics(),
              padding:
                  EdgeInsets.symmetric(vertical: DeviceInfo.size.width * 0.5),
              itemScrollController: _captionScrollController,
              itemBuilder: (context, index) {
                var data = _captions[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.d),
                  child: Text(
                    data.targetValue.simplify(),
                    textAlign: TextAlign.center,
                    style: data == value ? TStyles.big : TStyles.largeDetails,
                  ),
                );
              },
              itemCount: _captions.length,
            ),
          );
        },
      ),
    );
  }

  Widget _captionButton(String icon, Color color, {Function()? onPress}) {
    return Widgets.button(
      context,
      sfx: "",
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

  void _initYoutube() {
    final media = serviceLocator<MediaService>();
    _videoData.value = null;

    if (controller.currentSerie.iconUrl.isEmpty) {
      media.youtubeController?.dispose();
      media.youtubeController = null;
      return;
    }
    _videoData.value =
        MediaEntry.parse(MediaType.youtube, controller.currentSerie.iconUrl);
    media.initYoutube(_videoData.value!);
    _getCaptions();
  }

  void _getCaptions() {
    final media = serviceLocator<MediaService>();
    final captions = controller.currentSlide.children
        .where((c) => c.type == ContentType.caption);
    if (captions.isEmpty) {
      return;
    }
    _captions = captions.toList();
    media.play(_videoData.value!);
    _videoData.value!.onPositionChanged.listen(_findProperCaption);
  }

  void _findProperCaption(Duration position) {
    final seconds = position.inMilliseconds / 1000.0 + _videoData.value!.start;
    if (_videoData.value!.positionRatio >= 1 &&
        controller.slideIndex.value == 0) {
      _gotoSlide(true);
      return;
    }
    for (var talk in _captions) {
      MediaEntry caption = (talk as Talk).data;
      if (caption.start <= seconds && (caption.end ?? 0) > seconds) {
        this.caption.value = talk;
        return;
      }
    }
  }

  @override
  void onQiuzResult(QuizState state, String text, int score, Talk talk,
      bool repeated, dynamic data) {
    if (controller.currentSerie.majority!.type == ContentType.wordBank) {
      if (talk.type == ContentType.wordBank) {
        _showWordBankResult(state, data[0], data[1]);
      } else {
        _showListenerResult(state);
      }
    }

    controller.onQuizResult(state, text, score, talk);
  }

  void _showWordBankResult(
    QuizState quizState,
    List<Choice> words,
    List<String> patterns,
  ) {
    _logTrackerEvent("bt_ok");
    final success = quizState == QuizState.success;
    final label = success ? "correct" : "incorrect";
    final color = success ? TColors.green : TColors.red;
    final hints = <TextSpan>[];
    final incorrectStyle = TStyles.big.copyWith(color: TColors.blue);
    Widget hintWidget;
    if (success) {
      hintWidget = SizedBox();
    } else {
      for (var i = 0; i < patterns.length; i++) {
        hints.add(
          TextSpan(
            text: "${patterns[i]} ",
            style: words[i].state == ChoiceState.failure
                ? incorrectStyle
                : TStyles.big,
          ),
        );
      }
      hintWidget = RichText(text: TextSpan(children: hints));
    }

    modal(
      [
        Row(
          children: [
            Asset.load<SvgPicture>(label, width: 24.d),
            SizedBox(width: 10.d),
            Text("${label}_l".l(), style: TStyles.big.copyWith(color: color)),
          ],
        ),
        hintWidget,
        SizedBox(height: 10.d),
        AutoCallButton(
          color: color,
          label: "next_l".l(),
          onPressed: () => _gotoSlide(true),
        ),
      ],
      isDismissible: false,
      backgroundColor: Color.lerp(TColors.primary0, color, 0.15),
    );
  }

  void _showListenerResult(QuizState state) {
    if (state != QuizState.success) {
      return;
    }
    modal(
      [
        AutoCallButton(
          label: "next_l".l(),
          color: TColors.green,
          onPressed: () {
            Navigator.pop(context);
            _gotoSlide(true);
          },
        ),
      ],
      isDismissible: false,
      barrierColor: TColors.black40,
    );
  }

  @override
  Future<void> onPopInvoked(bool didPop, dynamic data) async {
    if (!didPop) return;
    if (controller.serieIndex.value < 2) {
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }
    controller.callCompletedMethod(showFeast: false);
  }

  @override
  void dispose() {
    serviceLocator<MediaService>().youtubeController?.dispose();
    serviceLocator<MediaService>().youtubeController = null;
    controller.serieIndex.removeListener(_onSerieChange);
    controller.slideIndex.removeListener(_onSlideChange);
    super.dispose();
  }

  void _logTrackerEvent(String name, {Map<String, dynamic>? params}) {
    try {
      params ??= <String, dynamic>{
        "video_id": controller.root!.iconUrl,
        "slide_index": controller.currentSlide.index,
        "slide": controller.currentSlide.majority!.type.name,
      };
      params["in_onboarding"] =
          "${serviceLocator<AccountProvider>().inOnboarding}";

      final type = controller.currentSerie.majority!.type;
      if (type == ContentType.caption) {
        params["cc"] = _captionMode.value ? "on" : "off";
        if (_videoData.value?.positionRatio == null) {
          params["position_ratio"] = -1;
        } else {
          params["position_ratio"] =
              ((_videoData.value?.positionRatio ?? 0) * 100).round();
        }
      }
      serviceLocator<Trackers>()
          .design("$name|${type.name}", parameters: params);
    } catch (e) {
      log(e.toString());
    }
  }
}

class RapidScrollPhysics extends ScrollPhysics {
  const RapidScrollPhysics({super.parent});

  @override
  RapidScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      RapidScrollPhysics(parent: buildParent(ancestor)!);

  @override
  SpringDescription get spring =>
      const SpringDescription(mass: 50, stiffness: 100, damping: 0.8);
}
