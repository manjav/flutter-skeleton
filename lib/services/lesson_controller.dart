import 'dart:math';

import 'package:flutter/material.dart';

import '../app_export.dart';

class LessonController {
  List<Talk> contents = [];
  List<GroupContent> topics = [];
  Function(Talk)? onQuizStart;
  Future<void> Function(Talk)? onQuizEnd;
  Future<void> Function()? onContentChange;
  Function(int, int, int)? onComplete;
  final ValueNotifier<int> topicIndex = ValueNotifier(-1);
  final ValueNotifier<int> contentIndex = ValueNotifier(-1);

  int _fouls = 0, _streakCorrects = 0, _maxCorrects = 0, _numQuizes = 0;

  String practice = "";

  GroupContent get currentTopic => topics[topicIndex.value];
  Talk get currentContent => currentTopic.children[contentIndex.value] as Talk;

  Future<void> changeTopic(int stepLength) async {
    if (topicIndex.value >= topics.length - stepLength) {
      for (var step in topics) {
        if (step.isQuiz) _numQuizes++;
      }
      var len = (topics.length / 2).round();
      var corrects = len - _fouls.max(5);
      debugPrint(
          "${corrects * 100 / len}% $corrects $_maxCorrects $len   ${3 - _fouls.max(2)}");
      await Future.delayed(const Duration(milliseconds: 500));
      onComplete?.call(corrects, _streakCorrects, _numQuizes);
      return;
    }

    topicIndex.value += stepLength;

    contents.clear();
    for (var child in currentTopic.children) {
      contents.add(child as Talk);
    }
    contentIndex.value = -1;
    changeContent(1);
  }

  Future<void> changeContent(int stepLength) async {
    if (contentIndex.value >= contents.length - stepLength) {
      return;
    }
    contentIndex.value += stepLength;
    await onContentChange?.call();
  }

  Future<void> onQuizResult(bool isSuccess) async {
    if (isSuccess) {
      serviceLocator<Sounds>().play("correct_${Random().nextInt(3)}");
      ++_streakCorrects;
      _maxCorrects = _streakCorrects.min(_maxCorrects);
      changeContent(1);
    } else {
      ++_fouls;
      _streakCorrects = 0;
      serviceLocator<Sounds>().play("wrong");
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
