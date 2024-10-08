import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_export.dart';

class DictationBox extends StatelessWidget {
  const DictationBox({super.key});

  @override
  Widget build(BuildContext context) {
    final dictator = serviceLocator<DictatorQuiz>();
    return ValueListenableBuilder(
      valueListenable: dictator.state,
      builder: (context, value, child) {
        if (value.index < QuizState.ready.index) {
          return SizedBox();
        }
        return ValueListenableBuilder(
          valueListenable: dictator.answers,
          builder: (context, value, child) => Padding(
            padding: EdgeInsets.all(8.d),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  textDirection: Localization.dir,
                  children: [
                    DirText("listening_hint".l()),
                    SpeakerBox(
                      width: 30.d,
                      value: dictator.talk!.targetValue,
                      narrator: dictator.talk!.narrator,
                    ),
                  ],
                ),
                SizedBox(height: 12.d),
                DirText(dictator.talk!.nativeValue,
                    style: TStyles.small.copyWith(color: TColors.primary40)),
                SizedBox(height: 8.d),
                _answerBox(context, dictator),
                SizedBox(height: 8.d),
                _wrapper(dictator.choices.length,
                    (i) => _choiceItemBuilder(context, i)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _answerBox(BuildContext context, DictatorQuiz dictator) {
    return Widgets.rect(
      radius: 20.d,
      color: TColors.primary20,
      padding: EdgeInsets.fromLTRB(16.d, 6.d, 6.d, 6.d),
      constraints: BoxConstraints.expand(
          height:
              (1.3.d * dictator.talk!.targetValue.length).clamp(64.d, 200.d)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _wrapper(
                  dictator.answers.value.length,
                  (i) => Text(
                      "${dictator.answers.value[i]}${dictator.charByChar ? "" : "  "}")),
            ),
          ),
          SizedBox(width: 8.d),
          dictator.answers.value.isEmpty
              ? const SizedBox()
              : Widgets.button(
                  context,
                  width: 80.d,
                  buttonId: dictator.state.value == QuizState.ready ? 30 : -1,
                  color: switch (dictator.state.value) {
                    QuizState.success => TColors.green.withOpacity(0.2),
                    QuizState.failure => TColors.error.withOpacity(0.2),
                    _ => TColors.primary20,
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 14.d,
                    width: 13.d,
                    child: switch (dictator.state.value) {
                      QuizState.success =>
                        Asset.load<SvgPicture>("mic_success", width: 32.d),
                      QuizState.failure =>
                        Asset.load<SvgPicture>("mic_fail", width: 32.d),
                      _ => Asset.load<SvgPicture>("clear", width: 24.d),
                    },
                  ),
                  onPressed: dictator.deselectChoice,
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

  Widget _choiceItemBuilder(BuildContext context, int index) {
    final dictator = serviceLocator<DictatorQuiz>();
    var choice = dictator.choices[index];
    return Widgets.button(
      context,
      margin: EdgeInsets.all(3.d),
      padding: EdgeInsets.symmetric(horizontal: 12.d, vertical: 8.d),
      color: choice.used ? TColors.primary20 : TColors.primary10,
      buttonId:
          dictator.state.value != QuizState.ready || choice.used ? -1 : 30,
      child: Opacity(opacity: choice.used ? 0 : 1, child: Text(choice.text)),
      onPressed: () => dictator.selectChoice(choice),
    );
  }
}
