import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:audioplayers/audioplayers.dart';
import 'package:lifetalk/app_export.dart';

enum AudioLoadMode { assets, network }

class MediaService extends IService {
  final _sounds = <String, Source>{};
  final Map<String, AudioPlayer> _audioPlayers = {};

  Future<void> play(MediaIntry? intry) async {
    if (intry == null) {
      return;
    }
    if (intry.type == MediaType.sound) {
      await playSound(intry.id);
    } else if (intry.type == MediaType.voice) {
      await playVoice(intry.id);
  }

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
  Future<void> playSound(
    String name, {
    String? channel,
    String? extension,
    bool loop = false,
    bool skipOnError = false,
    AudioLoadMode loadMode = AudioLoadMode.network,
  }) async {
    AudioPlayer player;
    if (name.isEmpty) return;
    if (channel == null) {
      if (!Pref.sfx.getBool()) return;
      player = getAudioPlayer(name);
    } else {
      if (channel == "music" && !Pref.music.getBool()) return;
      player = getAudioPlayer(channel);
    }

    if (loop) {
      player.setReleaseMode(ReleaseMode.loop);
    }

    if (_sounds.containsKey(name)) {
      try {
        if (player.state != audio.PlayerState.playing) {
          player.play(_sounds[name]!);
        }
      } catch (e) {
        player.state = audio.PlayerState.stopped;
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
      if (loader.bytes == null) return;
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
    await _waitingForComplete(player, skipOnError);
  }

  ///we have bug here because in mouse down and mouse up we get same audio player
  ///for example audio player index 1 [time between call these is very tiny and return same audio player]
  ///there fore we set two source in a small time with these way we didn't get any error
  AudioPlayer getAudioPlayer(String name) {
    // var entries = _players.entries;
    // for (var e in entries) {
    //   if (e.key.startsWith('_') && e.value.state != PlayerState.playing) {
    //     return e.value;
    //   }
    // }
    return _audioPlayers[name] ?? (_audioPlayers[name] = AudioPlayer());
  }

  void stop(String channel) {
    _audioPlayers[channel]!.stop();
  }

  Future<void> playVoice(String name) async {
    name = name.simplify();
    log("play => $name");
    var player = serviceLocator<MediaService>().getAudioPlayer(name);
    if (player.state == audio.PlayerState.playing) {
      player.stop();
    }

    try {
      await player.play(serviceLocator<LessonAssets>().get(name));
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
          return player.state != audio.PlayerState.completed && tries < 80;
        },
      ),
    );
  }

  void stopAll() {
    var entries = _audioPlayers.entries;
    for (var e in entries) {
      e.value.stop();
    }
  }
}

enum MediaType { voice, sound, video, youtube }

/// Current state of the player.
enum MediaState {
  /// Denotes State when player is not loaded with video.
  unknown,

  /// Denotes state when player loads first video.
  unStarted,

  /// Denotes state when player has ended playing a video.
  ended,

  /// Denotes state when player is playing video.
  playing,

  /// Denotes state when player is paused.
  paused,

  /// Denotes state when player is buffering bytes from the internet.
  buffering,

  /// Denotes state when player loads video and is ready to be played.
  cued,

  /// Denotes state when player loads video and is ready to be played.
  disposed,
}

class MediaIntry {
  int? end;
  int start = 0;
  String id = "";
  dynamic data;
  MediaType type;
  MediaIntry(this.type, this.id, {this.start = 0, this.end});
  MediaIntry.parse(this.type, String url) {
    final uri = Uri.parse(url);
    id = uri.pathSegments.last;
    start = int.parse(uri.queryParameters["start"] ?? "0");
    end = uri.queryParameters.containsKey("end")
        ? int.parse(uri.queryParameters["end"]!)
        : null;
  }

  final _stateController = StreamController<MediaState>.broadcast();

  /// Stream of changes on state.
  Stream<MediaState> get onStateChanged => _stateController.stream;
  MediaState _mediaState = MediaState.unknown;

  MediaState get state => _mediaState;

  /// The current playback state.
  /// It is only set, when the corresponding action succeeds.
  set _state(MediaState state) {
    if (_mediaState == MediaState.disposed) {
      throw Exception('Media has been disposed');
    }
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
    _mediaState = state;
  }

  /// Parse state from various sources
  void parseState(String name) {
    _state = MediaState.values
        .firstWhere((s) => s.name == name, orElse: () => MediaState.unknown);
  }
  }
