import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';

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
          final side = talk.textSide;
          if (!loadCaptions && talk.type == ContentType.caption) {
            continue; // Load captions only for lessons
          }
          if (talk.type == ContentType.video) {
            _loadFile(AssetType.video, talk.targetValue, onComplete, onProgress,
                onError);
          } else if (talk.type == ContentType.image) {
            _loadFile(AssetType.image, talk.targetValue, onComplete, onProgress,
                onError);
          }

          if (talk.isQuiz) {
            _loadFile(AssetType.animation, "mic_panel", onComplete, onProgress,
                onError);
          }

          if (side != TranslationSide.none) {
            var text = talk.getText(side).simplify();
            _loadVoice(text, talk.narrator, onComplete, onProgress, onError);
          }
          if (talk.type == ContentType.translate) {
            var text = talk.targetValue.simplify();
            _loadVoice(text, Narrator.onyx, onComplete, onProgress, onError);
          }
        }
      }
    }
    if (_assets.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 100));
      onComplete();
    }
  }

  Future<void> _loadVoice(
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
      final path = "${narrator.name}__$text";
      final hashName = "${md5.convert(utf8.encode(path)).toString()}.mp5";
      final url =
          "${LoaderWidget.baseURL}/cache.php?voice=${narrator.name}&input=$text";
      final loader = Loader();
      try {
        await loader.load(hashName, url, hash: LoaderWidget.hashMap[hashName]);
      } catch (e) {
        if (tryCount > 2) {
          onError("Lesson asset '$text' not found!");
        } else {
          _loadVoice(
              text, narrator, onComplete, onProgress, onError, tryCount++);
          log("Retry sound loading $tryCount");
        }
      }

      _assets[text] = BytesSource(
        Uint8List.fromList(loader.bytes!),
        mimeType: "audio/mpeg",
      );
    } catch (e) {
      onError(e.toString());
    }
    _checkCompletion(onProgress, onComplete);
  }

  Future<void> _loadFile(
      AssetType assetType,
      String name,
      Function() onComplete,
      Function(double p1) onProgress,
      Function(String p1) onError) async {
    final path = "$name.${assetType.type}";
    if (_assets.containsKey(path)) return;
    _assets[path] = null;
    final loader = await LoaderWidget.load(assetType, name);
    _assets[path] = loader.metadata;

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
