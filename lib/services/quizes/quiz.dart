import 'package:flutter/material.dart';

import '../../app_export.dart';

class Quiz extends IService {
  bool isEnable = false;
  Function(QuizState, String)? onResult;
  final ValueNotifier<QuizState> state = ValueNotifier(QuizState.none);

  void start({
    Function(QuizState, String)? onResult,
  }) {
    isEnable = true;
    state.value = QuizState.waiting;
    if (onResult != null) this.onResult = onResult;
  }

  void stop() {
    isEnable = false;
  }
}

enum QuizState { none, initialized, waiting, ready, success, fail, error }
