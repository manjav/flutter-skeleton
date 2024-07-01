import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class SeriesScreen extends AbstractScreen {
  SeriesScreen({super.key}) : super(Routes.series);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<SeriesScreen> with LessonMixin {
  final List<ParentContent> _animatedItems = [];
  final _animatedListKey = GlobalKey<AnimatedListState>();
  final ScrollController _chatScrollController = ScrollController();

  @override
  void initState() {
    var list = Get.arguments["content"].children;
    controller.series = List.generate(list.length, (i) => list[i]);
    controller.serieIndex.addListener(_onChangeSerie);
    controller.slideIndex.addListener(_onChangeSlide);
    controller.changeSerie(1);
    super.initState();
  }

  Future<void> _onChangeSerie() async {
    _animatedItems.clear();
    _animatedListKey.currentState
        ?.removeAllItems((context, animation) => const SizedBox());
  }

  Future<void> _onChangeSlide() async {
    if (controller.slideIndex.value <= -1) return;
    if (_animatedItems.isEmpty) {
      _animatedListKey.currentState?.insertItem(_animatedItems.length);
      _animatedItems
          .add(ParentContent.create(null, ContentType.category, "", {}));
    }
    _animatedListKey.currentState?.insertItem(_animatedItems.length - 1);
    _animatedItems.insert(_animatedItems.length - 1, controller.currentSlide);

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
  Widget childBuilder(double paddingTop) {
    return AnimatedList(
      key: _animatedListKey,
      controller: _chatScrollController,
      padding: EdgeInsets.fromLTRB(
          padding, paddingTop + padding * 6, padding, 200.d),
        itemBuilder: (c, i, a) {
          final slide = _animatedItems[i];
          var items = <Widget>[];
          for (var c = 0; c < slide.children.length; c++) {
            items.add(_contentItem(slide.children[c] as Talk));
            items.add(SizedBox(height: 12.d));
          }

          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: const Offset(0, 0),
            ).animate(a),
            child: Widgets.rect(
              radius: 24.d,
              height: 320.d,
              color: TColors.primary0,
              width: DeviceInfo.size.width,
              margin: EdgeInsets.symmetric(vertical: 5.d),
              padding: EdgeInsets.symmetric(horizontal: 32.d),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, children: items),
            ),
          );
        });
  }

  Widget _contentItem(Talk talk) {
    return switch (talk.type) {
        ContentType.image => _imageBuilder(talk),
      ContentType.head => DirText(
          talk.nativeValue,
          style: TStyles.big,
          textAlign: TextAlign.center,
        ),
      _ => DirText(
          talk.nativeValue,
          textAlign: TextAlign.center,
        ),
    };
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

    return RadioBox(
      talk.targetValue, //main,
      ballonPosition: tip,
      narrator: talk.type.narrator,
      translation: talk.nativeValue, //translate,
      textStyle: talk.isChat
          ? null
          : (talk.type == ContentType.head ? TStyles.large : TStyles.small),
      color: talk.isChat
          ? null
          : (talk.type == ContentType.head ? TColors.cream : TColors.primary10),
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
    controller.serieIndex.removeListener(_onChangeSerie);
    controller.slideIndex.removeListener(_onChangeSlide);
    super.dispose();
  }
}
