import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class LessonScreen extends AbstractScreen {
  LessonScreen({super.key}) : super(Routes.lesson);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<LessonScreen> with LessonMixin {
  final List<Talk> _animatedItems = [];
  final _animatedListKey = GlobalKey<AnimatedListState>();
  final ScrollController _chatScrollController = ScrollController();

  @override
  void initState() {
    var list = Get.arguments["content"].children;
    controller.series = List.generate(list.length, (i) => list[i]);
    controller.slideIndex.addListener(_onChangeSlide);
    controller.contentIndex.addListener(_onChangeLine);
    controller.changeSerie(1);
    super.initState();
  }

  Future<void> _onChangeSlide() async {
    _animatedItems.clear();
    _animatedListKey.currentState
        ?.removeAllItems((context, animation) => const SizedBox());
  }

  Future<void> _onChangeLine() async {
    if (controller.contentIndex.value <= -1) return;
    var talk = controller.currentContent;
    if (talk.isQuiz) {
      _startQuizCallback(talk);
    } else {
      footerHeight.value = 0;
      await _addChat(controller.uniqueIndex);
    }
  }

  Future<void> _addChat(int lastIndex) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (controller.uniqueIndex != lastIndex) return;
    serviceLocator<Sounds>().stopAll();
    var talk = controller.currentContent;
    if (talk.textPresentationMode == PresentMode.none) {
      subtitle.value = talk;
    } else {
      subtitle.value = null;
      _animatedListKey.currentState?.insertItem(_animatedItems.length);
      _animatedItems.add(controller.currentContent);
    }

    await playSound(talk, lastIndex: lastIndex);
    if (controller.uniqueIndex != lastIndex) return;

    controller.changeContent(1);

    // var duration = const Duration(milliseconds: 500);
    // await _chatScrollController.animateTo(
    //     _chatScrollController.position.maxScrollExtent,
    //     duration: duration,
    //     curve: Curves.easeOutQuart);
  }

  Future<void> _startQuizCallback(Talk step) async {
    subtitle.value == null;
    footerHeight.value = 100.d;
    if (!step.isQuiz) return;
    var account = serviceLocator<AccountProvider>();
    serviceLocator<STT>().start(
      locale: account.metadata["targetLanguage"],
      pattern: step.targetValue,
      exceptions: [account.account.user.displayName!.patternize()],
      onResult: _onSTTResult,
    );
  }

  Future<void> _endQuizCallback() async {
    footerHeight.value = 0;
    await _addChat(controller.uniqueIndex);
  }

  Future<void> _onSTTResult(QuizState state, String text) async {
    const duration = Duration(milliseconds: 1500);
    serviceLocator<STT>().stop();
    if (state == QuizState.success) {
      await Future.delayed(duration);
      serviceLocator<STT>().state.value = QuizState.none;
      if (mounted) {
        controller.onQuizResult(true);
      }
      _endQuizCallback();
    } else if (state == QuizState.fail) {
      controller.onQuizResult(false);
      await Future.delayed(duration);
      serviceLocator<STT>().start();
    }
  }

  @override
  Widget navigatorBuilder(double paddingTop, String title) {
    return ValueListenableBuilder(
      valueListenable: controller.contentIndex,
      builder: (context, value, child) {
        return Align(
          alignment: const Alignment(0, 1),
          child: FractionallySizedBox(
            heightFactor: 0.15,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                indicatorBuilder(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _navigationButton(
                      name: "footer_prev",
                      isEnable: controller.slideIndex.value > 0,
                      onPress: () => controller.changeSlide(-1),
                    ),
                    _navigationButton(
                      name: "footer_pause",
                    ),
                    _navigationButton(
                      name: "footer_next",
                      isEnable: value < controller.series.length &&
                          controller.contentIndex.value ==
                              controller.currentSerie.children.length - 1,
                      onPress: () => controller.changeSerie(1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _navigationButton({
    required name,
    bool isEnable = true,
    Function()? onPress,
  }) {
    return Opacity(
      opacity: isEnable ? 1 : 0.4,
      child: Widgets.button(
        context,
        height: 92.d,
        padding: EdgeInsets.all(12.d),
        child: Asset.load<Image>(name),
        onPressed: () {
          // if (isEnable) {
          onPress?.call();
          // }
        },
      ),
    );
  }

  @override
  Widget childBuilder(double paddingTop) {
    return AnimatedList(
      key: _animatedListKey,
      controller: _chatScrollController,
      padding: EdgeInsets.fromLTRB(
          padding, paddingTop + padding * 6, padding, 200.d),
      itemBuilder: (c, i, a) => _animatedItemBuilder(_animatedItems[i], a),
    );
  }

  Widget _animatedItemBuilder(Talk talk, Animation<double> animation) {
    talk.scrollPosition = _chatScrollController.position.pixels;
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
        _ => _chatBuilder(talk),
        // _ => const SizedBox(),
        // ContentType.name => SizedBox(height: 10.d),
      },
    );
  }

  Widget _imageBuilder(Talk talk) {
    final border = BorderRadius.all(Radius.circular(12.d));
    return Widgets.rect(
      decoration: BoxDecoration(
        borderRadius: border,
        border: Border.all(
          width: 2.d,
          color: TColors.primary20,
        ),
        shape: BoxShape.rectangle,
      ),
      padding: EdgeInsets.all(1.d),
      alignment: Alignment.center,
      margin: EdgeInsets.all(24.d),
      child: ClipRRect(
        borderRadius: border,
        child: LoaderWidget(
          AssetType.image,
          talk.targetValue,
          height: 180.d,
        ),
      ),
    );
  }

  Widget _chatBuilder(Talk talk) {
    var tip = switch (talk.type) {
      ContentType.user => BalloonTipPosition.rightBottom,
      ContentType.bot => BalloonTipPosition.leftTop,
      _ => BalloonTipPosition.none,
    };

    var main = talk.textPresentationMode.hasTarget
        ? talk.targetValue
        : talk.nativeValue;
    var translate =
        talk.textPresentationMode == PresentMode.both ? talk.nativeValue : null;
    return RadioBox(
      main,
      ballonPosition: tip,
      narrator: talk.type.narrator,
      translation: translate,
      textStyle: talk.isChat
          ? null
          : (talk.type == ContentType.intro ? TStyles.large : TStyles.small),
      color: talk.isChat
          ? null
          : (talk.type == ContentType.intro
              ? TColors.cream
              : TColors.primary10),
    );
  }

  @override
  Widget footerBuilder() {
    final talk = controller.currentContent;
    final answer = talk.targetValue.toLowerCase();
    final hint = talk.type == ContentType.translate
        ? talk.nativeValue
        : talk.targetValue;
    serviceLocator<Speaker>()
        .play(talk.nativeValue, narrator: talk.type.narrator);
    var footer = Column(children: [
      ListenerBox(
        answer: answer,
        hint: hint,
        narrator: talk.type.narrator,
      ),
      SizedBox(height: 120.d),
    ]);

    // footerSize.value = getFooterHeight(context);
    return footer;
  }

  @override
  void dispose() {
    serviceLocator<Sounds>().stopAll();
    controller.slideIndex.removeListener(_onChangeSlide);
    controller.contentIndex.removeListener(_onChangeLine);
    super.dispose();
  }
}
