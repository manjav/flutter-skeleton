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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _wrapper(dictator.words.length,
                  (i) => _wordBuilder(context, dictator, i)),
              SizedBox(height: 30.d),
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
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
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
            child: Text(word.text, style: TStyles.big),
          );
        }
        final filled = value.index >= ChoiceState.selected.index;
        return Widgets.button(
          context,
          height: 30.d,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5.d)),
              boxShadow: [
                BoxShadow(
                    color: filled ? TColors.transparent : TColors.primary30),
                BoxShadow(
                  offset: Offset(0, 0.4.d),
                  color: filled
                      ? _getRectColor(dictator.state.value, value)
                      : TColors.primary10,
                  spreadRadius: -0.6.d,
                ),
              ]),
          width: value == ChoiceState.available ? 50.d : null,
          margin: EdgeInsets.symmetric(horizontal: 5.d),
          padding: EdgeInsets.fromLTRB(
            paddingValue * 3,
            paddingValue * 0.5,
            paddingValue * 3,
            paddingValue,
          ),
          buttonId: dictator.state.value != QuizState.ready ||
                  value == ChoiceState.selected
              ? -1
              : 30,
          child:
              filled ? Text(word.text, style: TStyles.largeInvert) : SizedBox(),
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
        padding: EdgeInsets.symmetric(horizontal: 16.d, vertical: 10.d),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16.d)),
          border: Border.all(color: TColors.primary30),
          color: value == ChoiceState.selected
              ? TColors.primary10
              : TColors.primary0,
        ),
        buttonId: dictator.state.value != QuizState.ready ||
                value == ChoiceState.selected
            ? -1
            : 30,
        child: Opacity(
            opacity: value == ChoiceState.selected ? 0 : 1,
            child: Text(choice.text, style: TStyles.large)),
        onPressed: () => dictator.selectChoice(choice),
      ),
    );
  }

  Color _getRectColor(QuizState state, ChoiceState choiceState) {
    if (state == QuizState.success) {
      return TColors.green;
    }
    if (state == QuizState.failure && choiceState == ChoiceState.failure) {
      return TColors.red;
    }
    return TColors.primary90;
  }
}
