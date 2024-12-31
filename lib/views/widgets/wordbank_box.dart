import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
    final dictator = serviceLocator<DictatorQuiz>();
    return ValueListenableBuilder(
      valueListenable: _state,
      builder: (context, value, child) {
        if (value.index < QuizState.ready.index) {
          return SizedBox();
        }
        final enable = value.index >= QuizState.waiting.index;
        return Padding(
          padding: EdgeInsets.all(4.d),
          child: IgnorePointer(
            ignoring: !enable,
            child: Opacity(
              opacity: enable ? 1 : 0.7,
              child: Column(
                spacing: 20.d,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 5, child: SizedBox()),
                  _wrapper(_words.length, (i) => _wordBuilder(context, i)),
                  DirText(
                    widget.talk.nativeValue,
                    style: TStyles.medium,
                    textAlign: TextAlign.center,
                  ),
                  // SizedBox(height: 40.d),
                  Expanded(flex: 1, child: SizedBox()),
                  _wrapper(_choices.length, (i) => _choiceBuilder(context, i)),
                  Expanded(flex: 5, child: SizedBox()),
                  Row(
                    children: [
                      _button(
                        icon: "play",
                        onPressed: () => serviceLocator<MediaService>()
                            .play(dictator.initialMedia),
                      ),
                      SizedBox(width: dictator.initialMedia == null ? 0 : 12.d),
                      Expanded(
                        child: SkinnedButton(
                          height: 56.d,
                          cornerRadius: 32.d,
                          padding: EdgeInsets.all(2.d),
                          color: value == QuizState.running
                              ? TColors.blue
                              : TColors.primary30,
                          onPressed: dictator.chechAnswers,
                          child: Text("ok_l".l(), style: TStyles.largeInvert),
                        ),
                      ),
                      SizedBox(width: dictator.initialMedia == null ? 0 : 12.d),
                      _button(
                        icon: "slow",
                        onPressed: () => serviceLocator<MediaService>()
                            .play(dictator.initialMedia, playbackRate: 0.75),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _button({
    required String icon,
    required Future<void> Function() onPressed,
  }) {
    if (serviceLocator<DictatorQuiz>().initialMedia == null) {
      return SizedBox();
    }
    return Widgets.button(
      context,
      height: 44.d,
      padding: EdgeInsets.symmetric(horizontal: 12.d, vertical: 5.d),
      decoration: BoxDecoration(
        color: TColors.primary0,
        border: Border.all(color: TColors.primary20, width: 2.d),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Asset.load<SvgPicture>("quiz_$icon"),
      onPressed: onPressed,
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
            child: Text(word.text, style: TStyles.large),
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
