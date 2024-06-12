import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

import '../../app_export.dart';

enum Difficulty { simple, hint, hidden }

class ListenerBox extends StatelessWidget {
  final Talk talk;
  final Difficulty difficulty;
  final ValueNotifier<bool> _debugMode = ValueNotifier(false);
  final List<ValueNotifier<Choice>> _patterns = [];

  ListenerBox(this.talk, {this.difficulty = Difficulty.simple, super.key});
  final _correctStyle = TStyles.medium
      .copyWith(color: TColors.green, fontWeight: FontWeight.w900, height: 1);

  @override
  Widget build(BuildContext context) {
    var size = 100.d;
    var stt = serviceLocator<STT>();
    var defaultStyle = TStyles.medium.copyWith(
        height: 1,
        color: difficulty == Difficulty.simple
            ? TColors.primary80
            : TColors.transparent);
    var words = talk.targetValue.toLowerCase().split(" ");
    _patterns.addAll(
        List.generate(words.length, (i) => ValueNotifier(Choice(words[i]))));
    return Row(
      children: [
        SpeakerBox(
          narrator: talk.type.narrator,
          value: talk.targetValue,
          width: 50.d,
        ),
        SizedBox(width: 10.d),
        Expanded(
          child: ValueListenableBuilder(
              valueListenable: stt.recognizedWords,
              builder: (context, value, child) {
                return Column(
                  children: [
                    _answeringBuilder(
                        context, defaultStyle, value, stt.minMatchLevel),
                    SizedBox(height: 4.d),
                    DirText(talk.nativeValue,
                        style:
                            TStyles.small.copyWith(color: TColors.primary40)),
                    SizedBox(height: 6.d),
                    stt.state.value == QuizState.fail
                        ? DirText(
                            value,
                            style: TStyles.small
                                .copyWith(color: TColors.error, height: 1),
                            textAlign: TextAlign.center,
                          )
                        : const SizedBox(),
                    ValueListenableBuilder(
                        valueListenable: _debugMode,
                        builder: (context, value, child) => value
                            ? Text(stt.logs,
                                style:
                                    TStyles.tiny.copyWith(color: TColors.error))
                            : const SizedBox())
                  ],
                );
              }),
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
                valueListenable: stt.audioLevel,
                builder: (context, value, child) => AnimatedContainer(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(size)),
                    color: TColors.primary20,
                  ),
                  width: size * stt.audioLevel.value,
                  height: size * stt.audioLevel.value,
                  duration: const Duration(milliseconds: STT.levelInterval),
                ),
              ),
              _getIcon(size)
            ],
          ),
          onPressed: () {
            if (stt.state.value == QuizState.ready) {
              stt.start();
            }
          },
          onLongPress: () =>
              stt.onResult?.call(QuizState.success, stt.pattern!),
          // onLongPress: () => _debugMode.value = !_debugMode.value,
        ),
      ],
    );
  }

  Widget _getIcon(double size) {
    var stt = serviceLocator<STT>();
    return ValueListenableBuilder(
        valueListenable: stt.state,
        builder: (context, value, child) {
          return Asset.load<SvgPicture>("mic_${value.name}", width: size * 0.3);
        });
  }

  Widget _answeringBuilder(BuildContext context, TextStyle defaultStyle,
      String value, int minMatchLevel) {
    // if (difficulty != Difficulty.simple) {
    var items = <Widget>[];
    // var patterns = talk.targetValue.toLowerCase().split(" ");
    bool isCorrect = false;
    var values = value.split(" ");
    for (var i = 0; i < _patterns.length; i++) {
      var style = defaultStyle;
      if (i < values.length) {
        var rate =
            ratio(values[i].patternize(), _patterns[i].value.text.patternize());
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
                  _patterns[i].value.text.replaceAll(RegExp(r'[ًٍَُِّ{}]'), ''),
                  style: isHidden && !_patterns[i].value.used && !isCorrect
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

  List<TextSpan> _getWords(String value) {
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
  }
}
