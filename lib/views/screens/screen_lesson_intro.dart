import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class LessonIntroScreen extends AbstractScreen {
  LessonIntroScreen({super.key}) : super(Routes.intro);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<LessonIntroScreen>
    with LessonMixin {
  final List<Talk> _animatedItems = [];
  final _animatedListKey = GlobalKey<AnimatedListState>();
  final ScrollController _chatScrollController = ScrollController();

  @override
  void initState() {
    controller.topics = Get.arguments["content"].children;
    // controller.onQuizStart = _startQuizCallback;
    // controller.onQuizEnd = _endQuizCallback;
    controller.onContentChange = _contentChangeCallback;
    controller.topicIndex.addListener(_onChangeStep);
    controller.changeTopic(1);
    super.initState();
  }

  Future<void> _contentChangeCallback() async {
    await Future.delayed(const Duration(milliseconds: 500));
    var talk = controller.currentContent;
    if (talk.isQuiz) {
      _startQuizCallback(talk);
    } else {
      await _addChat();
      if (talk.personId == "explanation" ||
          talk.personId == "card" ||
          talk.isChat) {
        await serviceLocator<Speaker>().play(
            talk.personId == "explanation"
                ? talk.nativeValue
                : talk.targetValue,
            narrator: talk.isChat ? Narrator.alloy : Narrator.onyx);
      }
      controller.changeContent(1);
    }
  }

  Future<void> _onChangeStep() async {
    // serviceLocator<Sounds>().stopAll();
    _animatedItems.clear();
    _animatedListKey.currentState
        ?.removeAllItems((context, animation) => const SizedBox());
  }

  @override
  Widget navigatorBuilder(double paddingTop, String title) {
    return ValueListenableBuilder(
      valueListenable: controller.contentIndex,
      builder: (context, value, child) {
        return Align(
          alignment: const Alignment(0, 1),
          child: FractionallySizedBox(
            heightFactor: 0.25,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _slidination(
                    controller.topicIndex.value, controller.topics.length),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _navigationButton(
                      name: "footer_prev",
                      isEnable: controller.topicIndex.value > 0,
                      onPress: () => controller.changeTopic(-1),
                    ),
                    _navigationButton(
                      name: "footer_pause",
                    ),
                    _navigationButton(
                      name: "footer_next",
                      isEnable: value < controller.topics.length &&
                          controller.contentIndex.value ==
                              controller.contents.length - 1,
                      onPress: () => controller.changeTopic(1),
                    ),
                  ],
                ),
                SizedBox(height: 32.d)
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _slidination(int value, int length) {
    final margin = 3.d;
    final width = (DeviceInfo.size.width - margin * 12) / length - margin * 2;
    return SizedBox(
      height: 10.d,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: margin * 6),
        scrollDirection: Axis.horizontal,
        itemCount: length,
        itemBuilder: (context, index) {
          return Widgets.rect(
            radius: 4.d,
            width: width,
            height: margin,
            margin: EdgeInsets.all(margin),
            color: index <= value ? TColors.white : TColors.primary20,
          );
        },
      ),
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
        padding: EdgeInsets.all(32.d),
        child: Asset.load<Image>(name),
        onPressed: () {
          if (isEnable) {
            onPress?.call();
          }
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
      child: switch (talk.personId) {
        "intro" => _imageBuilder(talk),
        "card" => _phraseBuilder(talk),
        _ => _chatBuilder(talk),
        // _ => const SizedBox(),
        // ContentType.name => SizedBox(height: 10.d),
      },
    );
  }

  Widget _phraseBuilder(Talk talk) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DirText(talk.targetValue, style: TStyles.big),
          DirText(talk.nativeValue,
              style: TStyles.medium.copyWith(color: TColors.primary50)),
        ],
      );

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

    var isTarget = talk.isChat || talk.isName;
    var main = isTarget ? talk.targetValue : talk.nativeValue;
    var translate = isTarget ? talk.nativeValue : null;
    return RadioBox(
      main,
      ballonPosition: tip,
      narrator: talk.type.narrator,
      translation: translate,
      textStyle:
          talk.isChat ? null : (talk.isName ? TStyles.large : TStyles.small),
      color: talk.isChat
          ? null
          : (talk.isName ? TColors.cream : TColors.primary10),
    );
  }

  Future<void> _addChat() async {
    // var duration = const Duration(milliseconds: 500);
    _animatedListKey.currentState?.insertItem(_animatedItems.length);
    _animatedItems.add(controller.currentContent);
    // await _chatScrollController.animateTo(
    //     _chatScrollController.position.maxScrollExtent,
    //     duration: duration,
    //     curve: Curves.easeOutQuart);
  }

  Future<void> _startQuizCallback(Talk step) async {
    footerHeight.value = 100.d;
    if (!step.isQuiz) return;
    var account = serviceLocator<AccountProvider>();
    serviceLocator<STT>().start(
      locale: account.metadata["targetLanguage"],
      pattern: step.targetValue,
      exceptions: [account.account.user.displayName!.simple()],
      onResult: _onSTTResult,
    );
    // await Future.delayed(const Duration(milliseconds: 1200));
    // _endQuizCallback();
  }

  Future<void> _endQuizCallback() async {
    footerHeight.value = 0;

    await _addChat();
    setState(() {});
    // var step = controller.currentContent;
    // footerSize.value = 0;

    // if (step.isQuiz || step.type == ContentType.image) {
    //   await Future.delayed(const Duration(milliseconds: 10));
    // } else {
    //   final text =
    //       step.isChat || step.isName ? step.targetValue : step.nativeValue;
    //   if (step.isChat || step.isName) {
    //     final narrator = step.isName
    //         ? Narrator.nova
    //         : step.isChat
    //             ? Narrator.fable
    //             : Narrator.onyx;
    //     serviceLocator<Speaker>().play(text, narrator: narrator);
    //   } else {
    //     duration = Duration(milliseconds: text.length * 40);
    //   }
    // }

    // await Future.delayed(duration);
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
  Widget footerBuilder() {
    var footer = Column(children: [
      DirText(controller.practice,
          textAlign: TextAlign.center, style: TStyles.small),
      SizedBox(height: 24.d),
      ListenerBox(controller.currentContent,
          challengeMode: Get.arguments["challengeMode"] ?? false)
    ]);

    // footerSize.value = getFooterHeight(context);
    return footer;
  }
}
