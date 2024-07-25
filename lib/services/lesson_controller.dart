import 'dart:math';

import 'package:flutter/material.dart';

import '../app_export.dart';

class LessonController {
  List<ParentContent> series = [];
  Function(int, int, int)? onComplete;
  final ValueNotifier<int> serieIndex = ValueNotifier(-1);
  final ValueNotifier<int> slideIndex = ValueNotifier(-1);
  final ValueNotifier<int> contentIndex = ValueNotifier(-1);
  final ValueNotifier<bool> slidePassed = ValueNotifier(true);

  // int _fouls = 0, _streakCorrects = 0, _maxCorrects = 0, _numQuizes = 0;

  ParentContent get currentSerie => series[serieIndex.value];
  ParentContent get currentSlide =>
      currentSerie.children[slideIndex.value] as ParentContent;
  Talk get currentContent => currentSlide.children[contentIndex.value] as Talk;

  int get uniqueIndex => slideIndex.value * 100 + contentIndex.value;

  Future<void> changeSerie(int stepLength) async {
    if (serieIndex.value >= series.length - stepLength) {
      // for (var step in series) {
      //   if (step.isQuiz) _numQuizes++;
      // }
      // var len = (slides.length / 2).round();
      // var corrects = len - _fouls.max(5);
      // debugPrint(
      //     "${corrects * 100 / len}% $corrects $_maxCorrects $len   ${3 - _fouls.max(2)}");
      // await Future.delayed(const Duration(milliseconds: 500));
      onComplete?.call(0, 0, 0);
      return;
    }

    serieIndex.value += stepLength;
    slideIndex.value = -1;
    changeSlide(1);
  }

  Future<void> changeSlide(int stepLength) async {
    if (slideIndex.value >= currentSerie.children.length - stepLength) {
      changeSerie(1);
      return;
    }
    slideIndex.value += stepLength;
    contentIndex.value = -1;
    changeContent(1);
    slidePassed.value = false;
  }

  Future<void> changeContent(int stepLength) async {
    if (contentIndex.value >= currentSlide.children.length - stepLength) {
      changeSlide(1);
      return;
    }
    contentIndex.value += stepLength;
  }

  Future<void> onQuizResult(bool isSuccess) async {
    if (isSuccess) {
      serviceLocator<Sounds>().play("correct_${Random().nextInt(3)}");
      // ++_streakCorrects;
      // _maxCorrects = _streakCorrects.min(_maxCorrects);
    } else {
      // ++_fouls;
      // _streakCorrects = 0;
      slidePassed.value = true;
      serviceLocator<Sounds>().play("wrong");
    }
  }

  void dispose() => onComplete = null;
}

class Invoker extends ChangeNotifier {
  void invoke() => notifyListeners();
}
