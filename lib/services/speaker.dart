import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

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
    var player = serviceLocator<Sounds>().getPlayer(text);
    if (force) {
      player.stop();
    } else if (player.state == PlayerState.playing) {
      player.stop();
      return;
    }

    try {
      final url = "${narrator.url}$text${reset ? "&nocache" : ""}";
      await player.play(UrlSource(url), volume: 1);
      await Future.doWhile(() =>
          Future.delayed(const Duration(milliseconds: 100))
              .then((_) => player.state != PlayerState.completed));
    } catch (e) {
      log(e.toString());
    }
  }

  final _sounds = <String, BytesSource?>{};
  Future<void> loadAllSounds({
    required List<ParentContent> series,
    required Function() onComplete,
    required Function() onError,
    bool loadCaptions = true,
  }) async {
    _sounds.clear();
    for (var serie in series) {
      for (var slide in serie.children) {
        for (var talk in (slide as ParentContent).children) {
          talk = talk as Talk;
          final side = talk.type.textSide;
          if (!loadCaptions && talk.type == ContentType.caption) {
            continue; // Load captions only for lessons
          }
          if (side != TranslationSide.none) {
            var text = talk.getText(side);
            _loadFile(text, talk.type.narrator, onComplete, onError);
          }
          if (talk.type == ContentType.translate) {
            var text = talk.targetValue;
            _loadFile(text, Narrator.onyx, onComplete, onError);
          }
        }
      }
    }
  }

  Future<void> _loadFile(
    String text,
    Narrator narrator,
    Function() onComplete,
    Function() onError, [
    int tryCount = 0,
  ]) async {
    if (_sounds.containsKey(text)) return;
    _sounds[text] = null;
    var request = await HttpClient().getUrl(Uri.parse("${narrator.url}$text"));
    var response = await request.close();
    if (response.statusCode != 200) {
      log('Failure status code 😱');
      return;
    }
    var md5 = response.headers.value("Content-Md5");
    final bytes = await _readResponse(response);
    if (!Loader.isHashMatch(bytes!.toList(), md5)) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (tryCount > 2) {
        onError();
      } else {
        _loadFile(text, narrator, onComplete, onError, tryCount++);
        log("Retry sound loading $tryCount");
      }
      return;
    }

    _sounds[text] = BytesSource(
      bytes.buffer.asUint8List(32, bytes.lengthInBytes - 32),
      mimeType: "audio/mpeg",
    );

    if (_sounds.isEmpty) return;
    for (var entry in _sounds.entries) {
      if (entry.value == null) return;
    }
    await Future.delayed(const Duration(milliseconds: 100));
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

  Future<void> playLocal(String text) async {
    serviceLocator<ListenerQuiz>().stop();
    var player = serviceLocator<Sounds>().getPlayer(text);
    if (player.state == PlayerState.playing) {
      player.stop();
    }

    try {
      int tries = 0;
      await player.play(_sounds[text]!);
      await Future.doWhile(
          () => Future.delayed(const Duration(milliseconds: 100)).then((_) {
                // tries++;
                return player.state != PlayerState.completed && tries < 80;
              }));
    } catch (e) {
      log(e.toString());
    }
  }
}
