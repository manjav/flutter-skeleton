import 'package:flutter/material.dart';

import '../app_export.dart';

mixin ListeningMixin<S extends AbstractScreen> on AbstractScreenState<S> {
  Widget listenerBuilder(Talk talk) {
    return ListenerBox(
      hint: talk.nativeValue,
      answer: talk.targetValue,
      narrator: talk.type.narrator,
      voice: talk.getText(talk.type.textSide),
      repeatVoice: talk.type == ContentType.repeat ? "" : talk.targetValue,
    );
  }

  void listen(Talk talk) {
    final account = serviceLocator<AccountProvider>();

    // Change fuzzy acceptance level based on answer length
    final pattern = talk.targetValue;
    var minMatchLevel = 95;
    if (pattern.length < 10) {
      minMatchLevel = 84;
    } else if (pattern.length < 20) {
      minMatchLevel = 88;
    } else if (pattern.length < 30) {
      minMatchLevel = 92;
    }

    serviceLocator<ListenerQuiz>().listen(
      pattern: pattern,
      minMatchLevel: minMatchLevel,
      lastRecord: talk.lastRecord,
      locale: account.metadata["targetLanguage"],
      hintVoice: talk.getText(talk.type.textSide),
      repeatVoice: talk.type == ContentType.repeat ? "" : talk.targetValue,
      exceptions: [account.account.user.displayName!.patternize()],
      onResult: (state, text, score) =>
          onListeningResult(state, text, score, talk),
    );
  }

  void onListeningResult(QuizState state, String text, int score, Talk talk);
}
