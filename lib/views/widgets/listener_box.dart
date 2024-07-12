import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:rive/rive.dart';

import '../../app_export.dart';

enum Difficulty { simple, hint, hidden }

// ignore: must_be_immutable
class ListenerBox extends StatelessWidget {
  final String hint;
  final String answer;
  final String voiceHint;
  final Narrator narrator;
  final Difficulty difficulty;
  final List<ValueNotifier<Choice>> _patterns = [];
  final ValueNotifier<QuizState> _state = ValueNotifier(QuizState.none);
  final ValueNotifier<String> _recognizedWords = ValueNotifier("__waiting__");
  final ValueNotifier<bool> _debugMode = ValueNotifier(false);

  SMIInput<double>? _stateInput;
  SMIInput<double>? _soundLevelInput;

  ListenerBox({
    super.key,
    required this.hint,
    required this.answer,
    required this.narrator,
    required this.voiceHint,
    this.difficulty = Difficulty.simple,
  });
  final _correctStyle = TStyles.huge.copyWith(color: TColors.green, height: 1);

  @override
  Widget build(BuildContext context) {
    var listener = serviceLocator<ListenerQuiz>();
    if (_recognizedWords.value == "__waiting__") {
      var pattern = answer.patternize();
      listener.state.addListener(() {
        _recognizedWords.value = "";
        if (listener.pattern == pattern) {
          _stateInput?.value = listener.state.value.index.toDouble();
        }
      });
      listener.audioLevel.addListener(() {
        if (listener.pattern == pattern) {
          _soundLevelInput?.value = listener.audioLevel.value * 100;
        }
      });
      listener.recognizedWords.addListener(() {
        if (listener.pattern == pattern) {
          _recognizedWords.value = listener.recognizedWords.value;
        }
      });
    }
    var defaultStyle = TStyles.big.copyWith(
        fontSize: 36.d,
        height: 1,
        color: difficulty == Difficulty.simple
            ? TColors.primary80
            : TColors.transparent);
    var words = answer.split(" ");
    _patterns.addAll(
        List.generate(words.length, (i) => ValueNotifier(Choice(words[i]))));
    return Column(
      children: [
        _answeringBuilder(context, defaultStyle, listener.minMatchLevel),
        SizedBox(height: 10.d),
        DirText(hint, style: TStyles.small.copyWith(color: TColors.primary40)),
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
            SpeakerBox(
              narrator: narrator,
              value: voiceHint,
              width: 40.d,
            ),
            SizedBox(width: 50.d),
            _micButtonBuilder(context, listener),
            SizedBox(width: 90.d),
          ],
        ),
      ],
    );
  }

  Widget _micButtonBuilder(BuildContext context, ListenerQuiz listner) {
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
        // if (stt.state.value == QuizState.ready) {
        listner.start(pattern: answer.patternize());
        // }
      },
      onLongPress: () => listner.onResult?.call(QuizState.success, listner.pattern!),
    );
  }

  Widget _answeringBuilder(
      BuildContext context, TextStyle defaultStyle, int minMatchLevel) {
    return ValueListenableBuilder(
        valueListenable: _recognizedWords,
        builder: (context, value, child) {
          // if (difficulty != Difficulty.simple) {
          var items = <Widget>[];
          // var patterns = talk.targetValue.toLowerCase().split(" ");
          bool isCorrect = false;
          var values = value.split(" ");
          for (var i = 0; i < _patterns.length; i++) {
            var style = defaultStyle;
            if (i < values.length) {
              var rate = ratio(
                  values[i].patternize(), _patterns[i].value.text.patternize());
              isCorrect = rate > minMatchLevel;
              if (isCorrect) {
                style = _correctStyle;
              }
            }
            var isHidden = _patterns[i].value.text.contains("{") ||
                _patterns[i].value.text.contains("}");
            items.add(
              ValueListenableBuilder(
                valueListenable: _patterns[i],
                builder: (context, value, child) {
                  return Widgets.button(
                    context,
                    radius: 6.d,
                    color: isHidden ? TColors.primary0 : TColors.transparent,
                    margin: EdgeInsets.all(2.d),
                    padding: EdgeInsets.fromLTRB(4.d, 4.d, 4.d, 1.d),
                    child: Text(
                        _patterns[i]
                            .value
                            .text
                            .replaceAll(RegExp(r'[ًٍَُِّ{}]'), ''),
                        style:
                            isHidden && !_patterns[i].value.used && !isCorrect
                                ? style.copyWith(color: TColors.transparent)
                                : style),
                    onPressed: () =>
                        _patterns[i].value = Choice(value.text)..used = true,
                  );
                },
              ),
            );
          }
          return Wrap(children: items);
        });

    // }

    // return RichText(
    //   textDirection: talk.targetValue.getDirection(),
    //   textAlign: TextAlign.center,
    //   text: TextSpan(
    //     style: defaultStyle,
    //     children: _getWords(value),
    //   ),
    // );
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

  /* List<TextSpan> _getWords(String value) {
    var target = talk.targetValue;
    if (talk.targetValue == value) {
      return [TextSpan(text: target, style: _correctStyle)];
    }
    var index = target.toLowerCase().indexOf(value);
    if (index > -1) {
      var spans = <TextSpan>[];
      if (index > 0) {
        spans.add(TextSpan(text: target.substring(0, index)));
      }
      if (value.isNotEmpty) {
        spans.add(TextSpan(
            text: target.substring(index, index + value.length),
            style: _correctStyle..copyWith(backgroundColor: TColors.black)));
      }
      if (index + value.length < target.length - 1) {
        spans.add(TextSpan(text: target.substring(index + value.length)));
      }
      return spans;
    } else {
      return [TextSpan(text: target)];
    }
  } */
}
