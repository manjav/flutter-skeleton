import 'package:flutter/material.dart';

import '../../app_export.dart';

class ChoiceQuiz extends Quiz {
  String answer = "";
  final List<String> choices = [];
  ButtonMode mode = ButtonMode.text;
  final ValueNotifier<int> selectedIndex = ValueNotifier(-1);

  @override
  void start({
    required Talk talk,
    Function(QuizState s, String t, int score, bool r)? onResult,
  }) {
    answer = "";
    selectedIndex.value = -1;

    super.start(talk: talk, onResult: onResult);
    choices.clear();
    final sections = talk.targetValue.split("∆");
    final index = int.parse(sections.last);
    choices.addAll(sections.first.split("|"));
    answer = choices[index];
    choices.shuffle();
    state.value = QuizState.ready;
  }

  void select(int index) {
    if (state.value == QuizState.success) {
      return;
    }
    var isCorrect = choices[index] == answer;
    state.value = isCorrect ? QuizState.success : QuizState.failure;
    selectedIndex.value = index;
    if (isCorrect) sendResult();
  }

  Future<void> sendResult() async {
    await Future.delayed(Duration(milliseconds: 500));
    onResult?.call(state.value, choices[selectedIndex.value], 0, false);
    choices.clear();
  }
}
