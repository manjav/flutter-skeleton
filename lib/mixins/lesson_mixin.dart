import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_export.dart';

mixin LessonMixin<S extends AbstractScreen>
    on AbstractScreenState<S>, HeaderMixin {
  ParentContent? content;
  final GlobalKey<AnimatedListState> _chatListKey =
      GlobalKey<AnimatedListState>();

  int _fouls = 0, _streakCorrects = 0, _maxCorrects = 0;
  final List<Talk> _chatItems = [];
  final ValueNotifier<int> index = ValueNotifier(0);
  final ValueNotifier<double> inputSize = ValueNotifier(0);
  final ScrollController _chatScrollController = ScrollController();

  final GlobalKey _footerKey = GlobalKey();

  @override
  void initState() {
    content = Get.arguments["content"];
    nextStep();
    super.initState();
  }

  Future<void> nextStep() async {
    if (index.value >= content!.children.length) {
      var len = (content!.children.length / 2).round();
      var corrects = len - _fouls.max(5);
      print(
          "${corrects * 100 / len}% $corrects $_maxCorrects $len   ${3 - _fouls.max(2)}");
      await _delay(500);
      if (mounted) {
        // Navigator.pop(context, 3 - _fouls.max(2));
      }
      return;
    }
    var talk = content!.children[index.value] as Talk;
    if (await _delay(500)) return;
    index.value += 1;
    await _insertChat(talk);

    await serviceLocator<Speaker>()
        .play(talk.targetValue, narrator: talk.type.narrator);

    talk = content!.children[index.value] as Talk;
    inputSize.value = _getFooterHeight();
    // await serviceLocator<Speaker>()
    //     .play(currentTalk!.targetValue, narrator: currentTalk!.type.narrator);
    startQuiz(talk);
  }

  @override
  List<Widget> appBarElementsLeft() => [];

  @override
  Widget contentFactory(double paddingTop) {
    if (content == null) {
      return const SizedBox();
    }

    var padding = 12.d;
    return Stack(
      children: [
        AnimatedList(
            key: _chatListKey,
            controller: _chatScrollController,
            padding: EdgeInsets.fromLTRB(
                padding, paddingTop + padding * 6, padding, _getFooterHeight()),
            itemBuilder: (c, i, a) => _chatItemBuilder(_chatItems[i], a)),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 76.d,
          child: headerBuilder(context, index,
              EdgeInsets.fromLTRB(padding, padding, padding, 0), content!),
        ),
        ValueListenableBuilder(
            valueListenable: inputSize,
            builder: (context, value, child) {
              return AnimatedPositioned(
                left: 0,
                right: 0,
                top: DeviceInfo.size.height - value,
                curve: value == 0 ? Curves.easeIn : Curves.easeOutBack,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: _footerKey,
                  decoration: BoxDecoration(
                    color: TColors.primary0,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32.d),
                      topRight: Radius.circular(32.d),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: TColors.primary20,
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, -2.d), // changes position of shadow
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(padding),
                  child: footerBuilder(),
                ),
              );
            })
      ],
    );
  }

  Widget footerBuilder() => const SizedBox();

  Widget _chatItemBuilder(Talk talk, Animation<double> animation) {
    var tip = talk.type == TalkType.user
        ? BalloonTipPosition.rightBottom
        : BalloonTipPosition.leftTop;
    return ScaleTransition(
      alignment: switch (talk.type) {
        TalkType.user => Alignment.bottomRight,
        TalkType.bot => Alignment.topLeft,
        _ => Alignment.center,
      },
      scale: CurvedAnimation(
        parent: animation.drive(Tween<double>(begin: 0, end: 1)),
        curve: Curves.easeOutBack,
      ),
      child: RadioBox(
        talk.targetValue,
        ballonPosition: tip,
        narrator: talk.type.narrator,
        translation: talk.nativeValue,
      ),
    );
  }

  Future<void> onQuizResult(bool isSuccess) async {
    if (isSuccess) {
      serviceLocator<Sounds>().play("correct_${Random().nextInt(3)}");
      _streakCorrects++;
      _maxCorrects = _streakCorrects.min(_maxCorrects);

      // Waiting for celebration
      if (await _delay(500)) return;
      inputSize.value = 0;
      index.value += 1;
      await _insertChat(content!.children[index.value - 1] as Talk);

      if (await _delay(500)) return;
      nextStep();
    } else {
      ++_fouls;
      _streakCorrects = 0;
      serviceLocator<Sounds>().play("wrong");
    }
  }

  Future<void> _insertChat(Talk item) async {
    const duration = Duration(milliseconds: 500);
    _chatListKey.currentState?.insertItem(_chatItems.length);
    _chatItems.add(item);
    if (await _delay(1)) return;
    await _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: duration,
        curve: Curves.easeOutQuart);
    await _delay(duration.inMilliseconds);
  }

  void startQuiz(Talk chat) {}

  double _getFooterHeight() {
    double height = 500.d;
    final keyContext = _footerKey.currentContext;
    if (mounted && keyContext != null) {
      final box = keyContext.findRenderObject() as RenderBox;
      height = box.size.height;
    }
    return height;
  }

  _delay(int duration) async {
    await Future.delayed(Duration(milliseconds: duration));
    return !mounted;
  }
}
