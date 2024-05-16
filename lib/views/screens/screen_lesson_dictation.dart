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
  Future<void> changeStep(BuildContext context, [int step = 1]) async {
    if (index.value < steps.length) {
      serviceLocator<Dictator>().initialize(args: [steps[index.value + 1]]);
    }
    await super.changeStep(context, step);
  }

  @override
  void runStep(Content child) {
    serviceLocator<Dictator>().start(onResult: _onDictationResult);
  }

  Future<void> _onDictationResult(QuizState state, String value) async {
    var state = serviceLocator<Dictator>().state.value;
    if (state == QuizState.success) {
      onStepResult(context, true);
    } else if (state == QuizState.fail) {
      onStepResult(context, false);
      await Future.delayed(const Duration(seconds: 1));
      serviceLocator<Dictator>().reset();
    }
  }

  @override
  updateContent() async {
    var talk = steps[index.value] as Talk;
    await super.updateContent();
    if (talk.type == ContentType.user) {
      await serviceLocator<Speaker>()
          .play(talk.targetValue, narrator: talk.type.narrator);
    }
  }

  @override
  Widget footerBuilder() {
    return const DictationBox();
  }
}
