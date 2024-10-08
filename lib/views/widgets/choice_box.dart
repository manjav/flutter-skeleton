import 'package:flutter/material.dart';
import 'package:lifetalk/app_export.dart';

enum ButtonMode { text, image, voice }

class ChoiceBox extends StatelessWidget {
  ChoiceBox({super.key});

  @override
  Widget build(BuildContext context) {
    var quiz = serviceLocator<ChoiceQuiz>();
    return ValueListenableBuilder(
      valueListenable: quiz.state,
      builder: (context, value, child) {
        if (value.index < QuizState.ready.index) {
          return SizedBox();
        }
        return SizedBox(
          width: DeviceInfo.size.width * 0.8,
          height: DeviceInfo.size.width * 0.8,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: (quiz.mode == ButtonMode.image ? 1.0 : 2.2)),
            itemCount: quiz.choices.length,
            itemBuilder: _choiceItemBuilder,
          ),
        );
      },
    );
  }

  Widget _choiceItemBuilder(BuildContext context, int index) {
    var quiz = serviceLocator<ChoiceQuiz>();
    return ValueListenableBuilder(
      valueListenable: quiz.selectedIndex,
      builder: (context, value, child) {
        return SkinnedButton(
          width: 100.d,
          color: value == index
              ? switch (quiz.state.value) {
                  QuizState.success => TColors.green,
                  QuizState.failure => TColors.red,
                  _ => TColors.white,
                }
              : TColors.white,
          margin: EdgeInsets.all(4.d),
          paddingTop: 3.d,
          paddingLeft: 3.d,
          paddingBottom: 3.d,
          paddingRight: 3.d,
          child: switch (quiz.mode) {
            ButtonMode.text => Text(quiz.choices[index], style: TStyles.large),
            ButtonMode.image => ImageBox(name: quiz.choices[index]),
            _ => _player(quiz.choices[index]),
          },
          onPressed: () => quiz.select(index),
        );
      },
    );
  }

  Widget _player(String choice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SpeakerBox(value: choice, narrator: Narrator.onyx),
        Widgets.rect(color: TColors.primary20, height: 24.d, width: 4.d),
        Text("select_l".l()),
      ],
    );
  }
}
