import 'package:flutter/material.dart';

import '../../app_export.dart';

class LessonWordScreen extends AbstractScreen {
  LessonWordScreen({super.key}) : super(Routes.word);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<LessonWordScreen>
    with LessonMixin {
  @override
  Future<void> nextStep() async {
    if (index.value < content!.children.length) {
    }
    await super.nextStep();
  }

  @override
  void startQuiz(Talk talk) {
  }

  Future<void> _onQuizResult(QuizState state, String value) async {
  }

  @override
  Widget footerBuilder() {
  }
}
