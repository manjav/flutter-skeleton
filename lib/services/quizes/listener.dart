import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../app_export.dart';

class ListenerQuiz extends Quiz {
  static const int levelInterval = 100;
  Talk? talk;
  String? locale;
  String _pattern = "";
  int minMatchLevel = 95;
  Narrator narrator = Narrator.shimmer;
  final SpeechToText _speech = SpeechToText();
  final ValueNotifier<double> audioLevel = ValueNotifier(0);
  SpeechRecognitionResult result = SpeechRecognitionResult([], true);
  final ValueNotifier<String> recognizedWords = ValueNotifier("");

  final double _minSoundLevel = Platform.isIOS ? -70 : -10;
  final double _maxSoundLevel = Platform.isIOS ? -20 : 10;
  DateTime _lastLevelChanged = DateTime.now();
  bool _hasSoundPlayed = false;
  bool _hasResultSent = false;
  List<String> exceptions = [];
  int _matchLevel = 0;

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
      state.value = QuizState.listening;
    } else if (status == "done") {
      if (state.value == QuizState.listening && recognizedWords.value.isEmpty) {
        state.value = QuizState.failure;
      }
      if (_hasSoundPlayed) {
        _sendResult("status", false);
      }
    }
  }

  void listen({
    required Talk talk,
    String? locale,
    int minMatchLevel = 95,
    List<String>? exceptions,
    Function(QuizState, String, int, bool)? onResult,
  }) async {
    if (state.value.index < QuizState.ready.index) {
      log("Listener not initialized yet!");
      return;
    }
    if (state.value.index <= QuizState.listening.index) {
      _speech.cancel();
    }

    state.value = QuizState.none;
    this.talk = talk;
    _pattern = talk.targetValue.patternize();
    if (locale != null) this.locale = locale;
    if (exceptions != null) this.exceptions = exceptions;
    this.minMatchLevel = minMatchLevel;
    recognizedWords.value = "";
    state.value = QuizState.ready;
    _hasSoundPlayed = false;
    _hasResultSent = false;

    if (talk.lastRecord != null) {
      state.value = talk.lastRecord!.state;
      _sendResult("lastRecord", true);
      return;
    }
    // log("listen $_pattern");

    await Future.delayed(const Duration(milliseconds: 500));
    var initalVoice = talk.getText(talk.textSide);
    if (initalVoice.isNotEmpty) {
      await serviceLocator<Speaker>().playLocal(initalVoice);
    }
    super.start(onResult: onResult);

    final options = SpeechListenOptions(
        listenMode: ListenMode.deviceDefault,
        cancelOnError: true,
        autoPunctuation: true,
        enableHapticFeedback: true);
    // Note that `listenFor` is the maximum, not the minimum, on some
    // systems recognition will be stopped before this value is reached.
    // Similarly `pauseFor` is a maximum not a minimum and may be ignored
    // on some devices.

    var duration = (_pattern.length * 230).min(3000);
    _speech.listen(
      listenOptions: options,
      localeId: this.locale,
      listenFor: const Duration(seconds: 30),
      pauseFor: Duration(milliseconds: duration),
      onSoundLevelChange: _soundLevelListener,
      onResult: _resultListener,
    );
  }

  Future<void> toggle({
    required String pattern,
    required String hintVoice,
    required String repeatVoice,
  }) async {
    recognizedWords.value = "";
    if (state.value == QuizState.listening ||
        state.value == QuizState.waiting) {
      _speech.cancel();
      state.value = QuizState.ready;
      return;
    }
    listen(talk: talk!, onResult: onResult);
  }

  @override
  Future<void> stop() async {
    if (!isEnable) return;
    super.stop();
    await _speech.stop();
    audioLevel.value = 0.0;
  }

  Future<void> _proccessResult() async {
    if (state.value.index > QuizState.listening.index) return;
    for (var alternate in result.alternates) {
      var insert = alternate.recognizedWords.patternize();
      if (insert.contains(_pattern)) {
        recognizedWords.value = _pattern;
        _finalize(QuizState.success);
        return;
      }
      _matchLevel = ratio(_pattern, insert);
      // log("'$insert' '$_pattern' $_matchLevel");
      if (state.value.index > QuizState.listening.index) return;
      // logs = "=> $insert , ratio: $_matchLevel/$minMatchLevel";
      if (_matchLevel > minMatchLevel) {
        recognizedWords.value = _pattern;
        _finalize(QuizState.success);
        return;
      }
    }
    if (result.recognizedWords.isNotEmpty) {
      recognizedWords.value = result.recognizedWords.patternize();
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
    if (recognizedWords.value.isNotEmpty && talk!.type != ContentType.repeat) {
      await serviceLocator<Speaker>()
          .playLocal(talk!.targetValue, skipOnError: true);
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
    }
    _hasSoundPlayed = true;
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
    );
    _hasResultSent = true;
  }
}
