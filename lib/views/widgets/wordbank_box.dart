import 'package:flutter/material.dart';

import '../../app_export.dart';

class WordBankBox extends StatelessWidget {
  const WordBankBox({super.key});

  @override
  Widget build(BuildContext context) {
    final dictator = serviceLocator<DictatorQuiz>();
    return ValueListenableBuilder(
      valueListenable: dictator.state,
      builder: (context, value, child) {
        if (value.index < QuizState.ready.index) {
          return SizedBox();
        }
        return Padding(
          padding: EdgeInsets.all(8.d),
          child: Column(
            children: [
              _wrapper(dictator.words.length,
                  (i) => _wordBuilder(context, dictator, i)),
              SizedBox(height: 8.d),
              _wrapper(dictator.choices.length,
                  (i) => _choiceBuilder(context, dictator, i)),
            ],
          ),
        );
      },
    );
  }

  Widget _wrapper(int itemCount, Widget Function(int) itemBuilder) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [for (var i = 0; i < itemCount; i++) itemBuilder(i)],
    );
  }

  Widget _wordBuilder(BuildContext context, DictatorQuiz dictator, int index) {
    var word = dictator.words[index];
    final paddingValue = 3.d;
    return ValueListenableBuilder(
      valueListenable: word.stateNotifier,
      builder: (context, value, child) {
        if (value == ChoiceState.fixed) {
          return Padding(
            padding: EdgeInsets.all(paddingValue),
            child: Text(word.text),
          );
        }
        return Widgets.button(
          context,
          height: 30.d,
          radius: 8.d,
          color: TColors.primary0,
          width: value == ChoiceState.available ? 44.d : null,
          margin: EdgeInsets.symmetric(horizontal: 2.d),
          padding: EdgeInsets.symmetric(
            horizontal: paddingValue * 2,
            vertical: paddingValue,
          ),
          buttonId: dictator.state.value != QuizState.ready ||
                  value == ChoiceState.selected
              ? -1
              : 30,
          child: value == ChoiceState.selected ? Text(word.text) : SizedBox(),
          onPressed: () => dictator.clearChoice(word),
        );
      },
    );
  }

  Widget _choiceBuilder(
      BuildContext context, DictatorQuiz dictator, int index) {
    var choice = dictator.choices[index];
    return ValueListenableBuilder(
      valueListenable: choice.stateNotifier,
      builder: (context, value, child) => Widgets.button(
        context,
        margin: EdgeInsets.all(3.d),
        padding: EdgeInsets.symmetric(horizontal: 12.d, vertical: 8.d),
        color: value == ChoiceState.selected
            ? TColors.primary20
            : TColors.primary30,
        buttonId: dictator.state.value != QuizState.ready ||
                value == ChoiceState.selected
            ? -1
            : 30,
        child: Opacity(
            opacity: value == ChoiceState.selected ? 0 : 1,
            child: Text(choice.text)),
        onPressed: () => dictator.selectChoice(choice),
      ),
    );
  }
}
