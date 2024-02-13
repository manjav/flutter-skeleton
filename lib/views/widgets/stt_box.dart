// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../app_export.dart';

enum STTState { none, disable, enable, success, fail, error, done }

class STTBox extends StatelessWidget {
  String? pattern;
  final String locale;
  final Function(STTState, String)? onResult;
  STTBox(this.locale, {this.onResult, super.key});
  final SpeechToText _speech = SpeechToText();

  final ValueNotifier<STTState> state = ValueNotifier(STTState.none);
  final ValueNotifier<String> _recognizedWords = ValueNotifier("");
  final ValueNotifier<double> _level = ValueNotifier(0);
  SpeechRecognitionResult result = SpeechRecognitionResult([], true);

  final int _levelInterval = 100;
  final double _minSoundLevel = -10;
  final double _maxSoundLevel = 10;
  DateTime _lastLevelChanged = DateTime.now();

  @override
  Widget build(BuildContext context) {
    _initSTT();
    var size = 128.d;
    return ValueListenableBuilder(
      valueListenable: state,
      builder: (context, value, child) {
        return Column(
          children: [
            Widgets.button(
              context,
              width: size,
              height: size,
              radius: size,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              color: TColors.primary10,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ValueListenableBuilder(
                    valueListenable: _level,
                    builder: (context, value, child) => AnimatedContainer(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(size)),
                        color: TColors.primary20,
                      ),
                      width: size * _level.value,
                      height: size * _level.value,
                      duration: Duration(milliseconds: _levelInterval),
                    ),
                  ),
                  Asset.load<SvgPicture>(
                    "mic",
                    width: size * 0.3,
                    svgColorFilter:
                        ColorFilter.mode(_getIconColor(), BlendMode.srcIn),
                  ),
                ],
              ),
              onPressed: startListening,
            ),
            ValueListenableBuilder(
              valueListenable: _recognizedWords,
              builder: (context, value, child) => Text(value,
                  style: TStyles.medium.copyWith(color: _getIconColor())),
            )
          ],
        );
      },
    );
  }

  Future<void> _initSTT() async {
    if (state.value != STTState.none) return;
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
  }

  /// This callback is invoked each time new recognition results are
  void _resultListener(SpeechRecognitionResult result) {
    this.result = result;
    _proccessResult();
    _recognizedWords.value = result.recognizedWords;
    onResult?.call(state.value, result.recognizedWords);
    _logEvent(
        'Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
  }

  void _soundLevelListener(double level) {
    var value = (level.clamp(_minSoundLevel, _maxSoundLevel) + 10) /
        (_maxSoundLevel - _minSoundLevel);
    var d = DateTime.now();
    if (d.difference(_lastLevelChanged).inMilliseconds < _levelInterval) {
      return;
    }
    _lastLevelChanged = d;
    _level.value = Curves.easeInSine.transform(value);
  }

  void _errorListener(SpeechRecognitionError error) {
    _logEvent(
        'Received error status: $error, listening: ${_speech.isListening}');
    state.value = STTState.error;
    _level.value = 0;
  }

  void _statusListener(String status) {
    _logEvent(
        'Received listener status: $status, listening: ${_speech.isListening}');
    if (status == "done") {
      stopListening();
    }
  }

  // This is called each time the users wants to start a new speech
  void startListening() {
    if (state.value.index < STTState.enable.index) {
      return;
    }
    _recognizedWords.value = "";
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
      localeId: locale,
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(seconds: 30),
      onSoundLevelChange: _soundLevelListener,
      onResult: _resultListener,
    );
  }

  void stopListening() {
    _logEvent('stop');
    _speech.stop();
    _level.value = 0.0;
  }

  void setEnable(bool value, {String? pattern}) {
    if (pattern != null) {
      this.pattern = pattern;
    }
    _recognizedWords.value = "";
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

  Color _getIconColor() {
    return switch (state.value) {
      STTState.fail || STTState.error => TColors.error,
      STTState.success => TColors.green,
      STTState.disable => TColors.primary30,
      STTState.done => TColors.primary40,
      _ => TColors.primary60,
    };
  }

  void _logEvent(String eventDescription) {
    debugPrint('STT $eventDescription');
  }
}
