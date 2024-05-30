import 'dart:math';

import 'package:flutter/material.dart';

import '../app_export.dart';

class LessonController {
  List<Content> steps = [];
  Function(Content)? onQuizStart;
  Future<void> Function(Content)? onQuizEnd;
  Function(int, int, int)? onComplete;
  final ValueNotifier<int> stepIndex = ValueNotifier(-1);
  final ValueNotifier<double> footerSize = ValueNotifier(10);
  int _fouls = 0, _streakCorrects = 0, _maxCorrects = 0, _numQuizes = 0;

  String practice = "";

  Future<void> changeStep(int stepLength) async {
    if (stepIndex.value >= steps.length - 1) {
      for (var step in steps) {
        if (step.isQuiz) _numQuizes++;
      }
      var len = (steps.length / 2).round();
      var corrects = len - _fouls.max(5);
      debugPrint(
          "${corrects * 100 / len}% $corrects $_maxCorrects $len   ${3 - _fouls.max(2)}");
      await Future.delayed(const Duration(milliseconds: 500));
      onComplete?.call(corrects, _streakCorrects, _numQuizes);
      return;
    }

    stepIndex.value += stepLength;

    var step = steps[stepIndex.value];
    if ((step as Talk).personId == "practice") {
      practice = step.nativeValue;
      changeStep(1);
      return;
    }

    await onQuizStart?.call(step);
    if (!step.isQuiz) {
      onStepResult(true);
    }
    // await Future.delayed(const Duration(seconds: 15));
  }

  Future<void> onStepResult(bool isSuccess) async {
    var step = steps[stepIndex.value];
    if (isSuccess) {
      if (step.isQuiz) {
        serviceLocator<Sounds>().play("correct_${Random().nextInt(3)}");
        ++_streakCorrects;
        _maxCorrects = _streakCorrects.min(_maxCorrects);
      }
      await onQuizEnd?.call(step);
      changeStep(1);
    } else {
      if (step.isQuiz) {
        ++_fouls;
        _streakCorrects = 0;
        serviceLocator<Sounds>().play("wrong");
      }
    }
  }

  void dispose() {
    onComplete = null;
    onContentChange = null;
    onQuizEnd = null;
    onQuizStart = null;
  }
}

class Invoker extends ChangeNotifier {
  void invoke() => notifyListeners();
}
