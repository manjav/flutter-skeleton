import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class SpeakScreen extends AbstractScreen {
  SpeakScreen({super.key}) : super(Routes.speak);

  @override
  createState() => _SpeakScreenState();
}

class _SpeakScreenState extends AbstractScreenState<SpeakScreen> {
  Scenario? _scenario;
  final GlobalKey<AnimatedListState> _chatListKey =
      GlobalKey<AnimatedListState>();
  final List<Chat> _chatItems = [];
  Talk? _currentTalk;
  final ScrollController _chatScrollController = ScrollController();
  final ValueNotifier<double> _inputSize = ValueNotifier(0);
  final double _defaultInputSize = 180.d;

  @override
  List<Widget> appBarElementsLeft() {
    if (_scenario == null) return [];
    return super.appBarElementsLeft()
      ..addAll([
        Avatar(_scenario!.botAvatar, 64.d),
        SizedBox(width: 16.d),
        Text(_scenario!.botName),
      ]);
  }

  @override
  void initState() {
    _loadScenerio();
    super.initState();
  }

  Future<void> _loadScenerio() async {
    var data =
        await rootBundle.loadString("assets/texts/${Get.arguments}.json");
    _scenario = Scenario(jsonDecode(data));
    _nextStep(0);
  }

  Future<void> _nextStep(int index) async {
    const duration = Duration(milliseconds: 300);
    if (index >= _scenario!.thread.length) {
      await Future.delayed(duration);
      await Future.delayed(duration);
      if (mounted) {
        // Navigator.pop(context);
      }
      return;
    }
    setState(() => _currentTalk = _scenario!.thread[index]);
    await Future.delayed(duration);

    for (var chat in _currentTalk!.chats) {
      if (chat.type == ChatType.bot) {
        continue;
      }
      _inputSize.value = _defaultInputSize;
      await serviceLocator<Speaker>().play(chat.value, narrator: chat.narrator);

      if (chat.type == ChatType.user) {
        // if (kDebugMode) {
        //   await Future.delayed(const Duration(seconds: 2));
        //   _onSTTResult(STTState.success, chat.value);
        // } else {
        serviceLocator<STT>().startListening(
            locale: _scenario!.targetLanguage,
            pattern: chat.value,
            onResult: _onSTTResult);
        // }
      }
    }
  }

  @override
  Widget contentFactory() {
    if (_scenario == null) {
      return const SizedBox();
    }

    var padding = 16.d;
    return Stack(
      children: [
        Expanded(
          child: AnimatedList(
              key: _chatListKey,
              controller: _chatScrollController,
              padding: EdgeInsets.fromLTRB(padding, padding * 4, padding, 0),
              itemBuilder: (c, i, a) => _chatItemBuilder(_chatItems[i], a)),
        ),
        ValueListenableBuilder(
          valueListenable: _inputSize,
          builder: (context, value, child) {
            return AnimatedPositioned(
              right: 0,
              left: 0,
              top: DeviceInfo.size.height - value,
              curve: value == 0 ? Curves.easeIn : Curves.easeOutBack,
              duration: const Duration(milliseconds: 300),
              child: Widgets.rect(
                  decoration: BoxDecoration(
                    color: TColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.d),
                      topRight: Radius.circular(24.d),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, -2.d), // changes position of shadow
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(padding),
                  child: Column(children: [
                    Text(_currentTalk!.chats.first.value,
                        textDirection:
                            _currentTalk!.chats.first.value.getDirection()),
                    SizedBox(height: 24.d),
                    ListenerBox(_currentTalk!.chats[1])
                  ])),
            );
          },
        )
      ],
    );
  }

  Widget _chatItemBuilder(Chat chat, Animation<double> animation) {
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
        child: _itemContentBuilder(chat));
  }

  Widget _itemContentBuilder(Chat chat, [bool inChat = true]) {
    var tip = BalloonTipPosition.none;
    if (inChat) {
      tip = chat.type == ChatType.user
          ? BalloonTipPosition.rightBottom
          : BalloonTipPosition.leftTop;
    }
    if (chat.isChat) {
      return RadioBox(
        chat.value,
        ballonPosition: tip,
        narrator: chat.narrator,
        translation: chat.nativeLanguage,
      );
    }

    return Widgets.rect(
        alignment: Alignment.center,
        child: Text(
          chat.value,
          textDirection: chat.value.getDirection(),
        ));
  }

  Future<void> _onSTTResult(STTState state, String text) async {
    const duration = Duration(milliseconds: 1500);
    serviceLocator<STT>().stopListening();
    if (state == STTState.success) {
      serviceLocator<Sounds>().play("correct_${Random().nextInt(3)}");
      // Waiting for celebration
      await Future.delayed(duration);
      serviceLocator<STT>().state.value = STTState.none;
      _inputSize.value = 0;
      // Move items to chat list
      for (var item in _currentTalk!.chats) {
        if (item.isChat) {
          // Bot answering
          if (item.type == ChatType.bot) {
            serviceLocator<Speaker>().play(item.value, narrator: item.narrator);
          }
          await _insertChat(item, duration);
        }
      }

      await Future.delayed(duration);
      _nextStep(_currentTalk!.index + 1);
    } else if (state == STTState.fail) {
      serviceLocator<Sounds>().play("wrong");
      await Future.delayed(duration);
      serviceLocator<STT>().startListening();
    }
  }

  Future<void> _insertChat(Chat item, Duration duration) async {
    _chatListKey.currentState?.insertItem(_chatItems.length);
    _chatItems.add(item);
    await Future.delayed(const Duration(milliseconds: 1));
    await _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: duration,
        curve: Curves.easeOutQuart);
    await Future.delayed(duration);
  }
}
