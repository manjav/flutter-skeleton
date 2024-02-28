import 'package:flutter/material.dart';

import '../../app_export.dart';

class LessonSpeakScreen extends AbstractScreen {
  LessonSpeakScreen({super.key}) : super(Routes.speak);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<LessonSpeakScreen>
    with LessonMixin {
  @override
  Future<void> startQuiz(Chat chat) async {
    // // if (kDebugMode) {
    //   await Future.delayed(const Duration(seconds: 2));
    //   _onSTTResult(STTState.success, chat.value);
    // } else {
    serviceLocator<STT>().start(
      locale: scenario!.targetLanguage,
      pattern: chat.value,
      onResult: _onQuizResult,
    );
    // }
  }

  Future<void> _onQuizResult(QuizState state, String text) async {
    const duration = Duration(milliseconds: 1500);
    serviceLocator<STT>().stop();
    if (state == QuizState.success) {
      await Future.delayed(duration);
      serviceLocator<STT>().state.value = QuizState.none;
      onQuizResult(true);
    } else if (state == QuizState.fail) {
      onQuizResult(false);
      await Future.delayed(duration);
      serviceLocator<STT>().start();
    }
  }

  @override
  Widget footerBuilder() {
    return Column(children: [
      DirText(currentTalk!.chats.first.value),
      SizedBox(height: 24.d),
      ListenerBox(currentTalk!.chats[1])
    ]);
  }
}
