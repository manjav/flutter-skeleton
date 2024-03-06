import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../app_export.dart';

mixin LessonMixin<S extends AbstractScreen> on AbstractScreenState<S> {
  ParentContent? content;
  final GlobalKey<AnimatedListState> _chatListKey =
      GlobalKey<AnimatedListState>();

  int index = 0;
  final List<Talk> _chatItems = [];
  final ValueNotifier<double> inputSize = ValueNotifier(0);
  final ValueNotifier<Offset> _progress = ValueNotifier(const Offset(0, 0));
  final ScrollController _chatScrollController = ScrollController();

  final GlobalKey _footerKey = GlobalKey();

  @override
  void initState() {
    content = Get.arguments["content"];
    nextStep();
    super.initState();
  }

  Future<void> nextStep() async {
    const duration = Duration(milliseconds: 500);
    if (index >= content!.children.length) {
      await Future.delayed(duration);
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }
    var talk = content!.children[index] as Talk;
    await Future.delayed(duration);
    await _insertChat(talk);

    await serviceLocator<Speaker>()
        .play(talk.targetValue, narrator: talk.type.narrator);

    ++index;
    talk = content!.children[index] as Talk;
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
            child: _headerBuilder(
                EdgeInsets.fromLTRB(padding, padding, padding, 0))),
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

  Widget _headerBuilder(EdgeInsetsGeometry padding) {
    var person = (content!.children[0] as Talk).personId;
    return Widgets.rect(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [
              0.7,
              1
            ],
            colors: <Color>[
              TColors.primary10,
              TColors.primary10.withOpacity(0)
            ]),
      ),
      child: Row(
      children: [
          Avatar(person, 64.d),
        SizedBox(width: 12.d),
        Expanded(
            child: ValueListenableBuilder(
          valueListenable: _progress,
          builder: (context, value, child) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(person),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                tween: Tween(
                  begin: value.dx,
                  end: value.dy,
                ),
                builder: (context, value, _) => LinearProgressIndicator(
                  minHeight: 6.d,
                  value: value,
                  color: TColors.green,
                  backgroundColor: TColors.primary20,
                  borderRadius: BorderRadius.all(Radius.circular(6.d)),
                ),
              ),
              Text(
                  "${index + 1} / ${content!.children.length}",
                style: TStyles.small.copyWith(color: TColors.primary30),
              ),
            ],
          ),
        )),
        SizedBox(width: 12.d),
        Widgets.button(
          context,
          width: 32.d,
          height: 32.d,
          radius: 32.d,
          padding: EdgeInsets.all(8.d),
          color: TColors.primary20,
          child: Asset.load<SvgPicture>("close"),
          onPressed: () => Navigator.pop(context),
        )
      ],
      ),
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
    const duration = Duration(milliseconds: 500);
    if (isSuccess) {
      serviceLocator<Sounds>().play("correct_${Random().nextInt(3)}");

      // Waiting for celebration
      await Future.delayed(duration);
      inputSize.value = 0;
      // Move items to chat list
      for (var item in currentTalk!.chats) {
        if (item.isChat) {
          // Bot answering
          if (item.type == ChatType.bot) {
            serviceLocator<Speaker>()
                .play(item.value, narrator: item.type.narrator);
          }
          await _insertChat(item);
        }
      }

      await Future.delayed(duration);
      index++;
      nextStep();
    } else {
      serviceLocator<Sounds>().play("wrong");
    }
  }

  Future<void> _insertChat(Chat item) async {
    const duration = Duration(milliseconds: 500);
    _chatListKey.currentState?.insertItem(_chatItems.length);
    _chatItems.add(item);
    await Future.delayed(const Duration(milliseconds: 1));
    await _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: duration,
        curve: Curves.easeOutQuart);
    await Future.delayed(duration);
  }

  void startQuiz(Chat chat) {}

  double _getFooterHeight() {
    double height = 500.d;
    final keyContext = _footerKey.currentContext;
    if (mounted && keyContext != null) {
      final box = keyContext.findRenderObject() as RenderBox;
      height = box.size.height;
    }
    return height;
  }
}
