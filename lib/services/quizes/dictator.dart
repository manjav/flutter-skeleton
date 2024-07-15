import 'package:flutter/foundation.dart';

import '../../app_export.dart';

class DictatorQuiz extends Quiz {
  bool charByChar = false;
  List<Choice> choices = [];
  List<String> _pattern = [];
  Answers answers = Answers([]);

  Content? currentStage;

  @override
  initialize({List<Object>? args}) async {
    currentStage = args![0] as Content;
    var text = currentStage!.targetValue.patternize();
    var pattern = text.split(" ");
    _pattern = [];
    if (pattern.length > 10) {
      _pattern = _joinArray(pattern, pattern.length > 16 ? 3 : 2);
    } else {
      _pattern = pattern;
    }
    charByChar = _pattern.length < 2;
    if (charByChar) {
      _pattern = switch (text.length) {
        < 3 => text.split(""),
        _ => text.splitByLength(3),
      };
    }

    choices = List.generate(_pattern.length, (i) => Choice(_pattern[i]));
    choices.shuffle();
    answers.value = [];
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

  void reset() {
    answers.value = [];
    for (var c in choices) {
      c.used = false;
    }
    start();
  }

  bool _chechAnswers() {
    for (var i = 0; i < answers.value.length; i++) {
      if (answers.value[i] != _pattern[i]) {
        return false;
      }
    }
    return true;
  }

  Future<void> checkAnswers() async {
    if (answers.value.length == _pattern.length) {
      state.value = _chechAnswers() ? QuizState.success : QuizState.failure;
      onResult?.call(state.value, "");
    }
  }

  void selectChoice(Choice choice) {
    if (choice.used) return;
    answers.add(choice.text);
    choice.used = true;
    serviceLocator<DictatorQuiz>().checkAnswers();
  }

  void deselectChoice() {
    choices.lastWhere((c) => c.text == answers.value.last).used = false;
    answers.removeLast();
  }
}

class Choice {
  bool used = false;
  final String text;
  Choice(this.text);
}

class Answers extends ValueNotifier<List<String>> {
  Answers(super.value);

  void add(String answer) {
    value.add(answer);
    notifyListeners();
  }

  void removeLast() {
    value.removeLast();
    notifyListeners();
  }
}
