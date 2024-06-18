import 'package:audioplayers/audioplayers.dart';

import '../export.dart';

abstract class ISounds extends IService {
  void play(String name, {String? channel});
  void playMusic();
  void stop(String channel);
  void stopAll();
  void pauseAll();
  void resumeMusic();
}

class Sounds extends ISounds {
  @override
  initialize({List<Object>? args}) {
    super.initialize();
  }

/*
 * Load, cache and play sounds
 */
  // var _index = 0;
  final Map<String, AudioPlayer> _players = {};
  final _sounds = <String, DeviceFileSource>{};

  @override
  Future<void> play(String name, {String? channel, bool loop = false}) async {
    AudioPlayer player;
    if (name.isEmpty) return;
    if (channel == null) {
      if (!Pref.sfx.getBool()) return;
      player = _findPlayer(name);
    } else {
      if (channel == "music" && !Pref.music.getBool()) return;
      player = _findPlayer(channel);
    }

    if (loop) player.setReleaseMode(ReleaseMode.loop);

    if (_sounds.containsKey(name)) {
      try {
        player.play(_sounds[name]!);
      } catch (e) {
        log('$e');
      }
      return;
    }

    var extension = AssetType.sound.extension;
    var md5 = LoaderWidget.hashMap['$name.$extension'];
    var file = await Loader().load(
        '$name.$extension', '${LoaderWidget.baseURL}/sounds/$name.$extension',
        hash: md5);
    if (file == null) return;
    var isExits = await file.exists();
    if (!isExits) return;
    player.play(_sounds[name] = DeviceFileSource(file.path));
  }

  ///we have bug here because in mouse down and mouse up we get same audio player
  ///for example audio player index 1 [time between call these is very tiny and return same audio player]
  ///there fore we set two source in a small time with these way we didn't get any error
  AudioPlayer _findPlayer(String name) {
    // var entries = _players.entries;
    // for (var e in entries) {
    //   if (e.key.startsWith('_') && e.value.state != PlayerState.playing) {
    //     return e.value;
    //   }
    // }
    return _players[name] ?? (_players[name] = AudioPlayer());
  }

  @override
  void stop(String channel) {
    _players[channel]!.stop();
  }

  @override
  void stopAll() {
    var entries = _players.entries;
    for (var e in entries) {
      e.value.stop();
    }
  }

  @override
  void playMusic() {
    play('main_theme', channel: "music", loop: true);
  }

  @override
  void pauseAll() {
    var entries = _players.entries;
    for (var e in entries) {
      e.value.pause();
    }
  }

  @override
  void resumeMusic() {
    var player = _findPlayer("main_theme");
    if (player.source == null) {
      playMusic();
    } else {
      player.resume();
    }
  }
}
