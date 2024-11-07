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
    serviceLocator<MediaService>().stopAll();
    _playYoutube(controller.currentSlide);
    slide.majority = _getSlideType(slide);
    final talk = slide.majority as Talk;
    if (slide.majority!.type == ContentType.repeat) {
      listen(talk, initialMedia: _videoData.value);
    } else if (slide.majority!.type == ContentType.wordBank) {
      serviceLocator<DictatorQuiz>().prepare(
        talk: talk,
        onResult: (state, text, score, repeated, data) {
          modal(_resultBuilder(state, data[0], data[1]), isDismissible: false);
          onQiuzResult(state, text, score, talk, repeated, data);
        },
      );
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
    return [
      Widgets.button(
        context,
        width: 52.d,
        height: 52.d,
        padding: EdgeInsets.all(16.d),
        child: Asset.load<SvgPicture>("close"),
        onPressed: () => Navigator.pop(context),
      ),
      SizedBox(width: 8.d),
      progressSliderBuilder(DeviceInfo.size.width * 0.72),
    ];
  }

  @override
  Widget contentBuilder(double paddingTop) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(height: 90.d),
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
              height: _videoData.value == null &&
                      controller.currentSlide.majority!.type !=
                          ContentType.station
                  ? 650.d
                  : 450.d,
              child: PageView.builder(
                controller: _pageController,
                physics: RapidScrollPhysics(),
                itemCount: controller.currentSerie.children.length,
                itemBuilder: (context, index) => _slideRenderer(
                  controller.currentSerie.children[index] as ParentContent,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 30.d),
      ],
    );
  }

  Widget _slideRenderer(ParentContent slide) {
    return Widgets.rect(
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
    final color = switch (content.targetValue) {
      "watch" => TColors.orange,
      "repeat" => TColors.blue,
      _ => TColors.purpule,
    };
    final icon = content.targetValue == "watch" ? "play" : "arrow_right";

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
          onPressed: () => _gotoSlide(true),
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

  void _playYoutube(ParentContent slide) {
    _videoData.value = null;
    final youtubeContents = controller.currentSlide.children
        .where((c) => c.type == ContentType.youtube);
    if (youtubeContents.isEmpty) {
      return;
    }
    _videoData.value =
        MediaIntry.parse(MediaType.youtube, youtubeContents.first.targetValue);

    final captions =
        slide.children.where((c) => c.type == ContentType.caption).toList();
    if (captions.isNotEmpty) {
      serviceLocator<MediaService>().play(_videoData.value!);
      Future.delayed(Duration(milliseconds: 100)).then(
        (s) async {
          final youtube = serviceLocator<MediaService>().youtubeController!;
          youtube.addListener(
            () {
              final seconds = youtube.value.position.inMilliseconds / 1000.0;
              for (var talk in captions) {
                MediaIntry caption = (talk as Talk).data;
                if (caption.start <= seconds && (caption.end ?? 0) > seconds) {
                  this.caption.value = talk;
                  return;
                }
              }
            },
          );
        },
      );
    }
  }

  @override
  void onQiuzResult(QuizState state, String text, int score, Talk talk,
      bool repeated, dynamic data) {}

  Widget _resultBuilder(
    QuizState quizState,
    List<Choice> words,
    List<String> patterns,
  ) {
    final success = quizState == QuizState.success;
    final label = success ? "correct" : "incorrect";
    final color = success ? TColors.green : TColors.red;
    final hints = <TextSpan>[];
    final resulStyle = TStyles.big.copyWith(color: color);
    Widget hintWidget;
    if (success) {
      hintWidget = SizedBox();
    } else {
      for (var i = 0; i < patterns.length; i++) {
        hints.add(
          TextSpan(
            text: "${patterns[i]} ",
            style: words[i].state == ChoiceState.failure
                ? resulStyle
                : TStyles.big,
          ),
        );
      }

      hintWidget = RichText(text: TextSpan(children: hints));
    }

    return Widgets.rect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40.d),
        topRight: Radius.circular(40.d),
      ),
      padding: EdgeInsets.fromLTRB(40.d, 25.d, 40.d, 60.d),
      color: Color.lerp(TColors.primary0, color, 0.15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Asset.load<SvgPicture>(label, width: 24.d),
              SizedBox(width: 10.d),
              Text("${label}_l".l(), style: resulStyle),
            ],
          ),
          SizedBox(height: 12.d),
          hintWidget,
          SizedBox(height: 12.d),
          Widgets.button(
            context,
            alignment: Alignment.center,
            child: Text("next_l".l(), style: TStyles.bigInvert),
            padding: EdgeInsets.all(20.d),
            color: color,
            onPressed: () {
              Navigator.pop(context);
              _gotoSlide(true);
            },
          )
        ],
      ),
    );
  }
}

class RapidScrollPhysics extends ScrollPhysics {
  const RapidScrollPhysics({super.parent});

  @override
  RapidScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return RapidScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring =>
      const SpringDescription(mass: 50, stiffness: 100, damping: 0.8);
}
