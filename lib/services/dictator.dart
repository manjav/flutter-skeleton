import 'package:flutter/material.dart';

import '../app_export.dart';

class Dictator extends IService {
  bool charByChar = false;
  List<Choice> choices = [];
  List<String> answers = [], _pattern = [];
  final ValueNotifier<int> state = ValueNotifier(0);

  Talk? currentStage;

  void init(Talk stage) {
    currentStage = stage;
    var chat = stage.chats.where((c) => c.type == ChatType.user).first;
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
    answers = [];
    state.value = -3;
  }

  void reset() {
    answers = [];
    for (var c in choices) {
      c.used = false;
    }
    enable();
  }

  bool _chechAnswers() {
    for (var i = 0; i < answers.length; i++) {
      if (answers[i] != _pattern[i]) {
        return false;
      }
    }
    return true;
  }

  Future<void> checkAnswers() async {
    if (answers.length == _pattern.length) {
      state.value = _chechAnswers() ? -2 : -1;
    }
  }

  void enable() => state.value = 0;
}

class Choice {
  bool used = false;
  final String text;
  Choice(this.text);
}
