// ignore_for_file: must_be_immutable

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
  String pattern = "";
  String hintVoice = "";
  String repeatVoice = "";
  String logs = "none";
  int minMatchLevel = 95;
  Narrator narrator = Narrator.shimmer;
  final SpeechToText _speech = SpeechToText();
  final ValueNotifier<double> audioLevel = ValueNotifier(0);
  SpeechRecognitionResult result = SpeechRecognitionResult([], true);
  final ValueNotifier<String> recognizedWords = ValueNotifier("");

  final double _minSoundLevel = Platform.isIOS ? -70 : -10;
  final double _maxSoundLevel = Platform.isIOS ? -20 : 10;
  DateTime _lastLevelChanged = DateTime.now();
  bool _isRepeatPlayed = false;
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
    log('Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
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
      if (recognizedWords.value.isEmpty) {
        state.value = QuizState.ready;
        onResult?.call(state.value, result.recognizedWords, _matchLevel);
      } else if (_isRepeatPlayed) {
        onResult?.call(state.value, result.recognizedWords, _matchLevel);
      }
    }
  }

  void listen({
    required String pattern,
    required String hintVoice,
    required String repeatVoice,
    String? locale,
    int minMatchLevel = 95,
    List<String>? exceptions,
    bool autoStart = true,
    bool shouldPlayHint = true,
    Function(QuizState state, String text, int mathLevel)? onResult,
  }) async {
    if (state.value.index <= QuizState.listening.index) {
      _speech.cancel();
    }

    state.value = QuizState.none;
    this.hintVoice = hintVoice;
    this.repeatVoice = repeatVoice;
    this.pattern = pattern.patternize();
    if (locale != null) this.locale = locale;
    if (exceptions != null) this.exceptions = exceptions;
    this.minMatchLevel = minMatchLevel;
    recognizedWords.value = "";
    state.value = QuizState.ready;
    if (!autoStart) {
      this.onResult = onResult;
      return;
    }
    log("Start listen ${this.pattern}");

    await Future.delayed(const Duration(milliseconds: 500));
    if (shouldPlayHint) {
      await serviceLocator<Speaker>().playLocal(hintVoice);
    }
    super.start(onResult: onResult);

    final options = SpeechListenOptions(
        onDevice: false,
        listenMode: ListenMode.deviceDefault,
        cancelOnError: true,
        partialResults: true,
        autoPunctuation: true,
        enableHapticFeedback: true);
    // Note that `listenFor` is the maximum, not the minimum, on some
    // systems recognition will be stopped before this value is reached.
    // Similarly `pauseFor` is a maximum not a minimum and may be ignored
    // on some devices.

    var duration = (this.pattern.length * 220).min(2000);
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
    listen(
        pattern: pattern,
        hintVoice: hintVoice,
        repeatVoice: repeatVoice,
        shouldPlayHint: false,
        onResult: onResult);
  }

  @override
  Future<void> stop() async {
    if (!isEnable) return;
    super.stop();
    await _speech.stop();
    audioLevel.value = 0.0;
  }

  Future<void> _proccessResult() async {
    for (var alternate in result.alternates) {
      // print("${alternate.recognizedWords} ${alternate.confidence}");
      var insert = alternate.recognizedWords.patternize();
      if (insert.contains(pattern)) {
        insert = recognizedWords.value = pattern;
      } else {
        recognizedWords.value = alternate.recognizedWords;
      }

      _matchLevel = ratio(pattern, insert);
      // if (exception.isNotEmpty) {
      //   minMatchLevel =
      //       100 - (100 * exception.length / pattern!.length).round();
      // }
      if (state.value.index > QuizState.listening.index) return;
      logs = "=> $insert ratio: $_matchLevel/$minMatchLevel";
      if (_matchLevel > minMatchLevel) {
        state.value = QuizState.success;
        dispatchresult();
        return;
      }
    }

    if (result.recognizedWords.length > pattern.length * 2) {
      state.value = QuizState.failure;
      dispatchresult();
      return;
    }

    if (result.finalResult) {
      state.value =
          recognizedWords.value.isEmpty ? QuizState.ready : QuizState.failure;
      dispatchresult();
    }
  }

  void dispatchresult() async {
    _isRepeatPlayed = false;
    stop();
    if (repeatVoice.isNotEmpty) {
      await serviceLocator<Speaker>().playLocal(repeatVoice);
    } else {
      await Future.delayed(const Duration(seconds: 1));
    }
    _isRepeatPlayed = true;
    if (_speech.lastStatus == "done") {
      onResult?.call(state.value, result.recognizedWords, _matchLevel);
    }
  }
}
