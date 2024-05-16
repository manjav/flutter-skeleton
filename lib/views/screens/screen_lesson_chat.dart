import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class LessonChatScreen extends AbstractScreen {
  LessonChatScreen({super.key}) : super(Routes.chat);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<LessonChatScreen>
    with LessonChatMixin {
  @override
  Future<void> runStep(Content child) async {
    // await Future.delayed(const Duration(seconds: 2));
    // _onQuizResult(QuizState.success, child.targetValue);

    var account = serviceLocator<AccountProvider>();
    serviceLocator<STT>().start(
      locale: account.metadata["targetLanguage"],
      pattern: child.targetValue,
      exceptions: [account.account.user.displayName!.simple()],
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
        onStepResult(context, true);
      }
    } else if (state == QuizState.fail) {
      onStepResult(context, false);
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
