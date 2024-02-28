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
  void initState() {
    serviceLocator<Dictator>().state.addListener(_dictatorListener);
    super.initState();
  }

  @override
  Future<void> nextStep(int index) async {
    if (index < scenario!.thread.length) {
      serviceLocator<Dictator>().init(scenario!.thread[index]);
    }
    await super.nextStep(index);
  }

  @override
  void startQuiz(Chat chat) {
    serviceLocator<Dictator>().enable();
  }

  Future<void> _dictatorListener() async {
    var state = serviceLocator<Dictator>().state.value;
    if (state == -2) {
      onQuizResult(true);
    } else if (state == -1) {
      onQuizResult(false);
      await Future.delayed(const Duration(seconds: 1));
      serviceLocator<Dictator>().reset();
    }
  }

  @override
  Widget footerBuilder() {
    return const DictationBox();
  }

  @override
  void dispose() {
    serviceLocator<Dictator>().state.removeListener(_dictatorListener);
    super.dispose();
  }
}
