import 'package:flutter/foundation.dart';

import '../../app_export.dart';

class DictatorQuiz extends Quiz {
  bool charByChar = false;
  List<Choice> words = [];
  List<Choice> choices = [];
  List<String> _patterns = [];
  List<String> _extraChoices = [];

  Iterable<Choice> get blanks =>
      words.where((w) => w.state == ChoiceState.available);

  @override
  void prepare({
    required Talk talk,
    Function(QuizState, String, int, bool, dynamic)? onResult,
  }) {
    super.prepare(talk: talk, onResult: onResult);

    final sections = talk.targetValue.split("∆");
    var text = sections.first;
    final myWords = text.split(" ");
    _extraChoices = [];
    if (sections.length > 1) {
      _extraChoices = sections.last.split("|");
    }

    _patterns = [];
    if (words.length > 10) {
      _patterns = _joinArray(myWords, words.length > 16 ? 3 : 2);
    } else {
      _patterns = myWords;
    }
    charByChar = _patterns.length < 2;
    if (charByChar) {
      _patterns = switch (text.length) {
        < 3 => text.split(""),
        _ => text.splitByLength(3),
      };
    }

    words.clear();
    choices.clear();

    List<Choice> text2Choice(List<String> texts) {
      return List.generate(
        texts.length,
        (i) => Choice(texts[i].replaceAll(RegExp(r'[{}]'), '')),
      );
    }

    if (talk.targetValue.contains("}")) {
      for (var i = 0; i < _patterns.length; i++) {
        var text = _patterns[i];
        final blankMode = Choice.blankMode(text);
        text = text.replaceAll(RegExp(r'[ًٍَُِّ{}]'), '');
        _patterns[i] = text;
        final word = Choice(
          blankMode ? "" : text,
          state: blankMode ? ChoiceState.available : ChoiceState.fixed,
        );
        words.add(word);
        if (blankMode) {
          choices.add(Choice(text));
        }
      }
    } else {
      choices = text2Choice(_patterns);
      words = text2Choice(_patterns);
    }
    choices.addAll(text2Choice(_extraChoices));
    choices.shuffle();
    state.value = QuizState.ready;
  }

  List<String> _joinArray(List<String> array, int step) {
    var result = <String>[];
    for (var i = 0; i < array.length; i += step) {
      var sub = array.sublist(i, i > array.length - step ? null : i + step);
      result.add(sub.join(" "));
    }
    return result;
  }

  Future<void> selectChoice(Choice choice) async {
    final blank = words.firstWhere((w) => w.state == ChoiceState.available,
        orElse: () => Choice("no_space"));
    if (blank.text == "no_space") {
      return;
    }
    // final last
    if (choice.state == ChoiceState.selected) return;
    choice.setState(ChoiceState.selected);
    blank.text = choice.text;
    blank.setState(ChoiceState.selected);
    state.value = blanks.isEmpty ? QuizState.waiting : QuizState.ready;
  }

  void undoChoice(Choice word) {
    word.setState(ChoiceState.available);
    choices
        .lastWhere(
            (c) => c.text == word.text && c.state != ChoiceState.available)
        .setState(ChoiceState.available);
    state.value = blanks.isEmpty ? QuizState.waiting : QuizState.ready;
  }

  void chechAnswers() {
    if (blanks.isNotEmpty) {
      return;
    }

    var state = QuizState.success;
    var score = 0;
    var numQuizes = 0;
    for (var i = 0; i < words.length; i++) {
      if (words[i].state == ChoiceState.selected) {
        words[i].setState(words[i].text == _patterns[i]
            ? ChoiceState.success
            : ChoiceState.failure);
        if (words[i].state == ChoiceState.failure) {
          state = QuizState.failure;
        } else {
          score++;
        }
        numQuizes++;
      }
    }
    this.state.value = state;
    onResult?.call(
      state,
      "",
      (score / numQuizes * 100).round(),
      false,
      [words, _patterns],
    );
  }

  void popChoice() {
    var last = words.lastWhere((c) => c.state == ChoiceState.selected);
    last.setState(ChoiceState.available);
    words.last.setState(ChoiceState.available);
    choices
        .lastWhere((c) => c.text == last.text)
        .setState(ChoiceState.available);
  }
}

enum ChoiceState { fixed, available, selected, success, failure }

class Choice {
  String text = "";
  ChoiceState get state => _state.value;
  ValueNotifier<ChoiceState> get stateNotifier => _state;
  final _state = ValueNotifier(ChoiceState.available);

  void setState(ChoiceState value) => _state.value = value;
  Choice(
    this.text, {
    ChoiceState state = ChoiceState.available,
  }) {
    setState(state);
  }

  static blankMode(text) => text.contains("{") || text.contains("}");
}
