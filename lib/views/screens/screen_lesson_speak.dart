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
    // await Future.delayed(const Duration(seconds: 2));
    // _onQuizResult(QuizState.success, child.targetValue);

    var account = serviceLocator<AccountProvider>();
    var easyMode =
        child.targetValue.contains(account.account.user.displayName!);

    serviceLocator<STT>().start(
      locale: account.metadata["targetLanguage"],
      pattern: child.targetValue,
      minMatchLevel: easyMode ? 60 : 90,
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
    if (index.value >= steps.length) {
      return const SizedBox();
    }
    return Column(children: [
      DirText("speaking_hint".l()),
      SizedBox(height: 24.d),
      ListenerBox(steps[index.value] as Talk,
          challengeMode: Get.arguments["challengeMode"])
    ]);
  }
}
