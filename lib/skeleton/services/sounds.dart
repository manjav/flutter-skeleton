import 'package:audioplayers/audioplayers.dart';

import '../utils/assets.dart';
import '../utils/loader.dart';
import '../views/widgets/loader_widget.dart';
import 'prefs.dart';
import 'services.dart';

abstract class ISounds extends IService {
  void play(String name, {String? channel});
  void playMusic();
  void stop(String channel);
  void stopAll();
}

class Sounds extends ISounds {
  @override
  initialize({List<Object>? args}) {
    super.initialize();
  }

/*
 * Load, cache and play sounds
 */
  var _index = 0;
  final Map<String, AudioPlayer> _players = {};
  final _sounds = <String, DeviceFileSource>{};

  @override
  Future<void> play(String name, {String? channel}) async {
    AudioPlayer player;
    if (name.isEmpty) return;
    if (channel == null) {
      if (!Pref.sfx.getBool()) return;
      player = _findPlayer();
    } else {
      if (channel == "music" && !Pref.music.getBool()) return;
      if (!_players.containsKey(channel)) {
        _players[channel] = AudioPlayer();
      }
      player = _players[channel]!;
    }

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
    player.play(_sounds[name] = DeviceFileSource(file!.path));
  }

  AudioPlayer _findPlayer() {
    var entries = _players.entries;
    for (var e in entries) {
      if (e.key.startsWith('_') && e.value.state != PlayerState.playing) {
        return e.value;
      }
    }
    return _players["_${_index++}"] = AudioPlayer();
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
    play('main_theme', channel: "music");
  }
}
