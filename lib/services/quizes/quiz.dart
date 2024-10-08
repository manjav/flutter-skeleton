import 'package:flutter/material.dart';

import '../../app_export.dart';

class Quiz extends IService {
  bool isEnable = false;
  Function(QuizState, String, int, bool)? onResult;
  Talk? talk;
  final ValueNotifier<QuizState> state = ValueNotifier(QuizState.none);

  void start({
    required Talk talk,
    Function(QuizState, String, int, bool)? onResult,
  }) {
    isEnable = true;
    this.talk = talk;
    state.value = QuizState.waiting;
    if (onResult != null) this.onResult = onResult;
  }

  void stop() {
    isEnable = false;
  }
}

enum QuizState {
  none,
  ready,
  waiting,
  listening,
  success,
  failure,
  error;
}

class QuizRecord {
  final QuizState state;
  final String answer;
  QuizRecord({required this.state, required this.answer});
}
