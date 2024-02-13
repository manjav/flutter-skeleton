import 'dart:convert';

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

  final List<Chat> _chats = [];
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
    setState(() => _currentTalk = _scenario!.thread[index]);
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
            ]),
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: items,
    );
  }

}
