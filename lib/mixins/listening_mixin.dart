import 'package:flutter/material.dart';

import '../app_export.dart';

mixin ListeningMixin<S extends AbstractScreen> on AbstractScreenState<S> {
  Widget listenerBuilder(Talk talk) {
    var voice = talk.type == ContentType.translate
        ? talk.nativeValue
        : talk.targetValue;
    return ListenerBox(
      hint: talk.nativeValue,
      answer: talk.targetValue,
      narrator: talk.type.narrator,
      voiceHint: voice,
    );
  }

  Future<void> listen(Talk talk) async {
    final account = serviceLocator<AccountProvider>();
    final voice = talk.type == ContentType.translate
        ? talk.nativeValue
        : talk.targetValue;
    await serviceLocator<Speaker>().play(voice, narrator: talk.type.narrator);
    serviceLocator<ListenerQuiz>().start(
      pattern: talk.targetValue,
      locale: account.metadata["targetLanguage"],
      exceptions: [account.account.user.displayName!.patternize()],
      onResult: (state, text) => onListeningResult(state, talk),
    );
  }

  Future<void> onListeningResult(QuizState state, Talk talk) async {}
}
