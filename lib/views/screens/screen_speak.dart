import 'dart:convert';

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

  final List<Chat> _chats = [];
  Talk? _currentTalk;
  STTBox? _sttBox;
   
  final Narrator _userNarrator = Narrator.nova;
  final Narrator _botNarrator = Narrator.fable;

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
    _sttBox = STTBox(_scenario!.targetLanguage, onResult: _onSTTResult);
    _nextStep(0);
  }

  Future<void> _nextStep(int index) async {
    setState(() => _currentTalk = _scenario!.thread[index]);
    for (var chat in _currentTalk!.chats) {
      if (chat.type == ChatType.hint) {
        await serviceLocator<Speaker>().play(chat.value);
      } else if (chat.type == ChatType.user) {
        await serviceLocator<Speaker>()
            .play(chat.value, narrator: _userNarrator);
        _sttBox!.setEnable(true, pattern: chat.value);
      }
    }
    _sttBox!.startListening();
  }

  @override
  Widget contentFactory() {
    if (_scenario == null) {
      return const SizedBox();
    }
    var items = <Widget>[
    ];
    if (_currentTalk != null) {
      for (var chat in _currentTalk!.chats) {
        items.add(switch (chat.type) {
          ChatType.hint =>
            Text(chat.value, textDirection: chat.value.getDirection()),
          ChatType.user => Column(children: [
              SizedBox(height: 32.d),
              RadioBox(
                chat.value,
                ballonPosition: BalloonTipPosition.rightBottom,
                narrator: _userNarrator,
              ),
              SizedBox(height: 16.d),
              _sttBox!,
              SizedBox(height: 32.d),
            ]),
          _ => const SizedBox(),
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: items,
    );
  }


  Future<void> _onSTTResult(STTState state, String text) async {
    if (state == STTState.success) {
      await Future.delayed(const Duration(milliseconds: 300));
      _sttBox?.setEnable(false);
      var talk = _currentTalk!;
      _currentTalk = null;
      setState(() {});
      await serviceLocator<Speaker>()
          .play(talk.first(ChatType.bot).value, narrator: _botNarrator);

      _nextStep(talk.index + 1);
    }
  }
}
