import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_export.dart';

class LessonScreen extends AbstractScreen {
  LessonScreen({super.key}) : super(Routes.lesson);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<LessonScreen>
    with LessonMixin, ListeningMixin, VideoPlayerMixin {
  final List<Talk> _animatedItems = [];
  final _animatedListKey = GlobalKey<AnimatedListState>();
  final ScrollController _chatScrollController = ScrollController();

  @override
  void initState() {
    controller.slideIndex.addListener(_onChangeSlide);
    controller.contentIndex.addListener(_onChangeLine);
    initializeController();
    super.initState();
  }

  Future<void> _onChangeSlide() async {
    for (var i = 0; i <= _animatedItems.length - 1; i++) {
      _animatedListKey.currentState!.removeItem(
        0,
        (BuildContext context, Animation<double> animation) => const SizedBox(),
      );
    }
    _animatedItems.clear();
  }

  Future<void> _onChangeLine() async {
    if (controller.contentIndex.value <= -1) return;
    var talk = controller.currentContent;
    serviceLocator<MediaService>().stopAll();
    stopVideo();
    await _addChat(controller.uniqueIndex);
    if (talk.isQuiz) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (talk.type == ContentType.dictation) {
        serviceLocator<DictatorQuiz>().start(
          talk: talk,
          onResult: (state, text, score, repeated, data) =>
              onQiuzResult(state, text, score, talk, repeated, data),
        );
      } else if (talk.type == ContentType.match) {
        serviceLocator<MatchQuiz>().start(
          talk: talk,
          onResult: (state, text, score, repeated, data) =>
              onQiuzResult(state, text, score, talk, repeated, data),
        );
      } else if (talk.type == ContentType.choices) {
        serviceLocator<ChoiceQuiz>().start(
          talk: talk,
          onResult: (state, text, score, repeated, data) =>
              onQiuzResult(state, text, score, talk, repeated, data),
        );
      } else {
        listen(talk);
      }
    }
    if (!talk.isStation) {
      controller.changeContent(1);
    }
  }

  Future<void> _addChat(int lastIndex) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (controller.uniqueIndex != lastIndex) return;
    var talk = controller.currentContent;
    if (talk.type == ContentType.caption) {
      caption.value = talk;
    } else {
      caption.value = null;
      _animatedListKey.currentState?.insertItem(_animatedItems.length);
      _animatedItems.add(controller.currentContent);
    }

