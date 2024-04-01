import 'package:audioplayers/audioplayers.dart';

import '../app_export.dart';

enum Narrator { alloy, echo, fable, nova, onyx, shimmer }

class Speaker extends IService {
  Future<void> play(
    String text, {
    bool force = false,
    bool reset = false,
    Narrator narrator = Narrator.onyx,
  }) async {
    serviceLocator<STT>().stop();
    // serviceLocator<Sounds>().stopAll();
    var player = serviceLocator<Sounds>().getPlayer(text);
    if (force) {
      player.stop();
    } else if (player.state == PlayerState.playing) {
      player.stop();
      return;
    }
    player.setPlaybackRate(narrator == Narrator.onyx ? 1 : 0.8);
    await player.play(
      UrlSource(
          "https://s1.matnyaar.ir/gpt/tts.php?voice=${narrator.name}&input=$text${reset ? "&nocache" : ""}"),
    );
    await Future.doWhile(() => Future.delayed(const Duration(milliseconds: 50))
        .then((_) => player.state != PlayerState.completed));
  }
}
