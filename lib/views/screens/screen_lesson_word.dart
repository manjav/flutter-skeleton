import 'package:flutter/material.dart';

import '../../app_export.dart';

class LessonWordScreen extends AbstractScreen {
  LessonWordScreen({super.key}) : super(Routes.word);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<LessonWordScreen>
    with LessonChatMixin {
  @override
  Future<void> nextStep(BuildContext context) async {
    if (index.value < content!.children.length) {
      serviceLocator<Dictator>()
          .initialize(args: [content!.children[index.value + 1]]);
    }
    await super.nextStep(context);
  }

  @override
  void startQuiz(Talk talk) {
    serviceLocator<Dictator>().start(onResult: _onQuizResult);
  }

  Future<void> _onQuizResult(QuizState state, String value) async {
    var state = serviceLocator<Dictator>().state.value;
    if (state == QuizState.success) {
      onQuizResult(context, true);
    } else if (state == QuizState.fail) {
      onQuizResult(context, false);
      await Future.delayed(const Duration(seconds: 1));
      serviceLocator<Dictator>().reset();
    }
  }

  @override
  Widget footerBuilder() {
    return const DictationBox();
  }
}
