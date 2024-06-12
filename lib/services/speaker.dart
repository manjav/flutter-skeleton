import 'package:audioplayers/audioplayers.dart';

import '../app_export.dart';

enum Narrator { alloy, echo, fable, nova, onyx, shimmer }

class Speaker extends IService {
  Future<void> play(
    String text, {
    bool force = false,
    bool reset = false,
    Narrator narrator = Narrator.onyx,
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
      player.setPlaybackRate(narrator == Narrator.onyx ? 1.3 : 0.8);
      if (onComplete != null) {
        player.eventStream.listen((event) {
          if (event.eventType == AudioEventType.complete) {
            onComplete();
          }
        });
      }
      await player.play(
        UrlSource(
            //narrator == Narrator.onyx?
            // "https://s1.matnyaar.ir/gpt/tts-ms.php?locale=fa-IR&voice=fa-IR-FaridNeural&input=$text${reset ? "&nocache" : ""}":
            "https://s1.matnyaar.ir/gpt/tts.php?voice=${narrator.name}&input=$text${reset ? "&nocache" : ""}"),
      );
      await Future.doWhile(() =>
          Future.delayed(const Duration(milliseconds: 50))
              .then((_) => player.state != PlayerState.completed));
    } finally {}
  }
}
