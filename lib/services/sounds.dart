import 'package:audioplayers/audioplayers.dart';

import '../utils/loader.dart';
import 'core/iservices.dart';
import 'prefs.dart';

abstract class ISounds extends IService {
  play(String name, {String extension, String? channel});
  stop(String channel);
  stopAll();
}

class Sounds extends ISounds {
  dynamic configs;
  String? baseURL;

  @override
  initialize({List<Object>? args}) {
    // play('main-theme', channel: "music");
    super.initialize();
  }

/*
 * Load, cache and play sounds
 */
  var _index = 0;
  final Map<String, AudioPlayer> _players = {};
  final _sounds = <String, DeviceFileSource>{};

  @override
  play(String name, {String extension = "mp3", String? channel}) {
    AudioPlayer player;
    if (channel == null) {
      if (!Prefs.getBool("settings_sfx")) return;
      player = _findPlayer();
    } else {
      if (channel == "music" && !Prefs.getBool("settings_music")) return;
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

    String? md5;
    if (configs != null) {
      md5 = configs!['files']['$name.$extension'];
    }
    Loader().load('$name.$extension', '${baseURL}sounds/$name.$extension',
        hash: md5, onDone: (file) async {
      player.play(_sounds[name] = DeviceFileSource(file.path));
    });
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
  stop(String channel) {
    _players[channel]!.stop();
  }

  @override
  stopAll() {
    var entries = _players.entries;
    for (var e in entries) {
      e.value.stop();
    }
  }
}