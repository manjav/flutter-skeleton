import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

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
  }) async {
    serviceLocator<ListenerQuiz>().stop();
    // serviceLocator<Sounds>().stopAll();
    var player = serviceLocator<Sounds>().getPlayer(text);
    if (force) {
      player.stop();
    } else if (player.state == PlayerState.playing) {
      player.stop();
      return;
    }

    final url = "${narrator.url}$text${reset ? "&nocache" : ""}";
    await player.play(UrlSource(url), volume: 1);
    await Future.doWhile(() => Future.delayed(const Duration(milliseconds: 100))
        .then((_) => player.state != PlayerState.completed));
  }

  final _sounds = <String, DeviceFileSource?>{};
  Future<void> loadAllSounds(
      List<ParentContent> series, Function() onComplete) async {
    _sounds.clear();
    for (var serie in series) {
      for (var slide in serie.children) {
        for (var talk in (slide as ParentContent).children) {
          talk = talk as Talk;
          final soundText = talk.getSoundId();
          if (soundText != null) {
            _loadFile(
                talk.id, "${talk.type.narrator.url}$soundText", onComplete);
          }
        }
      }
    }
  }

  Future<void> _loadFile(String id, String url, Function() onComplete) async {
    _sounds[id] = null;
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    if (response.statusCode != 200) {
      log('Failure status code 😱');
      return;
    }
    final bytes = await _readResponse(response);
    final unit8 = bytes!.buffer.asUint8List(32, bytes.lengthInBytes - 32);
    Directory dir = await getApplicationDocumentsDirectory();

    var tmpFile = "${dir.path}/$id.mp3";
    // ignore: unused_local_variable
    var writeFile = File(tmpFile).writeAsBytesSync(unit8);
    _sounds[id] = DeviceFileSource(tmpFile);

    if (_sounds.isEmpty) return;
    for (var entry in _sounds.entries) {
      if (entry.value == null) return;
    }
    onComplete();
  }

  Future<Uint8List?> _readResponse(HttpClientResponse response) {
    final bytes = <int>[];
    final completer = Completer<Uint8List?>();
    response.asBroadcastStream().listen(
        (List<int> newBytes) => bytes.addAll(newBytes),
        onDone: () => completer.complete(Uint8List.fromList(bytes)),
        onError: (d) => log("loading failed. $d"),
        cancelOnError: true);
    return completer.future;
  }

  Future<void> playLocal(
    String id, {
    bool force = false,
  }) async {
    serviceLocator<ListenerQuiz>().stop();
    // serviceLocator<Sounds>().stopAll();
    var player = serviceLocator<Sounds>().getPlayer(id);
    if (force) {
      player.stop();
    } else if (player.state == PlayerState.playing) {
      player.stop();
      return;
    }

    await player.play(_sounds[id]!);
    await Future.doWhile(() => Future.delayed(const Duration(milliseconds: 100))
        .then((_) => player.state != PlayerState.completed));
  }
}
