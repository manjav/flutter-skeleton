import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

import '../app_export.dart';

class LessonAssets with ILogger {
  final _assets = <String, dynamic>{};
  Future<void> load({
    required List<ParentContent> series,
    required Function(String) onError,
    required Function() onComplete,
    required Function(double) onProgress,
    bool loadCaptions = true,
  }) async {
    _assets.clear();
    for (var serie in series) {
      for (var slide in serie.children) {
        for (var talk in (slide as ParentContent).children) {
          talk = talk as Talk;
          final side = talk.type.textSide;
          if (!loadCaptions && talk.type == ContentType.caption) {
            continue; // Load captions only for lessons
          }
          if (talk.type == ContentType.video) {
            _loadVideo(talk, onComplete, onProgress, onError);
          }
          if (side != TranslationSide.none) {
            var text = talk.getText(side);
            _loadFile(
                text, talk.type.narrator, onComplete, onProgress, onError);
          }
          if (talk.type == ContentType.translate) {
            var text = talk.targetValue;
            _loadFile(text, Narrator.onyx, onComplete, onProgress, onError);
          }
        }
      }
    }
  }

  Future<void> _loadFile(
    String text,
    Narrator narrator,
    Function() onComplete,
    Function(double) onProgress,
    Function(String) onError, [
    int tryCount = 0,
  ]) async {
    if (_assets.containsKey(text)) return;
    _assets[text] = null;
    try {
      var request =
          await HttpClient().getUrl(Uri.parse("${narrator.url}$text"));
      var response = await request.close();
      if (response.statusCode != 200) {
        log('Failure status code 😱');
        _loadFile(text, narrator, onComplete, onProgress, onError, tryCount++);
        return;
      }
      var md5 = response.headers.value("Content-Md5");
      final bytes = await _readResponse(response);
      if (!Loader.isHashMatch(bytes!.toList(), md5)) {
        await Future.delayed(const Duration(milliseconds: 50));
        if (tryCount > 2) {
          onError("Lesson asset '$text' not found!");
        } else {
          _loadFile(
              text, narrator, onComplete, onProgress, onError, tryCount++);
          log("Retry sound loading $tryCount");
        }
        return;
      }

      _assets[text] = BytesSource(
        bytes.buffer.asUint8List(),
        mimeType: "audio/mpeg",
      );
    } catch (e) {
      onError(e.toString());
    }
    _checkCompletion(onProgress, onComplete);
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

  Future<void> _loadVideo(Talk talk, Function() onComplete,
      Function(double p1) onProgress, Function(String p1) onError) async {
    final path = "${talk.targetValue}.mp4";
    if (_assets.containsKey(path)) return;
    _assets[path] = null;

    final loader = Loader();
    final file = await loader.load(path, "${LoaderWidget.baseURL}/videos/$path",
        hash: LoaderWidget.hashMap[path]);
    _assets[path] = file;

    _checkCompletion(onProgress, onComplete);
  }

  Future<void> _checkCompletion(
    Function(double) onProgress,
    Function() onComplete,
  ) async {
    if (_assets.isEmpty) return;
    var progress = 0.0;
    for (var entry in _assets.entries) {
      if (entry.value != null) progress++;
    }
    progress = progress / _assets.length;
    onProgress(progress);

    if (progress < 1) return;
    await Future.delayed(const Duration(milliseconds: 100));
    onComplete();
  }

  get(String name) => _assets[name];
}
