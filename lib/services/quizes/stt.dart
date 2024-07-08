// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../app_export.dart';

class STT extends Quiz {
  static const int levelInterval = 100;
  String? locale;
  String? pattern;
  String logs = "none";
  int minMatchLevel = 90;
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
      state.value = success ? QuizState.initialized : QuizState.error;
    } catch (e) {
      state.value = QuizState.error;
    }
    super.initialize(args: args);
  }

  /// This callback is invoked each time new recognition results are
  void _resultListener(SpeechRecognitionResult result) {
    this.result = result;
    _proccessResult();
    if (result.finalResult) {
      onResult?.call(state.value, result.recognizedWords);
    }
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
      state.value = QuizState.ready;
    } else if (status == "done") {
      stop();
    }
  }

  @override
  void start({
    Function(QuizState p1, String p2)? onResult,
    String? locale,
    String? pattern,
    int minMatchLevel = 90,
    List<String>? exceptions,
  }) {
    // serviceLocator<Sounds>().stopAll();
    super.start(onResult: onResult);
    if (locale != null) this.locale = locale;
    if (pattern != null) this.pattern = pattern.patternize();
    if (exceptions != null) this.exceptions = exceptions;
    this.minMatchLevel = minMatchLevel;
    recognizedWords.value = "";
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
      pauseFor: const Duration(seconds: 5),
      listenFor: const Duration(seconds: 3),
      onSoundLevelChange: _soundLevelListener,
      onResult: _resultListener,
    );
  }

  @override
  void stop() {
    if (!isEnable) return;
    super.stop();
    log('stop');
    _speech.stop();
    audioLevel.value = 0.0;
  }

  void _proccessResult() {
    if (pattern == null) {
      state.value = result.finalResult ? QuizState.success : QuizState.fail;
    } else {
      // var words = result.alternates.where((a) =>
      //     pattern!.toLowerCase().contains(a.recognizedWords.toLowerCase()));
      // words.first.recognizedWords;
      recognizedWords.value = result.recognizedWords;
      // if (result.finalResult) {
      var insert = result.recognizedWords.patternize();
      // var exception = exceptions.firstWhere((ex) => pattern!.contains(ex),
      //     orElse: () => "");
      var rate = ratio(pattern!, insert);
      // if (exception.isNotEmpty) {
      //   minMatchLevel =
      //       100 - (100 * exception.length / pattern!.length).round();
      // }
      logs = "=> $insert ratio: $rate/$minMatchLevel";
      // log(log);
      if (result.finalResult) {
        state.value = rate > minMatchLevel ? QuizState.success : QuizState.fail;
      }
      if (state.value == QuizState.success) stop();
      // }
    }
  }
}
