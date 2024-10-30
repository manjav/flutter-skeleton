import 'package:flutter/material.dart';

import '../app_export.dart';

mixin ListeningMixin<S extends AbstractScreen> on AbstractScreenState<S> {
  Widget microphoneBuilder(Talk talk) {
    return MicPanel(talk: talk);
  }

  void listen(
    Talk talk, {
    MediaIntry? initialMedia,
    MediaIntry? finalMedia,
  }) {
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

    final initalVoice = talk.getText(talk.textSide);
    initialMedia ??= (initalVoice.isNotEmpty
        ? MediaIntry(MediaType.voice, initalVoice)
        : null);
    finalMedia ??= talk.type != ContentType.repeat
        ? MediaIntry(MediaType.voice, talk.targetValue)
        : null;

    serviceLocator<ListenerQuiz>().listen(
      talk: talk,
      finalMedia: finalMedia,
      initialMedia: initialMedia,
      minMatchLevel: minMatchLevel,
      locale: account.metadata["targetLanguage"],
      onResult: (state, text, score, repeated) =>
          onListeningResult(state, text, score, talk, repeated),
    );
  }

  void onListeningResult(
      QuizState state, String text, int score, Talk talk, bool repeated);
}
