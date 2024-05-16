import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_export.dart';

mixin LessonChatMixin<S extends AbstractScreen>
    on AbstractScreenState<S>, LessonMixin {
  final List<Talk> _chatItems = [];
  final _chatListKey = GlobalKey<AnimatedListState>();
  final ScrollController _chatScrollController = ScrollController();

  @override
  void initState() {
    steps = Get.arguments["content"].children;
    changeStep(context, 1);
    super.initState();
  }

  @override
  List<Widget> appBarElementsLeft() => [];

  @override
  Widget contentFactory(double paddingTop) {
    if (steps.isEmpty) {
      return const SizedBox();
    }

    var padding = 12.d;
    return Stack(
      children: [
        AnimatedList(
            key: _chatListKey,
            controller: _chatScrollController,
            padding: EdgeInsets.fromLTRB(padding, paddingTop + padding * 6,
                padding, getFooterHeight(context)),
            itemBuilder: (c, i, a) => _chatItemBuilder(_chatItems[i], a)),
        Positioned(
          top: paddingTop,
          left: 0,
          right: 0,
          height: headerHeight,
          child: headerBuilder(
              context,
              index,
              EdgeInsets.fromLTRB(padding, padding, padding, 0),
              Get.arguments["content"].title,
              steps),
        ),
        ValueListenableBuilder(
            valueListenable: headerSize,
            builder: (context, value, child) {
              return AnimatedPositioned(
                left: 0,
                right: 0,
                top: DeviceInfo.size.height - value,
                curve: value == 0 ? Curves.easeIn : Curves.easeOutBack,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: footerKey,
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
    var tip = talk.type == ContentType.user
        ? BalloonTipPosition.rightBottom
        : BalloonTipPosition.leftTop;
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
      child: RadioBox(
        talk.targetValue,
        ballonPosition: tip,
        narrator: talk.type.narrator,
        translation: talk.nativeValue,
      ),
    );
  }

  @override
  updateContent() async => await _insertChat();

  Future<void> _insertChat() async {
    var talk = steps[index.value] as Talk;
    const duration = Duration(milliseconds: 500);

    _chatListKey.currentState?.insertItem(_chatItems.length);
    _chatItems.add(talk);
    await Future.delayed(const Duration(milliseconds: 1));
    await _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: duration,
        curve: Curves.easeOutQuart);
    await Future.delayed(duration);
  }
}
