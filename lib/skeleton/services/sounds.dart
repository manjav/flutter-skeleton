import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

import '../export.dart';

enum AudioLoadMode { assets, network }

class Sounds extends IService {
  final _sounds = <String, Source>{};
  final Map<String, AudioPlayer> _players = {};

  /// Plays the audio with the given [name].
  ///
  /// The [name] is the name of the sound to play.
  ///
  /// The [loadMode] specifies how to load the sound. It can be either [AudioLoadMode.assets]
  /// or [AudioLoadMode.network].
  ///
  /// The [channel] is the channel to play the sound on. If it is `null`, the sound will be
  /// played on the default channel.
  ///
  /// The [loop] parameter specifies whether to loop the sound. It defaults to `false`.
  ///
  /// Throws an exception if the sound cannot be played.
  Future<void> play(
    String name, {
    String? channel,
    String? extension,
    bool loop = false,
    AudioLoadMode loadMode = AudioLoadMode.network,
  }) async {
    AudioPlayer player;
    if (name.isEmpty) return;
    if (channel == null) {
      if (!Pref.sfx.getBool()) return;
      player = getPlayer(name);
    } else {
      if (channel == "music" && !Pref.music.getBool()) return;
      player = getPlayer(channel);
    }

    if (loop) {
      player.setReleaseMode(ReleaseMode.loop);
    }

    if (_sounds.containsKey(name)) {
      try {
        if (player.state != PlayerState.playing) {
          player.play(_sounds[name]!);
        }
      } catch (e) {
        player.state = PlayerState.stopped;
        log('$e');
      }
      return;
    }

    extension ??= AssetType.sound.extension;
    if (loadMode == AudioLoadMode.network) {
      var md5 = LoaderWidget.hashMap['$name.$extension'];
      var loader = Loader();
      await loader.load(
          '$name.$extension', '${LoaderWidget.baseURL}/sounds/$name.$extension',
          hash: md5);

      var bytes = Uint8List.fromList(loader.bytes!);
      final source = BytesSource(
        bytes.buffer.asUint8List(32, bytes.lengthInBytes - 32),
        mimeType: "audio/mpeg",
      );
      player.play(_sounds[name] = source);
      // player.play(_sounds[name] = DeviceFileSource(file!.path));
      // player.play(UrlSource('${LoaderWidget.baseURL}/sounds/$name.$extension'));
    } else {
      player.play(_sounds[name] = AssetSource("sounds/$name.$extension"));
    }
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
}
