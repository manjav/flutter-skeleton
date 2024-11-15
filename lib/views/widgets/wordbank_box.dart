import 'package:flutter/material.dart';

import '../../app_export.dart';

class WordBankBox extends StatefulWidget {
  final Talk talk;

  const WordBankBox(this.talk, {super.key});

  @override
  State<WordBankBox> createState() => _WordBankBoxState();
}

class _WordBankBoxState extends State<WordBankBox> {
  List<Choice> _words = [];
  List<Choice> _choices = [];
  final ValueNotifier<QuizState> _state = ValueNotifier(QuizState.none);

  @override
  void initState() {
    final dictator = serviceLocator<DictatorQuiz>();
    _removeListeners(dictator);
    dictator.state.addListener(_onDictatorStateChange);
    _onDictatorStateChange();
    super.initState();
  }

  void _onDictatorStateChange() {
    final dictator = serviceLocator<DictatorQuiz>();
    if (widget.talk == dictator.talk) {
      _words = List.from(dictator.words);
      _choices = List.from(dictator.choices);
      _state.value = dictator.state.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _state,
      builder: (context, value, child) {
        if (value.index < QuizState.ready.index) {
          return SizedBox();
        }
        return Padding(
          padding: EdgeInsets.all(8.d),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DirText(
                widget.talk.nativeValue,
                style: TStyles.small.copyWith(color: TColors.primary70),
              ),
              _wrapper(_words.length, (i) => _wordBuilder(context, i)),
              SizedBox(height: 5.d),
              _wrapper(_choices.length, (i) => _choiceBuilder(context, i)),
              SizedBox(height: 5.d),
              SkinnedButton(
                color: value == QuizState.waiting
                    ? TColors.blue
                    : TColors.primary30,
                label: "ok_l".l(),
                onPressed: serviceLocator<DictatorQuiz>().chechAnswers,
              ),
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

  Widget _wordBuilder(BuildContext context, int index) {
    var word = _words[index];
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
                      ? _getRectColor(_state.value, value)
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
          buttonId:
              _state.value != QuizState.ready || value == ChoiceState.selected
                  ? -1
                  : 30,
          child:
              filled ? Text(word.text, style: TStyles.largeInvert) : SizedBox(),
          onPressed: () => serviceLocator<DictatorQuiz>().undoChoice(word),
        );
      },
    );
  }

  Widget _choiceBuilder(BuildContext context, int index) {
    var choice = _choices[index];
    return ValueListenableBuilder(
      valueListenable: choice.stateNotifier,
      builder: (context, value, child) => Widgets.button(
        context,
        margin: EdgeInsets.all(3.d),
        padding: EdgeInsets.symmetric(horizontal: 16.d, vertical: 5.d),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16.d)),
          border: Border.all(color: TColors.primary30),
          color: value == ChoiceState.selected
              ? TColors.primary10
              : TColors.primary0,
        ),
        buttonId:
            _state.value != QuizState.ready || value == ChoiceState.selected
                ? -1
                : 30,
        child: Opacity(
            opacity: value == ChoiceState.selected ? 0 : 1,
            child: Text(choice.text, style: TStyles.large)),
        onPressed: () => serviceLocator<DictatorQuiz>().selectChoice(choice),
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

  @override
  void dispose() {
    _removeListeners(serviceLocator<DictatorQuiz>());
    super.dispose();
  }

  void _removeListeners(DictatorQuiz dictator) {
    dictator.state.removeListener(_onDictatorStateChange);
  }
}
