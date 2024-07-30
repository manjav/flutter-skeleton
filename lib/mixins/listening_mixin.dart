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

  Future<void> listen(Talk talk) async {
    final account = serviceLocator<AccountProvider>();
    await Future.delayed(const Duration(seconds: 2));
    serviceLocator<ListenerQuiz>().listen(
      pattern: talk.targetValue,
      locale: account.metadata["targetLanguage"],
      hintVoice: talk.getText(talk.type.textSide),
      repeatVoice: talk.type == ContentType.repeat ? "" : talk.targetValue,
      exceptions: [account.account.user.displayName!.patternize()],
      onResult: (state, text) => onListeningResult(state, talk),
    );
  }

  Future<void> onListeningResult(QuizState state, Talk talk) async {}
}
