import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lingai/views/widgets/stt_box.dart';

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
  final GlobalKey<AnimatedListState> _mainListKey =
      GlobalKey<AnimatedListState>();
  final List<Chat> _chatItems = [], _mainItems = [];
  Talk? _currentTalk;

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
        Navigator.pop(context);
      }
      return;
    }
    setState(() => _currentTalk = _scenario!.thread[index]);
    await Future.delayed(duration);

    for (var chat in _currentTalk!.chats) {
      if (chat.type == ChatType.bot) {
        continue;
      }
      _mainListKey.currentState?.insertItem(0);
      _mainItems.insert(0, chat);
      if (chat.type == ChatType.stt) {
        await Future.delayed(const Duration(seconds: 2));
        _onSTTResult(STTState.success, chat.value);
        // serviceLocator<STT>().setEnable(true, pattern: chat.value);
        // serviceLocator<STT>().startListening(
        //     locale: _scenario!.targetLanguage, onResult: _onSTTResult);
      } else {
        await serviceLocator<Speaker>()
            .play(chat.value, narrator: chat.narrator);
      }
    }
  }

  @override
  Widget contentFactory() {
    if (_scenario == null) {
      return const SizedBox();
    }

    var padding = 16.d;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: AnimatedList(
              padding: EdgeInsets.fromLTRB(padding, padding * 4, padding, 0),
              key: _chatListKey,
              itemBuilder: (c, i, a) => _chatItemBuilder(_chatItems[i], a)),
        ),
        SizedBox(height: 10.d),
        Widgets.rect(
          color: TColors.white,
          padding: EdgeInsets.all(padding),
          height: 340.d,
          child: AnimatedList(
              reverse: true,
              key: _mainListKey,
              itemBuilder: (c, i, a) => _chatItemBuilder(_mainItems[i], a)),
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

  Widget _itemContentBuilder(Chat chat) {
    if (chat.isChat) {
      return RadioBox(
        chat.value,
        ballonPosition: chat.type == ChatType.user
            ? BalloonTipPosition.rightBottom
            : BalloonTipPosition.leftTop,
        narrator: chat.narrator,
      );
    }
    if (chat.type == ChatType.stt) {
      return const STTBox();
    }
    return Widgets.rect(
        height: 60.d,
        alignment: Alignment.center,
        child: Text(
          chat.value,
          textDirection: chat.value.getDirection(),
          style: TStyles.large,
        ));
  }

  Future<void> _onSTTResult(STTState state, String text) async {
    if (state == STTState.success) {
      serviceLocator<Sounds>().play("correct_${Random().nextInt(3)}");
      const duration = Duration(milliseconds: 300);

      // Waiting for celebration
      await Future.delayed(duration);
      serviceLocator<STT>().setEnable(false);

      // Move items to chat list
      for (var item in _currentTalk!.chats) {
        var index = _mainItems.indexOf(item);
        if (index > -1) {
          _mainItems.removeAt(index);
          _mainListKey.currentState
              ?.removeItem(index, (c, a) => _chatItemBuilder(item, a));
        }
        if (item.isChat) {
          _chatListKey.currentState?.insertItem(_chatItems.length);
          _chatItems.add(item);
          await Future.delayed(duration);
          // Bot answering
          if (item.type == ChatType.bot) {
            await serviceLocator<Speaker>()
                .play(item.value, narrator: item.narrator);
          }
        }
      }
      _nextStep(_currentTalk!.index + 1);
    } else {
      serviceLocator<Sounds>().play("wrong");
    }
  }
}
