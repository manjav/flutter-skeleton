import 'package:audioplayers/audioplayers.dart';

import '../app_export.dart';

enum Narrator {
  ali,
  alloy,
  echo,
  fable,
  nova,
  onyx,
  shimmer,
  farid;

  String get value {
    return switch (this) {
      farid => "fa-IR-FaridNeural",
      _ => name,
    };
  }

  String get url {
    return switch (this) {
      ali => "https://s1.matnyaar.ir/gpt/tts-ms.php?voice=$value&input=",
      farid =>
        "https://s1.matnyaar.ir/gpt/tts-ms.php?voice=fa-IR-FaridNeural&input=",
      _ => "https://s1.matnyaar.ir/gpt/tts.php?voice=$value&input=",
    };
  }
}
// locale=fa-IR&

class Speaker extends IService {
  Narrator defaultNarrator = Narrator.farid;
  Future<void> play(
    String text, {
    bool force = false,
    bool reset = false,
    Narrator narrator = Narrator.ali,
    Function()? onComplete,
  }) async {
    try {
      serviceLocator<STT>().stop();
      // serviceLocator<Sounds>().stopAll();
      var player = serviceLocator<Sounds>().getPlayer(text);
      if (force) {
        player.stop();
      } else if (player.state == PlayerState.playing) {
        player.stop();
        return;
      }
      // player.setPlaybackRate(narrator == Narrator.onyx ? 1.3 : 0.8);
      if (onComplete != null) {
        player.eventStream.listen((event) {
          if (event.eventType == AudioEventType.complete) {
            onComplete();
          }
        });
      }

      final url = "${narrator.url}$text${reset ? "&nocache" : ""}";
      await player.play(UrlSource(url), volume: 1);
      await Future.doWhile(() =>
          Future.delayed(const Duration(milliseconds: 50))
              .then((_) => player.state != PlayerState.completed));
    } finally {}
  }
}
