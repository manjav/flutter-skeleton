import 'package:flutter/material.dart';

import '../app_export.dart';

mixin ListeningMixin<S extends AbstractScreen> on AbstractScreenState<S> {
  Widget listenerBuilder(Talk talk) {
    final voice = talk.type == ContentType.translate
        ? talk.nativeValue
        : talk.targetValue;
    return ListenerBox(
      voice: voice,
      hint: talk.nativeValue,
      answer: talk.targetValue,
      narrator: talk.type.narrator,
      repeatVoice: talk.type != ContentType.repeat ? talk.targetValue : "",
    );
  }

  Future<void> listen(Talk talk) async {
    final voice = talk.type == ContentType.translate
        ? talk.nativeValue
        : talk.targetValue;
    final account = serviceLocator<AccountProvider>();
    serviceLocator<ListenerQuiz>().listen(
      hint: voice,
      pattern: talk.targetValue,
      narrator: talk.type.narrator,
      locale: account.metadata["targetLanguage"],
      repeatVoice: talk.type != ContentType.repeat ? talk.targetValue : "",
      exceptions: [account.account.user.displayName!.patternize()],
      onResult: (state, text) => onListeningResult(state, talk),
    );
  }

  Future<void> onListeningResult(QuizState state, Talk talk) async {}
}
