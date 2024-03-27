import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

import '../../app_export.dart';

class ListenerBox extends StatelessWidget {
  final Talk talk;
  final bool challengeMode;
  ListenerBox(this.talk, {this.challengeMode = false, super.key});
  final _correctStyle = TStyles.medium
      .copyWith(color: TColors.green, fontWeight: FontWeight.w900, height: 1);

  @override
  Widget build(BuildContext context) {
    var size = 100.d;
    var stt = serviceLocator<STT>();
    var defaultStyle = TStyles.medium.copyWith(
        height: 1,
        color: challengeMode ? TColors.transparent : TColors.primary80);
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
                    _answeringBuilder(defaultStyle, value, stt.minMatchLevel),
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

  Widget _answeringBuilder(TextStyle defaultStyle, String value, int minMatchLevel) {
    if (challengeMode) {
      var items = <Widget>[];
      var patterns = talk.targetValue.toLowerCase().split(" ");
      var values = value.split(" ");
      for (var i = 0; i < patterns.length; i++) {
        var style = defaultStyle;
        if (i < values.length) {
          var rate = ratio(values[i].simple(), patterns[i].simple());
          if (rate > minMatchLevel) {
            style = _correctStyle;
          }
        }
        items.add(
          Widgets.rect(
            radius: 6.d,
            color: TColors.primary10,
            margin: EdgeInsets.all(4.d),
            padding: EdgeInsets.fromLTRB(6.d, 4.d, 6.d, 1.d),
            child: Text(patterns[i], style: style),
          ),
        );
      }
      return Wrap(children: items);
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: defaultStyle,
        children: _getWords(value),
      ),
    );
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
            style: _correctStyle));
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
