import 'dart:async';

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

//   String get url {
//     return switch (this) {
//       ali => "https://s1.matnyaar.ir/gpt/tts-ms.php?voice=$value&input=",
//       farid =>
//         "https://s1.matnyaar.ir/gpt/tts-ms.php?voice=fa-IR-FaridNeural&input=",
//       _ => "https://s1.matnyaar.ir/gpt/tts.php?voice=$value&input=",
//     };
//   }
}
// locale=fa-IR&

class Speaker extends IService {
  Narrator defaultNarrator = Narrator.farid;

  Future<void> play(
    String text, {
    bool force = false,
    bool reset = false,
    Narrator narrator = Narrator.ali,
    bool skipOnError = false,
  }) async {
    serviceLocator<ListenerQuiz>().stop();
    var player = serviceLocator<Sounds>().getPlayer(text);
    if (force) {
      player.stop();
    } else if (player.state == PlayerState.playing) {
      player.stop();
      return;
    }

    try {
      const url = "";//"${narrator.url}$text${reset ? "&nocache" : ""}";
      await player.play(UrlSource(url), volume: 1);
      await _waitingForComplete(player, skipOnError);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> playLocal(
    String name, {
    bool skipOnError = false,
  }) async {
    name = name.simplify();
    log("play => $name");
    serviceLocator<ListenerQuiz>().stop();
    var player = serviceLocator<Sounds>().getPlayer(name);
    if (player.state == PlayerState.playing) {
      player.stop();
    }

    try {
      await player.play(serviceLocator<LessonAssets>().get(name));
      await _waitingForComplete(player, skipOnError);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _waitingForComplete(AudioPlayer player, bool skipOnError) async {
    int tries = 0;
    await Future.doWhile(
      () => Future.delayed(const Duration(milliseconds: 100)).then(
        (_) {
          if (skipOnError) tries++;
          return player.state != PlayerState.completed && tries < 80;
        },
      ),
    );
  }
}
