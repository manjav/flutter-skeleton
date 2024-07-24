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
  String hint = "";
  String pattern = "";
  String repeatVoice = "";
  String logs = "none";
  int minMatchLevel = 90;
  Narrator narrator = Narrator.shimmer;
  final SpeechToText _speech = SpeechToText();
  final ValueNotifier<double> audioLevel = ValueNotifier(0);
  SpeechRecognitionResult result = SpeechRecognitionResult([], true);
  final ValueNotifier<String> recognizedWords = ValueNotifier("");

  final double _minSoundLevel = Platform.isIOS ? -70 : -10;
  final double _maxSoundLevel = Platform.isIOS ? -20 : 10;
  DateTime _lastLevelChanged = DateTime.now();

  List<String> exceptions = [];

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
    audioLevel.value = Curves.easeInSine.transform(value);
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
      }
      stop();
    }
  }

  void listen({
    required String hint,
    required String pattern,
    required Narrator narrator,
    required String repeatVoice,
    String? locale,
    int minMatchLevel = 93,
    List<String>? exceptions,
    bool shouldPlayHint = true,
    Function(QuizState p1, String p2)? onResult,
  }) async {
    // serviceLocator<Sounds>().stopAll();
    if (state.value.index <= QuizState.listening.index) {
      _speech.cancel();
    }

    state.value = QuizState.ready;
    this.hint = hint;
    this.narrator = narrator;
    this.repeatVoice = repeatVoice;
    this.pattern = pattern.patternize();
    if (locale != null) this.locale = locale;
    if (exceptions != null) this.exceptions = exceptions;
    this.minMatchLevel = minMatchLevel;
    recognizedWords.value = "";

    if (shouldPlayHint) {
      await Future.delayed(const Duration(milliseconds: 200));
      await serviceLocator<Speaker>().play(hint, narrator: narrator);
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
    _speech.listen(
      listenOptions: options,
      localeId: this.locale,
      pauseFor: const Duration(seconds: 10),
      listenFor: const Duration(seconds: 10),
      onSoundLevelChange: _soundLevelListener,
      onResult: _resultListener,
    );
  }

  Future<void> toggle(
      {required String hint,
      required String pattern,
      required String repeatVoice,
      required Narrator narrator}) async {
    recognizedWords.value = "";
    if (state.value == QuizState.listening ||
        state.value == QuizState.waiting) {
      _speech.cancel();
      state.value = QuizState.ready;
      return;
    }
    listen(
        hint: hint,
        pattern: pattern,
        narrator: narrator,
        repeatVoice: repeatVoice,
        shouldPlayHint: false);
  }

  @override
  Future<void> stop() async {
    if (!isEnable) return;
    super.stop();
    await _speech.stop();
    audioLevel.value = 0.0;
  }

  Future<void> _proccessResult() async {
    // for (var alternate in result.alternates) {
    //   print("${alternate.recognizedWords} ${alternate.confidence}");
    // }
    var insert = result.recognizedWords.patternize();
    if (insert.contains(pattern)) {
      insert = recognizedWords.value = pattern;
    } else {
      recognizedWords.value = result.recognizedWords;
    }

    var rate = ratio(pattern, insert);
    // if (exception.isNotEmpty) {
    //   minMatchLevel =
    //       100 - (100 * exception.length / pattern!.length).round();
    // }
    if (state.value.index > QuizState.listening.index) return;
    logs = "=> $insert ratio: $rate/$minMatchLevel";
    if (rate > minMatchLevel) {
      state.value = QuizState.success;
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
    if (repeatVoice.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 200));
      await serviceLocator<Speaker>().play(repeatVoice, narrator: narrator);
    }
    onResult?.call(state.value, result.recognizedWords);
    stop();
  }
}
