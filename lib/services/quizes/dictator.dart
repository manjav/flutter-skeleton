import 'package:flutter/foundation.dart';

import '../../app_export.dart';

class Dictator extends Quiz {
  bool charByChar = false;
  List<Choice> choices = [];
  List<String> _pattern = [];
  Answers answers = Answers([]);

  Talk? currentStage;

  @override
  initialize({List<Object>? args}) async {
    currentStage = args![0] as Talk;
    var chat = currentStage!.chats.where((c) => c.type == ChatType.user).first;
    _pattern = chat.value.split(" ");
    charByChar = _pattern.length < 2;
    if (charByChar) {
      _pattern = switch (chat.value.length) {
        < 5 => chat.value.split(""),
        _ => chat.value.splitByLength(2),
      };
    }

    choices = List.generate(_pattern.length, (i) => Choice(_pattern[i]));
    choices.shuffle();
    answers.value = [];
    state.value = QuizState.ready;
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
      state.value = _chechAnswers() ? QuizState.success : QuizState.fail;
      onResult?.call(state.value, "");
    }
  }

  void selectChoice(Choice choice) {
    answers.add(choice.text);
    choice.used = true;
    serviceLocator<Dictator>().checkAnswers();
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
