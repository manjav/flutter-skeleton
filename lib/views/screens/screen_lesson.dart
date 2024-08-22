import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    // List list = Get.arguments["content"].children[0].children;
    // list.removeRange(0, list.length - 8);
    trackerParams = {"id": Get.arguments["content"]!.id};
    controller.init(Get.arguments["content"]);
    controller.onComplete = _onSerieComplete;
    controller.slideIndex.addListener(_onChangeSlide);
    controller.contentIndex.addListener(_onChangeLine);
    serviceLocator<Speaker>().loadAllSounds(
      series: controller.series,
      onComplete: () {
        if (mounted) {
          controller.changeSerie(1);
          setState(() {});
        }
      },
      onProgress: (p) => progressInput?.value = p * 100,
      onError: (message) async {
        await Get.toNamed(Routes.popupMessage, arguments: {"title": message});
        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
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
    if (talk.isQuiz) {
      listen(talk);
    }
    await _addChat(controller.uniqueIndex);
  }

  Future<void> _addChat(int lastIndex) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (controller.uniqueIndex != lastIndex) return;
    serviceLocator<Sounds>().stopAll();
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
    if (!talk.isStation) controller.changeContent(1);

    // var duration = const Duration(milliseconds: 500);
    // await _chatScrollController.animateTo(
    //     _chatScrollController.position.maxScrollExtent,
    //     duration: duration,
    //     curve: Curves.easeOutQuart);
  }

  @override
  Widget contentFactory(double paddingTop) {
    if (controller.series.isEmpty) {
      return const SizedBox();
    }

    if (controller.serieIndex.value < 0) {
      return loadingProgressbarBuilder();
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        childBuilder(paddingTop),
        _captionBuilder(),
        _navigatorBuilder(),
      ],
    );
  }

  Widget _captionBuilder() {
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

  Widget _navigatorBuilder() {
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
  Widget childBuilder(double paddingTop) {
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
        ContentType.video => videoBuilder(controller, talk),
        _ => _contentItem(talk),
      },
    );
  }

  Widget _imageBuilder(Talk talk) {
    final border = BorderRadius.all(Radius.circular(12.d));
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
        child: LoaderWidget(AssetType.image, talk.targetValue),
      ),
    );
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
          height: 400.d,
          color: TColors.primary0,
          alignment: Alignment.center,
          width: DeviceInfo.size.width,
          margin: EdgeInsets.symmetric(vertical: 5.d),
          padding: EdgeInsets.symmetric(horizontal: 20.d),
          child: listenerBuilder(talk));
    }
    return RadioBox(
      talk.targetValue, // main,
      ballonPosition: tip,
      narrator: talk.type.narrator,
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
  Future<void> listen(Talk talk, {bool autoStart = true}) async {
    caption.value == null;
    await super.listen(talk);
  }

  @override
  void onListeningResult(QuizState state, String text, int score, Talk talk) {
    if (state == QuizState.success) {
      controller.changeContent(1);
    }
    controller.onQuizResult(score, text, talk);
  }

  Future<void> _onSerieComplete(
      int sentenceCount, int quizCount, int score) async {
    await Get.toNamed(Routes.popupResult, arguments: {
      "id": controller.root!.id,
      "score": score,
      "quizCount": quizCount,
      "sentenceCount": sentenceCount
    });
    if (mounted) {
      Navigator.pop(context);
      showFeedback();
    }
  }

  @override
  void dispose() {
    serviceLocator<Sounds>().stopAll();
    controller.slideIndex.removeListener(_onChangeSlide);
    controller.contentIndex.removeListener(_onChangeLine);
    super.dispose();
  }
}
