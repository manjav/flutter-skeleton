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
  int _currnentDialogIndex = 0;

  List<Chat> _thread = [];
  List<Chat> _mainDialogs = [];

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
    _nextStep();
  }

  void _nextStep() {
    var dialog = _scenario!.thread[_currnentDialogIndex];
    if (dialog.type == ChatType.hint) {
      // serviceLocator<RouteService>()
      //     .to(Routes.popupMentor, args: {"message": dialog.text});
      _mainDialogs = [
        dialog,
        _scenario!.thread[_currnentDialogIndex + 1],
      ];
    }

    setState(() {});
  }

  @override
  Widget contentFactory() {
    if (_scenario == null) {
      return const SizedBox();
    }

    return Column(
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 148.d),
        Text(_mainDialogs[0].text, textDirection: TextDirection.rtl),
        SizedBox(height: 12.d),
        RadioBox(_mainDialogs[1].text, BalloonTipPosition.rightBottom),
        SkinnedButton(width: 277, label: "test", onPressed: () {})
      ],
    );
  }
}
