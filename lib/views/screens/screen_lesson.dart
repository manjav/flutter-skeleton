import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class LessonScreen extends AbstractScreen {
  LessonScreen({super.key}) : super(Routes.lesson);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<LessonScreen>
    with LessonMixin, ListeningMixin {
  final List<Talk> _animatedItems = [];
  final _animatedListKey = GlobalKey<AnimatedListState>();
  final ScrollController _chatScrollController = ScrollController();

  @override
  void initState() {
    var list = Get.arguments["content"].children;
    controller.series = List.generate(list.length, (i) => list[i]);
    // controller.series[0].children.removeRange(0, 1);
    controller.slideIndex.addListener(_onChangeSlide);
    controller.contentIndex.addListener(_onChangeLine);
    serviceLocator<Speaker>().loadAllSounds(controller.series, () {
      controller.changeSerie(1);
    });
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
      subtitle.value = talk;
    } else {
      subtitle.value = null;
      _animatedListKey.currentState?.insertItem(_animatedItems.length);
      _animatedItems.add(controller.currentContent);
    }

    await playSound(talk, lastIndex: lastIndex);
    if (controller.uniqueIndex != lastIndex) return;
    if (!talk.isQuiz) controller.changeContent(1);

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

    return Widgets.rect(
      color: TColors.primary10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _subtitleBuilder(),
          childBuilder(paddingTop),
          _navigatorBuilder(),
        ],
      ),
    );
  }

  Widget _subtitleBuilder() {
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: Align(
        alignment: const Alignment(0, -0.7),
        child: ValueListenableBuilder(
          valueListenable: subtitle,
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
      alignment: const Alignment(0, 0.8),
      child: ValueListenableBuilder(
        valueListenable: controller.slidePassed,
        builder: (context, value, child) {
          return Visibility(
            visible: value,
            child: SizedBox(
              width: 270.d,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // progressSliderBuilder(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // _navigationButton(
                      //   name: "footer_prev",
                      //   isEnable: controller.slideIndex.value > 0 && value,
                      //   onPress: () => controller.changeSlide(-1),
                      // ),
                      // SizedBox(width: 250.d),
                      _navigationButton(
                        name: "footer_next",
                        isEnable: /* controller.slideIndex.value <
                              controller.currentSerie.children.length && */
                            true,
                        onPress: () => controller.changeSlide(1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
    return Widgets.button(
      context,
      height: 92.d,
      padding: EdgeInsets.all(12.d),
      child: Asset.load<Image>(name),
      onPressed: () {
        if (isEnable) {
          onPress?.call();
        }
      },
    );
  }

  @override
  Widget childBuilder(double paddingTop) {
    return AnimatedList(
      key: _animatedListKey,
      controller: _chatScrollController,
      padding: EdgeInsets.fromLTRB(
          padding, paddingTop + padding * 16, padding, 200.d),
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
        _ => _contentItem(talk),
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

  Widget _contentItem(Talk talk) {
    var tip = switch (talk.type) {
      ContentType.user => BalloonTipPosition.rightBottom,
      ContentType.bot => BalloonTipPosition.leftTop,
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
  Future<void> listen(Talk talk) async {
    subtitle.value == null;
    await super.listen(talk);
  }

  @override
  Future<void> onListeningResult(QuizState state, Talk talk) async {
    const duration = Duration(milliseconds: 500);
    serviceLocator<ListenerQuiz>().stop();
    if (state == QuizState.success) {
      await Future.delayed(duration);
      // serviceLocator<STT>().state.value = QuizState.none;
      if (mounted) {
        controller.onQuizResult(true);
        // _animatedListKey.currentState?.removeItem(_animatedItems.length - 1,
        //     (context, animation) => const SizedBox());
        // _animatedItems.removeLast();
        // talk.type = ContentType.user;
        await Future.delayed(duration);
        // _addChat(controller.uniqueIndex);
        controller.changeContent(1);
      }
    } else if (state == QuizState.failure) {
      controller.onQuizResult(false);
      // await Future.delayed(duration);
      // serviceLocator<STT>().start(activeId: controller.uniqueIndex);
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
