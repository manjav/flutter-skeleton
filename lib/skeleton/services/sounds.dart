import 'package:audioplayers/audioplayers.dart';

import '../export.dart';

class Sounds extends IService {
/*
 * Load, cache and play sounds
 */
  // var _index = 0;
  final Map<String, AudioPlayer> _players = {};
  final _sounds = <String, DeviceFileSource>{};

  Future<AudioPlayer?> play(String name,
      {String? channel, bool loop = false}) async {
    AudioPlayer player;
    if (name.isEmpty) return null;
    if (channel == null) {
      if (!Pref.sfx.getBool()) return null;
      player = getPlayer(name);
    } else {
      if (channel == "music" && !Pref.music.getBool()) return null;
      player = getPlayer(channel);
    }

    if (loop) player.setReleaseMode(ReleaseMode.loop);

    if (_sounds.containsKey(name)) {
      try {
        player.play(_sounds[name]!);
      } catch (e) {
        log('$e');
      }
      return player;
    }

    var extension = AssetType.sound.extension;
    var md5 = LoaderWidget.hashMap['$name.$extension'];
    var file = await Loader().load(
        '$name.$extension', '${LoaderWidget.baseURL}/sounds/$name.$extension',
        hash: md5);
    player.play(_sounds[name] = DeviceFileSource(file!.path));
    return player;
  }

  ///we have bug here because in mouse down and mouse up we get same audio player
  ///for example audio player index 1 [time between call these is very tiny and return same audio player]
  ///there fore we set two source in a small time with these way we didn't get any error
  AudioPlayer getPlayer(String name) {
    // var entries = _players.entries;
    // for (var e in entries) {
    //   if (e.key.startsWith('_') && e.value.state != PlayerState.playing) {
    //     return e.value;
    //   }
    // }
    return _players[name] ?? (_players[name] = AudioPlayer());
  }

  void stop(String channel) {
    _players[channel]!.stop();
  }

  void stopAll() {
    var entries = _players.entries;
    for (var e in entries) {
      e.value.stop();
    }
  }

  void playMusic() {
    // play('main_theme', channel: "music", loop: true);
  }
}
