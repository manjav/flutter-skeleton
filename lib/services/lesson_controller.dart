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
  Function(int, int, int, bool)? onComplete;
  final ValueNotifier<int> serieIndex = ValueNotifier(-1);
  final ValueNotifier<int> slideIndex = ValueNotifier(-1);
  final ValueNotifier<int> contentIndex = ValueNotifier(-1);
  final ValueNotifier<bool> slidePassed = ValueNotifier(true);
  Function(double)? onAssetLoadingProgress;
  Function(String)? onError;

  ParentContent get currentSerie => series[serieIndex.value];
  ParentContent get currentSlide =>
      currentSerie.children[slideIndex.value] as ParentContent;
  Talk get currentContent => currentSlide.children[contentIndex.value] as Talk;

  int get uniqueIndex => slideIndex.value * 100 + contentIndex.value;

  Future<void> init(ParentContent root, {bool loadCaptions = true}) async {
    serviceLocator<Trackers>().startProgress(root.id);

    try {
      await _loadGroup(root);
    } on SkeletonException catch (e) {
      onError?.call(e.message);
      return;
    }
    // List list = (root.children[0] as ParentContent).children;
    // list.removeRange(0, 1);
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

    _loadAssets(loadCaptions);
  }

  Future<void> _loadGroup(ParentContent root) async {
    this.root = root;
    // Load group contents
    if (root.children.isEmpty) {
      await serviceLocator<AccountProvider>().loadGroup(root);
    }
    series = List.generate(
        root.children.length, (i) => root.children[i] as ParentContent);
  }

  void _loadAssets(bool loadCaptions) {
    serviceLocator<LessonAssets>().load(
      series: series,
      onComplete: () => changeSerie(1),
      onProgress: (p) => onAssetLoadingProgress?.call(p * 100),
      onError: onError!,
    );
  }

  Future<void> changeSerie(int stepLength) async {
    if (serieIndex.value >= series.length - stepLength) {
      callCompletedMethod();
      return;
    }

    serieIndex.value += stepLength;
    slideIndex.value = -1;
    changeSlide(1);

    serviceLocator<Trackers>().design(currentSerie.id);
  }

  void callCompletedMethod({bool showFeast = true}) {
    int score = 0;
    for (var entry in quizes.entries) {
      score += entry.value.score.max(100);
    }
    score = (score / quizes.length).round();

    serviceLocator<Trackers>().endProgress(
      root!.id,
      score,
      parameters: {
        "quizCount": quizes.length,
        "sentenceCount": sentenceCount,
      },
    );

    onComplete?.call(sentenceCount, quizes.length, score, showFeast);
  }

  Future<void> changeSlide(int stepLength) async {
    if (slideIndex.value >= currentSerie.children.length - stepLength) {
      changeSerie(1);
      return;
    }
    if (stepLength != 0) {
      var index = (slideIndex.value + stepLength)
          .clamp(0, currentSerie.children.length - 1);
      slideIndex.value = index;
      contentIndex.value = -1;
      changeContent(1);
    }

    // Disable next slide and enable after 1 second
    final quizes = currentSlide.children.where((c) => (c as Talk).isQuiz);
    if (quizes.isEmpty || (quizes.first as Talk).lastRecord == null) {
      slidePassed.value = false;
      _slidePassTimer?.cancel();
      if (quizes.isEmpty) {
        _slidePassTimer =
            Timer(const Duration(seconds: 1), () => slidePassed.value = true);
      }
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
      serviceLocator<MediaService>()
          .playSound("correct_${Random().nextInt(3)}");
    } else {
      serviceLocator<MediaService>().playSound("wrong");
    }
    slidePassed.value = true;

    serviceLocator<AccountProvider>().addToLeitner(
      talk.id,
      talk.targetValue,
      lastAnswer: answer,
      lastScore: score,
      step: (state == QuizState.success ? 1 : -1),
    );
  }

  void dispose() => onComplete = null;
}

class Invoker extends ChangeNotifier {
  void invoke() => notifyListeners();
}
