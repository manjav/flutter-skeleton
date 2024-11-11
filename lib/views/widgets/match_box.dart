import 'package:flutter/material.dart';

import '../../app_export.dart';

class MatchBox extends StatelessWidget {
  const MatchBox({super.key});

  @override
  Widget build(BuildContext context) {
    var quiz = serviceLocator<MatchQuiz>();
    return ValueListenableBuilder(
      valueListenable: quiz.state,
      builder: (context, value, child) {
        if (value.index < QuizState.ready.index) {
          return SizedBox();
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _listBuilder(quiz.lefts),
            _listBuilder(quiz.rights),
          ],
        );
      },
    );
  }

  Widget _listBuilder(List<MatchSide> list) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < list.length; i++) _choiceItemBuilder(list[i])
      ],
    );
  }

  Widget _choiceItemBuilder(
    MatchSide side,
    // ButtonMode mode,
    // bool isTarget,
  ) {
    return ListenableBuilder(
      listenable: side,
      builder: (context, child) {
        return SkinnedButton(
          isEnable: side.isEnable,
          height: 100.d,
          width: /* mode == ButtonMode.image ? 100.d : */ 170.d,
          color: side.isEnable
              ? (side.isSelected ? TColors.blue : TColors.white)
              : TColors.teal,
          paddingTop: 3.d,
          paddingLeft: 3.d,
          paddingBottom: 3.d,
          paddingRight: 3.d,
          margin: EdgeInsets.all(4.d),
          child: /* switch (mode) {
            ButtonMode.image => ImageBox(name: widget.choices[index].value),
            ButtonMode.text => */
              Text(side.value,
                  style: TStyles
                      .large) /* ,
            _ => _player(item),
          }*/
          ,
          onPressed: () => serviceLocator<MatchQuiz>().select(side),
        );
      },
    );
  }
}
