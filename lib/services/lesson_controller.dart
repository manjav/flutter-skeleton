import 'dart:math';

import 'package:flutter/material.dart';

import '../app_export.dart';

class LessonController {
  ParentContent? root;
  int sentenceCount = 0;
  List<ParentContent> series = [];
  final Map<String, Talk> quizes = {};
  Function(int, int, int)? onComplete;
  final ValueNotifier<int> serieIndex = ValueNotifier(-1);
  final ValueNotifier<int> slideIndex = ValueNotifier(-1);
  final ValueNotifier<int> contentIndex = ValueNotifier(-1);
  final ValueNotifier<bool> slidePassed = ValueNotifier(true);

  ParentContent get currentSerie => series[serieIndex.value];
  ParentContent get currentSlide =>
      currentSerie.children[slideIndex.value] as ParentContent;
  Talk get currentContent => currentSlide.children[contentIndex.value] as Talk;

  int get uniqueIndex => slideIndex.value * 100 + contentIndex.value;

  void init(ParentContent root) {
    this.root = root;
    series = List.generate(
        root.children.length, (i) => root.children[i] as ParentContent);

    quizes.clear();
    for (ParentContent serie in series) {
      for (var slide in serie.children) {
        for (var talk in (slide as ParentContent).children) {
          talk = talk as Talk;
          talk.score = 0;
          if (talk.isQuiz) quizes[talk.id] = talk;
          sentenceCount++;
        }
      }
    }
  }

  Future<void> changeSerie(int stepLength) async {
    if (serieIndex.value >= series.length - stepLength) {
      int score = 0;
      for (var entry in quizes.entries) {
        score += entry.value.score.max(100);
      }
      onComplete?.call(sentenceCount, quizes.length, score);
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
    if (stepLength != 0) {
      slideIndex.value += stepLength;
      contentIndex.value = -1;
      changeContent(1);
    }
    slidePassed.value = false;
  }

  Future<void> changeContent(int stepLength) async {
    if (contentIndex.value >= currentSlide.children.length - stepLength) {
      changeSlide(1);
      return;
    }
    contentIndex.value += stepLength;
  }

  void onQuizResult(int score, String answer, Talk talk) {
    final listener = serviceLocator<ListenerQuiz>();
    quizes[talk.id]!.score = score;
    if (score > listener.minMatchLevel) {
      serviceLocator<Sounds>().play("correct_${Random().nextInt(3)}");
    } else {
      slidePassed.value = true;
      serviceLocator<Sounds>().play("wrong");
    }

    serviceLocator<AccountProvider>().writeStorage(
      collectionId: "log_${root!.id}",
      keyId: talk.id,
      values: {
        "score": score,
        "answer": answer,
        "expected": listener.pattern,
      },
    );
  }

  void dispose() => onComplete = null;
}

class Invoker extends ChangeNotifier {
  void invoke() => notifyListeners();
}
