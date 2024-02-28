import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_export.dart';

class DictationBox extends StatefulWidget {
  const DictationBox({super.key});

  @override
  State<DictationBox> createState() => _DictationBoxState();
}

class _DictationBoxState extends State<DictationBox> {
  @override
  Widget build(BuildContext context) {
    final dictator = serviceLocator<Dictator>();
    final size = 80.d;
    final chat = dictator.currentStage!.chats
        .where((c) => c.type == ChatType.user)
        .first;
    return ValueListenableBuilder<int>(
      valueListenable: dictator.state,
      builder: (context, value, child) => Padding(
        padding: EdgeInsets.all(8.d),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Widgets.button(
                  context,
                  radius: size,
                  width: size * 0.5,
                  height: size * 0.5,
                  color: TColors.primary10,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(12.d),
                  child: StreamBuilder(
                    stream: serviceLocator<Sounds>()
                        .getPlayer(chat.value)
                        .onPlayerStateChanged,
                    builder: (context, snapshot) => Asset.load<SvgPicture>(
                        snapshot.data == PlayerState.playing ? "stop" : "play",
                        width: size * 0.3),
                  ),
                  onPressed: () => serviceLocator<Speaker>()
                      .play(chat.value, narrator: chat.type.narrator),
                ),
                DirText(dictator.currentStage!.chats.first.value),
              ],
            ),
            SizedBox(height: 8.d),
            _answerBox(dictator),
            SizedBox(height: 8.d),
            _wrapper(dictator.choices.length, _choiceItemBuilder),
          ],
        ),
      ),
    );
  }

  Widget _answerBox(Dictator dictator) {
    return Widgets.rect(
      radius: 20.d,
      color: TColors.primary10,
      padding: EdgeInsets.fromLTRB(16.d, 6.d, 6.d, 6.d),
      constraints: BoxConstraints.expand(height: 64.d),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _wrapper(
                  dictator.answers.length,
                  (i) => Text(
                      "${dictator.answers[i]}${dictator.charByChar ? "" : "  "}")),
            ),
          ),
          SizedBox(width: 8.d),
          dictator.answers.isEmpty
              ? const SizedBox()
              : Widgets.button(
                  context,
                  width: 80.d,
                  color: switch (dictator.state.value) {
                    -2 => TColors.green.withOpacity(0.2),
                    -1 => TColors.error.withOpacity(0.2),
                    _ => TColors.primary20,
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 14.d,
                    width: 13.d,
                    child: switch (dictator.state.value) {
                      -2 => Asset.load<SvgPicture>("mic_success", width: 32.d),
                      -1 => Asset.load<SvgPicture>("mic_fail", width: 32.d),
                      _ => Asset.load<SvgPicture>("clear", width: 24.d),
                    },
                  ),
                  onPressed: () {
                    if (dictator.state.value > -1) {
                      var last = dictator.answers.removeLast();
                      dictator.choices.lastWhere((c) => c.text == last).used =
                          false;
                      dictator.state.value = dictator.answers.length;
                    }
                  },
                ),
        ],
      ),
    );
  }

  Widget _wrapper(
    int itemCount,
    Widget Function(int) itemBuilder,
  ) {
    return Wrap(
      children: [
        for (var i = 0; i < itemCount; i++) itemBuilder(i),
      ],
    );
  }

  Widget _choiceItemBuilder(int index) {
    final dictator = serviceLocator<Dictator>();
    var choice = dictator.choices[index];
    return Widgets.button(
      context,
      padding: EdgeInsets.symmetric(horizontal: 12.d, vertical: 8.d),
      margin: EdgeInsets.all(3.d),
      color: choice.used ? TColors.primary20 : TColors.primary10,
      child: Opacity(opacity: choice.used ? 0 : 1, child: Text(choice.text)),
      onPressed: () {
        if (dictator.state.value < 0 || choice.used) return;
        dictator.answers.add(choice.text);
        dictator.state.value = dictator.answers.length;
        choice.used = true;
        serviceLocator<Dictator>().checkAnswers();
      },
    );
  }
}
