import 'package:flutter/material.dart';

import '../../app_export.dart';

class LessonDictationScreen extends AbstractScreen {
  LessonDictationScreen({super.key}) : super(Routes.dictation);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<LessonDictationScreen>
    with LessonChatMixin {
  @override
  Future<void> nextStep(BuildContext context) async {
    if (index.value < steps.length) {
      serviceLocator<Dictator>().initialize(args: [steps[index.value + 1]]);
    }
    await super.nextStep(context);
  }

  @override
  void startQuiz(Content child) {
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
  updateContent() async {
    var talk = steps[index.value] as Talk;
    if (talk.type == ContentType.user) {
      serviceLocator<Speaker>()
          .play(talk.targetValue, narrator: talk.type.narrator);
    }
    await super.updateContent();
  }

  @override
  Widget footerBuilder() {
    return const DictationBox();
  }
}