    await playSound(talk, lastIndex: lastIndex);
    await playVideo(talk);
    if (controller.uniqueIndex != lastIndex) return;
  }

  @override
  Widget headerBuilder(double paddingTop) {
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: Align(
        alignment: const Alignment(0, -0.7),
        child: ValueListenableBuilder(
          valueListenable: caption,
          builder: (context, value, child) {
            if (value == null) return const SizedBox();
            return Widgets.button(
              context,
              radius: 16.d,
              padding: EdgeInsets.all(16.d),
              color: TColors.green,
              child: Text(
                value.nativeValue, // text,
                style: TStyles.mediumInvert,
                textDirection: TextDirection.rtl, // dir,
              ),
              onLongPress: () => playSound(value, force: true),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget footerBuilder() {
    return Align(
      alignment: const Alignment(0, 0.9),
      child: ValueListenableBuilder(
        valueListenable: controller.slidePassed,
        builder: (context, value, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              progressSliderBuilder(DeviceInfo.size.width * 0.8),
              Opacity(
                opacity: value ? 1 : 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navigationButton(value, -1),
                    _navigationButton(value, 1),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _navigationButton(bool isEnable, int step) {
    return Widgets.button(
      context,
      height: 92.d,
      padding: EdgeInsets.all(12.d),
      child: Asset.load<Image>("footer_${step > 0 ? "next" : "prev"}"),
      onPressed: () {
        if (isEnable) {
          controller.changeSlide(step);
        }
      },
      onLongPress: () => controller.changeSlide(step),
    );
  }

  @override
  Widget contentBuilder(double paddingTop) {
    return AnimatedList(
      shrinkWrap: true,
      key: _animatedListKey,
      controller: _chatScrollController,
      padding: EdgeInsets.fromLTRB(padding, paddingTop, padding, 100.d),
      itemBuilder: (c, i, a) => _animatedItemBuilder(_animatedItems[i], a),
    );
  }

  Widget _animatedItemBuilder(Talk talk, Animation<double> animation) {
    // talk.scrollPosition = _chatScrollController.position.pixels;
    return ScaleTransition(
      alignment: switch (talk.type) {
        ContentType.user => Alignment.bottomRight,
        ContentType.bot => Alignment.topLeft,
        _ => Alignment.center,
      },
      scale: CurvedAnimation(
        parent: animation.drive(Tween<double>(begin: 0, end: 1)),
        curve: Curves.easeOutBack,
      ),
      child: switch (talk.type) {
        ContentType.image => _imageBuilder(talk),
        ContentType.avatar => _avatarBuilder(talk),
        ContentType.uncover => _uncoverBuilder(talk),
        ContentType.video => videoBuilder(controller),
        // ContentType.youtube => youtubePlayer(controller, talk.targetValue),
        ContentType.dictation => DictationBox(),
        ContentType.wordBank => WordBankBox(talk),
        ContentType.match => MatchBox(),
        ContentType.choices => ChoiceBox(),
        _ => _contentItem(talk),
      },
    );
  }

  Widget _imageBuilder(Talk talk) {
    final border = BorderRadius.all(Radius.circular(12.d));
    final bytes =
        serviceLocator<LessonAssets>().get("${talk.targetValue}.webp");
    return Widgets.rect(
      decoration: BoxDecoration(
        borderRadius: border,
        shape: BoxShape.rectangle,
        border: Border.all(width: 2.d, color: TColors.primary20),
      ),
      padding: EdgeInsets.all(1.d),
      alignment: Alignment.center,
      margin: EdgeInsets.all(24.d),
      child: ClipRRect(
        borderRadius: border,
        child: Image.memory(bytes, gaplessPlayback: true),
      ),
    );
  }

  Widget _uncoverBuilder(Talk talk) {
    final words = talk.targetValue.split(" ");
    final answerWords = List.generate(words.length, (i) => Choice(words[i]));
    return Widgets.rect(
      radius: 24.d,
      color: TColors.primary0,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 80.d),
      child: HiddenWords(answerWords, ValueNotifier<String>("")),
    );
  }

  Widget _avatarBuilder(Talk talk) {
    final expression =
        AvatarExpression.values[talk.version < 0 ? 0 : talk.version];
    return Avatar(
        expression: expression,
        size: expression == AvatarExpression.point ? 150.d : 250.d);
  }

  Widget _contentItem(Talk talk) {
    var tip = switch (talk.type) {
      ContentType.user => BalloonTipPosition.rightBottom,
      ContentType.bot => BalloonTipPosition.leftBottom,
      _ => BalloonTipPosition.none,
    };
    if (talk.isQuiz) {
      return Widgets.rect(
          radius: 24.d,
          height: DeviceInfo.size.width,
          color: TColors.primary0,
          alignment: Alignment.center,
          width: DeviceInfo.size.width,
          margin: EdgeInsets.symmetric(vertical: 5.d),
          padding: EdgeInsets.all(20.d),
          child: microphoneBuilder(talk));
    }
    return RadioBox(
      talk.targetValue, // main,
      ballonPosition: tip,
      narrator: talk.narrator,
      translation: talk.nativeValue, // translate,
      textStyle: talk.isChat
          ? null
          : (talk.type == ContentType.head ? TStyles.large : TStyles.small),
      color: talk.isChat
          ? null
          : (talk.type == ContentType.head ? TColors.cream : TColors.primary10),
    );
  }

  @override
  void onQiuzResult(
    QuizState state,
    String text,
    int score,
    Talk talk,
    bool repeated,
    dynamic data,
  ) {
    controller.onQuizResult(state, text, score, talk);
    if (state == QuizState.success && !repeated) {
      controller.changeContent(1);
    }
  }

  @override
  void dispose() {
    serviceLocator<MediaService>().stopAll();
    controller.slideIndex.removeListener(_onChangeSlide);
    controller.contentIndex.removeListener(_onChangeLine);
    super.dispose();
  }
}
