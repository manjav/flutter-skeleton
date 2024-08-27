import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:rive/rive.dart';

import '../../app_export.dart';

enum Difficulty { simple, hint, hidden }

// ignore: must_be_immutable
class ListenerBox extends StatefulWidget {
  final String hint;
  final String voice;
  final String answer;
  final String repeatVoice;
  final Narrator narrator;
  final Difficulty difficulty;

  const ListenerBox({
    super.key,
    required this.hint,
    required this.voice,
    required this.answer,
    required this.narrator,
    required this.repeatVoice,
    this.difficulty = Difficulty.simple,
  });

  @override
  State<ListenerBox> createState() => _ListenerBoxState();
}

class _ListenerBoxState extends State<ListenerBox> {
  final List<ValueNotifier<Choice>> _patterns = [];
  final ValueNotifier<QuizState> _state = ValueNotifier(QuizState.none);
  final ValueNotifier<String> _recognizedWords = ValueNotifier("");
  final _correctStyle = TStyles.huge.copyWith(color: TColors.green, height: 1);
  final _defaultStyle = TStyles.huge.copyWith(height: 1);
  final _hiddenStyle =
      TStyles.huge.copyWith(height: 1, color: TColors.transparent);
  SMIInput<double>? _stateInput;
  SMIInput<double>? _soundLevelInput;

  String _pattern = "";

  @override
  void initState() {
    _pattern = widget.answer.patternize();
    final listener = serviceLocator<ListenerQuiz>();
    listener.state.addListener(_stateListener);
    listener.audioLevel.addListener(_soundLevelListener);
    listener.recognizedWords.addListener(_resultListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final listener = serviceLocator<ListenerQuiz>();
    final words = widget.answer.replace().split(" ");
    _patterns.clear();
    _patterns.addAll(
        List.generate(words.length, (i) => ValueNotifier(Choice(words[i]))));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _answeringBuilder(context, listener.minMatchLevel),
        SizedBox(height: 10.d),
        DirText(widget.hint,
            style: TStyles.small.copyWith(color: TColors.primary40)),
        SizedBox(height: 50.d),
        _wrongResultBuilder(listener),
        SizedBox(height: 20.d),
        ValueListenableBuilder(
            valueListenable: _debugMode,
            builder: (context, value, child) => value
                ? Text(listener.logs,
                    style: TStyles.tiny.copyWith(color: TColors.error))
                : const SizedBox()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ValueListenableBuilder(
              valueListenable: _state,
              builder: (context, value, child) => SkinnedButton(
                color: TColors.white,
                width: 62.d,
                height: 62.d,
                cornerRadius: 22.d,
                isEnable: value != QuizState.waiting,
                child: Asset.load<SvgPicture>("reset"),
                onPressed: () => listener.listen(
                  pattern: widget.answer,
                  hintVoice: widget.voice,
                  repeatVoice: widget.repeatVoice,
                  onResult: listener.onResult,
                ),
              ),
            ),
            SizedBox(width: 50.d),
            _micButtonBuilder(context, listener),
            SizedBox(width: 90.d),
          ],
        ),
      ],
    );
  }

  Widget _micButtonBuilder(BuildContext context, ListenerQuiz listener) {
    var size = 120.d;
    return Widgets.touchable(
      context,
      child: LoaderWidget(
        AssetType.animation,
        "mic_button",
        width: size,
        height: size,
        onRiveInit: (artboard) {
          final controller =
              StateMachineController.fromArtboard(artboard, "State Machine 1");
          _stateInput = controller?.findInput<double>("state");
          _soundLevelInput = controller?.findInput<double>("soundLevel");
          artboard.addController(controller!);
        },
      ),
      onTap: () {
        if (listener.state.value != QuizState.ready) {
          return;
        }
        listener.listen(
          pattern: widget.answer,
          hintVoice: widget.voice,
          repeatVoice: widget.repeatVoice,
          onResult: listener.onResult,
        );
      },
      onLongPress: () =>
          listener.onResult?.call(QuizState.success, listener.pattern, 101),
    );
  }

  Widget _answeringBuilder(BuildContext context, int minMatchLevel) {
    return ValueListenableBuilder(
      valueListenable: _recognizedWords,
      builder: (context, value, child) {
        var items = <Widget>[];
        var words = value.split(" ");
        for (var i = 0; i < _patterns.length; i++) {
          var isCorrect = false;
          var isHidden = _patterns[i].value.text.contains("{") ||
              _patterns[i].value.text.contains("}");
          var style = _defaultStyle;
          if (i < words.length) {
            var rate = ratio(words[i], _patterns[i].value.text.patternize());
            isCorrect = rate > minMatchLevel;
            if (isCorrect) {
              style = _correctStyle;
            }
          }
          items.add(
            ValueListenableBuilder(
              valueListenable: _patterns[i],
              builder: (context, value, child) {
                // print("Hide:$isHidden Correct:$isCorrect =>${_state.value}");
                return Widgets.button(
                  context,
                  radius: 6.d,
                  color: isHidden ? TColors.primary10 : TColors.transparent,
                  margin: EdgeInsets.all(2.d),
                  padding: EdgeInsets.fromLTRB(4.d, 4.d, 4.d, 1.d),
                  child: Text(
                      _patterns[i]
                          .value
                          .text
                          .replaceAll(RegExp(r'[ًٍَُِّ{}]'), ''),
                      style: isHidden && !_patterns[i].value.used && !isCorrect
                          ? _hiddenStyle
                          : style),
                  onPressed: () =>
                      _patterns[i].value = Choice(value.text)..used = true,
                );
              },
            ),
          );
        }
        return Wrap(children: items);
      },
    );
  }

  Widget _wrongResultBuilder(ListenerQuiz stt) {
    return ValueListenableBuilder(
        valueListenable: _state,
        builder: (context, value, child) {
          return value == QuizState.failure
              ? DirText(
                  _recognizedWords.value,
                  style:
                      TStyles.small.copyWith(color: TColors.error, height: 1),
                  textAlign: TextAlign.center,
                )
              : SizedBox(height: 12.d);
        });
  }

  @override
  void dispose() {
    final listener = serviceLocator<ListenerQuiz>();
    listener.state.removeListener(_stateListener);
    listener.audioLevel.removeListener(_soundLevelListener);
    listener.recognizedWords.removeListener(_resultListener);
    super.dispose();
  }

  void _stateListener() {
    final listener = serviceLocator<ListenerQuiz>();
    if (listener.pattern != _pattern) return;
    _state.value = listener.state.value;
    _stateInput?.value = listener.state.value.index.toDouble();
    if (_state.value == QuizState.ready) {
      for (var pattern in _patterns) {
        pattern.value = Choice(pattern.value.text)..used = false;
      }
    } else if (_state.value.index >= QuizState.success.index) {
      for (var pattern in _patterns) {
        pattern.value = Choice(pattern.value.text)..used = true;
      }
    }
  }

  void _soundLevelListener() {
    final listener = serviceLocator<ListenerQuiz>();
    if (listener.pattern != _pattern) return;
    _soundLevelInput?.value = listener.audioLevel.value * 100;
  }

  void _resultListener() {
    final listener = serviceLocator<ListenerQuiz>();
    if (listener.pattern != _pattern) return;
    _recognizedWords.value = listener.recognizedWords.value;
  }
}
