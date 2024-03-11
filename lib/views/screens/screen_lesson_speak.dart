import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class LessonSpeakScreen extends AbstractScreen {
  LessonSpeakScreen({super.key}) : super(Routes.speak);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<LessonSpeakScreen>
    with LessonChatMixin {
  @override
  Future<void> startQuiz(Content child) async {
    await Future.delayed(const Duration(seconds: 2));
    _onQuizResult(QuizState.success, child.targetValue);
    serviceLocator<STT>().start(
      locale: serviceLocator<AccountProvider>().metadata["targetLanguage"],
      pattern: child.targetValue.simple(),
      onResult: _onQuizResult,
    );
  }

  Future<void> _onQuizResult(QuizState state, String text) async {
    const duration = Duration(milliseconds: 1500);
    serviceLocator<STT>().stop();
    if (state == QuizState.success) {
      await Future.delayed(duration);
      serviceLocator<STT>().state.value = QuizState.none;
      if (mounted) {
        onQuizResult(context, true);
      }
    } else if (state == QuizState.fail) {
      onQuizResult(context, false);
      await Future.delayed(duration);
      serviceLocator<STT>().start();
    }
  }

  @override
  Widget footerBuilder() {
    if (index.value >= content!.children.length) {
      return const SizedBox();
    }
    return Column(children: [
      DirText("speaking_hint".l()),
      SizedBox(height: 24.d),
      ListenerBox(content!.children[index.value] as Talk,
          challengeMode: Get.arguments["challengeMode"])
    ]);
  }
}
