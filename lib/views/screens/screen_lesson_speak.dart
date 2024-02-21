import 'package:flutter/foundation.dart';
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
    if (kDebugMode) {
      await Future.delayed(const Duration(seconds: 2));
      _onSTTResult(STTState.success, chat.value);
    } else {
      serviceLocator<STT>().startListening(
          locale: scenario!.targetLanguage,
          pattern: chat.value,
          onResult: _onSTTResult);
    }
  }

  Future<void> _onSTTResult(STTState state, String text) async {
    const duration = Duration(milliseconds: 1500);
    serviceLocator<STT>().stopListening();
    if (state == STTState.success) {
      await Future.delayed(duration);
      serviceLocator<STT>().state.value = STTState.none;
      onQuizResult(true);
    } else if (state == STTState.fail) {
      onQuizResult(false);
      await Future.delayed(duration);
      serviceLocator<STT>().startListening();
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
