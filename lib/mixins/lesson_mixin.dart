import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../app_export.dart';

mixin LessonMixin<S extends AbstractScreen> on AbstractScreenState<S> {
  Scenario? scenario;
  final GlobalKey<AnimatedListState> _chatListKey =
      GlobalKey<AnimatedListState>();

  final List<Chat> _chatItems = [];
  Talk? currentTalk;
  final ScrollController _chatScrollController = ScrollController();
  final ValueNotifier<double> inputSize = ValueNotifier(0);
  final ValueNotifier<Offset> _progress = ValueNotifier(const Offset(0, 0));

  final GlobalKey _footerKey = GlobalKey();

  @override
  void initState() {
    _loadScenerio();
    super.initState();
  }

  Future<void> _loadScenerio() async {
    var data =
        await rootBundle.loadString("assets/texts/${Get.arguments}.json");
    scenario = Scenario(jsonDecode(data));
    nextStep(0);
  }

  Future<void> nextStep(int index) async {
    const duration = Duration(milliseconds: 300);
    if (index >= scenario!.thread.length) {
      await Future.delayed(duration);
      await Future.delayed(duration);
      if (mounted) {
        // Navigator.pop(context);
      }
      return;
    }
    setState(() => currentTalk = scenario!.thread[index]);
    await Future.delayed(duration);

    for (var chat in currentTalk!.chats) {
      if (chat.type == ChatType.bot) {
        continue;
      }

      inputSize.value = _getFooterHeight();
      await serviceLocator<Speaker>()
          .play(chat.value, narrator: chat.type.narrator);

      if (chat.type == ChatType.user) {
        startQuiz(chat);
      }
    }
  }

  @override
  List<Widget> appBarElementsLeft() => [];

  @override
  Widget contentFactory(double paddingTop) {
    if (scenario == null) {
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
            top: paddingTop + padding,
            left: padding,
            right: padding,
            height: 64.d,
            child: _headerBuilder()),
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

  Widget _headerBuilder() {
    return Row(
      children: [
        Avatar(scenario!.botAvatar, 64.d),
        SizedBox(width: 12.d),
        Expanded(
            child: ValueListenableBuilder(
          valueListenable: _progress,
          builder: (context, value, child) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(scenario!.botName),
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
                "${currentTalk!.index + 1} / ${scenario!.thread.length}",
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
    );
  }

  Widget footerBuilder() => const SizedBox();

  Widget _chatItemBuilder(Chat chat, Animation<double> animation) {
    var tip = chat.type == ChatType.user
        ? BalloonTipPosition.rightBottom
        : BalloonTipPosition.leftTop;
    return ScaleTransition(
      alignment: switch (chat.type) {
        ChatType.user => Alignment.bottomRight,
        ChatType.bot => Alignment.topLeft,
        _ => Alignment.center,
      },
      scale: CurvedAnimation(
        parent: animation.drive(Tween<double>(begin: 0, end: 1)),
        curve: Curves.easeOutBack,
      ),
      child: RadioBox(
        chat.value,
        ballonPosition: tip,
        narrator: chat.type.narrator,
        translation: chat.nativeLanguage,
      ),
    );
  }

  Future<void> onQuizResult(bool isSuccess) async {
    const duration = Duration(milliseconds: 1500);

    if (isSuccess) {
      _progress.value = Offset(
        currentTalk!.index / scenario!.thread.length,
        (currentTalk!.index + 1) / scenario!.thread.length,
      );
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
      nextStep(currentTalk!.index + 1);
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
