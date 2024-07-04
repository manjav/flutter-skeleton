import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

import '../../app_export.dart';

enum Difficulty { simple, hint, hidden }

class ListenerBox extends StatelessWidget {
  final String hint;
  final String answer;
  final String voiceHint;
  final Narrator narrator;
  final Difficulty difficulty;
  final List<ValueNotifier<Choice>> _patterns = [];
  final ValueNotifier<double> _audioLevel = ValueNotifier(0);
  final ValueNotifier<QuizState> _state = ValueNotifier(QuizState.none);
  final ValueNotifier<String> _recognizedWords = ValueNotifier("__waiting__");
  final ValueNotifier<bool> _debugMode = ValueNotifier(false);

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
    var stt = serviceLocator<STT>();
    if (_recognizedWords.value == "__waiting__") {
      _recognizedWords.value = "";
      var pattern = answer.patternize();
      stt.state.addListener(() {
        if (stt.pattern == pattern) {
          _state.value = stt.state.value;
        }
      });
      stt.audioLevel.addListener(() {
        if (stt.pattern == pattern) {
          _audioLevel.value = stt.audioLevel.value;
        }
      });
      stt.recognizedWords.addListener(() {
        if (stt.pattern == pattern) {
          _recognizedWords.value = stt.recognizedWords.value;
        }
      });
    }
    var size = 120.d;
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
        SizedBox(height: 10.d),
        DirText(hint, style: TStyles.small.copyWith(color: TColors.primary40)),
        SizedBox(height: 10.d),
        _answeringBuilder(context, defaultStyle, stt.minMatchLevel),
        SizedBox(height: 20.d),
        ValueListenableBuilder(
            valueListenable: _debugMode,
            builder: (context, value, child) => value
                ? Text(stt.logs,
                    style: TStyles.tiny.copyWith(color: TColors.error))
                : const SizedBox()),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SpeakerBox(
              narrator: narrator,
              value: voiceHint,
              width: 50.d,
            ),
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
                    valueListenable: _audioLevel,
                    builder: (context, value, child) => AnimatedContainer(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(size)),
                        color: TColors.primary20,
                      ),
                      width: size * _audioLevel.value,
                      height: size * _audioLevel.value,
                      duration: const Duration(milliseconds: STT.levelInterval),
                    ),
                  ),
                  _getIcon(size)
                ],
              ),
              onPressed: () {
                // if (stt.state.value == QuizState.ready) {
                stt.start(pattern: answer.patternize());
                // }
              },
              onLongPress: () =>
                  stt.onResult?.call(QuizState.success, stt.pattern!),
            )
          ],
        ),
        SizedBox(height: 20.d),
        _wrongResultBuilder(),
      ],
    );
  }

  Widget _getIcon(double size) => ValueListenableBuilder(
      valueListenable: _state,
      builder: (context, value, child) =>
          Asset.load<SvgPicture>("mic_${value.name}", width: size * 0.3));

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
                    color: isHidden ? TColors.primary10 : TColors.transparent,
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

  Widget _wrongResultBuilder() {
    return ValueListenableBuilder(
        valueListenable: _state,
        builder: (context, value, child) {
          return value == QuizState.fail
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
