import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../app_export.dart';

class LessonController {
  ParentContent? root;
  int sentenceCount = 0;
  Timer? _slidePassTimer;
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
    serviceLocator<Trackers>().startProgress(root.id);
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

      serviceLocator<Trackers>().endProgress(root!.id, score, parameters: {
        "quizCount": quizes.length,
        "sentenceCount": sentenceCount,
      });

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
      slideIndex.value =
          (slideIndex.value + stepLength).max(currentSerie.children.length);
      contentIndex.value = -1;
      changeContent(1);
    }
    slidePassed.value = false;
    _slidePassTimer?.cancel();
    if (currentSlide.children.where((c) => (c as Talk).isQuiz).isEmpty) {
      _slidePassTimer =
          Timer(const Duration(seconds: 1), () => slidePassed.value = true);
    }
  }

  Future<void> changeContent(int stepLength) async {
    if (contentIndex.value >= currentSlide.children.length - stepLength) {
      changeSlide(1);
      return;
    }
    contentIndex.value += stepLength;
  }

  void onQuizResult(QuizState state, String answer, int score, Talk talk) {
    final listener = serviceLocator<ListenerQuiz>();
    talk.lastRecord = QuizRecord(state: state, answer: answer);
    quizes[talk.id]!.score = score;
    if (score > listener.minMatchLevel) {
      serviceLocator<Sounds>().play("correct_${Random().nextInt(3)}");
    } else {
      serviceLocator<Sounds>().play("wrong");
    }
    slidePassed.value = true;

    serviceLocator<AccountProvider>().writeStorage(
      collectionId: "log_${root!.id}",
      keyId: talk.id,
      values: {
        "score": score,
        "answer": answer,
        "expected": talk.targetValue,
      },
    );
  }

  void dispose() => onComplete = null;
}

class Invoker extends ChangeNotifier {
  void invoke() => notifyListeners();
}
