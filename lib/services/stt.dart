// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../app_export.dart';

enum STTState { none, disable, enable, success, fail, error, done }

class STT extends IService {
  static const int levelInterval = 100;
  String? locale;
  String? pattern;
  Function(STTState, String)? onResult;
  final SpeechToText _speech = SpeechToText();
  final ValueNotifier<double> audioLevel = ValueNotifier(0);
  final ValueNotifier<STTState> state = ValueNotifier(STTState.none);
  SpeechRecognitionResult result = SpeechRecognitionResult([], true);
  final ValueNotifier<String> recognizedWords = ValueNotifier("");

  final double _minSoundLevel = -10;
  final double _maxSoundLevel = 10;
  DateTime _lastLevelChanged = DateTime.now();

  @override
  initialize({List<Object>? args}) async {
    if (isInitialized) return;
    try {
      var success = await _speech.initialize(
        debugLogging: false,
        onError: _errorListener,
        onStatus: _statusListener,
      );
      state.value = success ? STTState.disable : STTState.error;
    } catch (e) {
      state.value = STTState.error;
    }
    super.initialize(args: args);
  }

  /// This callback is invoked each time new recognition results are
  void _resultListener(SpeechRecognitionResult result) {
    this.result = result;
    _proccessResult();
    recognizedWords.value = result.recognizedWords;
    onResult?.call(state.value, result.recognizedWords);
    _logEvent(
        'Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
  }

  void _soundLevelListener(double level) {
    var value = (level.clamp(_minSoundLevel, _maxSoundLevel) + 10) /
        (_maxSoundLevel - _minSoundLevel);
    var d = DateTime.now();
    if (d.difference(_lastLevelChanged).inMilliseconds < levelInterval) {
      return;
    }
    _lastLevelChanged = d;
    audioLevel.value = Curves.easeInSine.transform(value);
  }

  void _errorListener(SpeechRecognitionError error) {
    _logEvent(
        'Received error status: $error, listening: ${_speech.isListening}');
    state.value = STTState.error;
    audioLevel.value = 0;
  }

  void _statusListener(String status) {
    _logEvent(
        'Received listener status: $status, listening: ${_speech.isListening}');
    if (status == "done") {
      stopListening();
    }
  }

  // This is called each time the users wants to start a new speech
  void startListening({
    String? locale,
    Function(STTState, String)? onResult,
  }) {
    if (locale != null) this.locale = locale;
    if (onResult != null) this.onResult = onResult;
    if (state.value.index < STTState.enable.index) {
      return;
    }
    recognizedWords.value = "";
    state.value = STTState.enable;
    final options = SpeechListenOptions(
        onDevice: false,
        listenMode: ListenMode.confirmation,
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
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(seconds: 30),
      onSoundLevelChange: _soundLevelListener,
      onResult: _resultListener,
    );
  }

  void stopListening() {
    _logEvent('stop');
    _speech.stop();
    audioLevel.value = 0.0;
  }

  void setEnable(bool value, {String? pattern}) {
    if (pattern != null) {
      this.pattern = pattern;
    }
    recognizedWords.value = "";
    state.value = value ? STTState.enable : STTState.disable;
  }

  void _proccessResult() {
    if (!result.finalResult) {
      return;
    }
    if (pattern == null) {
      state.value = STTState.success;
    } else {
      var isCorrect = result.recognizedWords == pattern;
      state.value = isCorrect ? STTState.success : STTState.fail;
    }
  }

  void _logEvent(String eventDescription) {
    debugPrint('STT $eventDescription');
  }
}
