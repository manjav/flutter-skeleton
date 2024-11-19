import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../app_export.dart';

class ListenerQuiz extends Quiz {
  static const int levelInterval = 100;
  String? locale;
  String _pattern = "";
  int minMatchLevel = 95;
  final SpeechToText _speech = SpeechToText();
  final ValueNotifier<double> audioLevel = ValueNotifier(0);
  SpeechRecognitionResult result = SpeechRecognitionResult([], true);
  final ValueNotifier<String> recognizedWords = ValueNotifier("");

  final double _minSoundLevel = Platform.isIOS ? -70 : -10;
  final double _maxSoundLevel = Platform.isIOS ? -20 : 10;
  DateTime _lastLevelChanged = DateTime.now();
  bool _hasMediaPlayed = false;
  bool _hasResultSent = false;
  List<String> exceptions = [];
  int _matchLevel = 0;
  MediaIntry? initialMedia, finalMedia;

  @override
  initialize({List<Object>? args}) async {
    if (isInitialized) return;
    try {
      var success = await _speech.initialize(
        debugLogging: false,
        onError: _errorListener,
        onStatus: _statusListener,
      );
      state.value = success ? QuizState.ready : QuizState.error;
    } catch (e) {
      state.value = QuizState.error;
    }
    super.initialize(args: args);
  }

  /// This callback is invoked each time new recognition results are
  void _resultListener(SpeechRecognitionResult result) {
    this.result = result;
    _proccessResult();
  }

  void _soundLevelListener(double level) {
    var value =
        ((level.clamp(_minSoundLevel, _maxSoundLevel) - _minSoundLevel) /
                (_maxSoundLevel - _minSoundLevel))
            .abs();
    var d = DateTime.now();
    if (d.difference(_lastLevelChanged).inMilliseconds < levelInterval) {
      return;
    }
    _lastLevelChanged = d;
    if ((audioLevel.value - value).abs() > 0.1) {
      audioLevel.value = Curves.easeInSine.transform(value);
    }
  }

  void _errorListener(SpeechRecognitionError error) {
    log('Received error status: $error, listening: ${_speech.isListening}');
    state.value = QuizState.error;
    audioLevel.value = 0;
  }

  void _statusListener(String status) {
    log('Received listener status: => $status, listening: ${_speech.isListening}');
    if (status == "listening") {
      state.value = QuizState.running;
    } else if (status == "done") {
      if (state.value == QuizState.running && recognizedWords.value.isEmpty) {
        state.value = QuizState.failure;
      }
      if (_hasMediaPlayed) {
        _sendResult("status", false);
      }
    }
  }

  @override
  void prepare({
    String? locale,
    required Talk talk,
    int minMatchLevel = 95,
    bool autoStart = false,
    MediaIntry? finalMedia,
    MediaIntry? initialMedia,
    List<String>? exceptions,
    Function(QuizState, String, int, bool, dynamic)? onResult,
  }) async {
    this.talk = talk;
    if (state.value.index < QuizState.initialize.index) {
      log("Listener not initialized yet!");
      return;
    }
    if (state.value.index <= QuizState.running.index) {
      _speech.cancel();
    }

    super.prepare(talk: talk, onResult: onResult);
    recognizedWords.value = "";
    if (talk.lastRecord != null) {
      await Future.delayed(const Duration(milliseconds: 100));
      state.value = talk.lastRecord!.state;
      recognizedWords.value = talk.lastRecord!.answer;
      _sendResult("lastRecord", true);
      return;
    }
    _pattern = talk.targetValue.patternize();
    if (locale != null) this.locale = locale;
    if (exceptions != null) this.exceptions = exceptions;
    this.minMatchLevel = minMatchLevel;
    recognizedWords.value = "";
    this.initialMedia = initialMedia;
    this.finalMedia = finalMedia;
    _hasMediaPlayed = false;
    _hasResultSent = false;
    // log("listen $_pattern");

    if (initialMedia!.type == MediaType.youtube) {
      await serviceLocator<MediaService>().play(initialMedia);
    }

    state.value = QuizState.ready;

    if (autoStart) {
      start();
    }
  }

  Future<void> start() async {
    state.value = QuizState.waiting;
    await Future.delayed(const Duration(milliseconds: 400));
    final options = SpeechListenOptions(
        listenMode: ListenMode.deviceDefault,
        cancelOnError: true,
        enableHapticFeedback: true);
    // Note that `listenFor` is the maximum, not the minimum, on some
    // systems recognition will be stopped before this value is reached.
    // Similarly `pauseFor` is a maximum not a minimum and may be ignored
    // on some devices.
    // if (_speech.lastStatus.isEmpty) return;
    var duration = (_pattern.length * 170).min(3000).max(10000);
    _speech.listen(
      listenOptions: options,
      localeId: locale,
      listenFor: const Duration(seconds: 30),
      pauseFor: Duration(milliseconds: duration),
      onSoundLevelChange: _soundLevelListener,
      onResult: _resultListener,
    );
  }

  @override
  Future<void> stop() async {
    if (!isEnable) return;
    super.stop();
    await _speech.stop();
    audioLevel.value = 0.0;
  }

  Future<void> _proccessResult() async {
    if (state.value.index > QuizState.running.index) return;
    final alternates = List<String>.generate(result.alternates.length,
        (i) => result.alternates[i].recognizedWords.patternize());
    for (var alternate in alternates) {
      // log("match '$alternate' '$_pattern'");
      if (alternate.contains(_pattern)) {
        recognizedWords.value = _pattern;
        _finalize(QuizState.success);
        return;
      }
    }
    for (var alternate in alternates) {
      _matchLevel = ratio(_pattern, alternate);
      if (state.value.index > QuizState.running.index) return;
      // log("fuzzy '$alternate' '$_pattern' $_matchLevel $minMatchLevel");
      if (_matchLevel > minMatchLevel) {
        recognizedWords.value = _pattern;
        _finalize(QuizState.success);
        return;
      }
    }
    if (result.recognizedWords.isNotEmpty) {
      recognizedWords.value = result.recognizedWords;
    }
    if (result.recognizedWords.length > _pattern.length * 2) {
      _finalize(QuizState.failure);
      return;
    }

    if (result.finalResult) {
      _finalize(QuizState.failure);
    }
  }

  void _finalize(QuizState state) async {
    this.state.value = state;
    stop();
    if (recognizedWords.value.isNotEmpty && finalMedia != null) {
      await serviceLocator<MediaService>().play(finalMedia);
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
    }
    _hasMediaPlayed = true;
    if (_speech.lastStatus == "done") {
      _sendResult("finalize", false);
    }
  }

  void _sendResult(String flag, bool isReserved) {
    if (_hasResultSent) return;
    // log("_dispatchResult $flag => ${recognizedWords.value} ${state.value}");
    onResult?.call(
      state.value,
      recognizedWords.value,
      _matchLevel,
      isReserved,
      null,
    );
    _hasResultSent = true;
  }
}
