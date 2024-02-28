import 'package:flutter/material.dart';

import '../../app_export.dart';

class LessonListenScreen extends AbstractScreen {
  LessonListenScreen({super.key}) : super(Routes.listen);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<LessonListenScreen>
    with LessonMixin {
  @override
  Future<void> nextStep(int index) async {
    if (index < scenario!.thread.length) {
      serviceLocator<Dictator>().initialize(args: [scenario!.thread[index]]);
    }
    await super.nextStep(index);
  }

  @override
  void startQuiz(Chat chat) {
    serviceLocator<Dictator>().start(onResult: _onQuizResult);
  }

  Future<void> _onQuizResult(QuizState state, String value) async {
    var state = serviceLocator<Dictator>().state.value;
    if (state == QuizState.success) {
      onQuizResult(true);
    } else if (state == QuizState.fail) {
      onQuizResult(false);
      await Future.delayed(const Duration(seconds: 1));
      serviceLocator<Dictator>().reset();
    }
  }

  @override
  Widget footerBuilder() {
    return const DictationBox();
  }
}
