import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_export.dart';

class ListenerBox extends StatelessWidget {
  final Talk pattern;
  final bool challengeMode;
  ListenerBox(this.pattern, {this.challengeMode = false, super.key});
  final _defaultStyle =
      TStyles.medium.copyWith(height: 1, color: TColors.transparent);
  final _correctStyle = TStyles.medium
      .copyWith(color: TColors.green, fontWeight: FontWeight.w900, height: 1);
  @override
  Widget build(BuildContext context) {
    var stt = serviceLocator<STT>();
    var size = 100.d;
    return Row(
      children: [
        Widgets.button(
          context,
          radius: size,
          width: size * 0.5,
          height: size * 0.5,
          color: TColors.primary10,
          alignment: Alignment.center,
          padding: EdgeInsets.all(16.d),
          child: StreamBuilder(
            stream: serviceLocator<Sounds>()
                .getPlayer(pattern.targetValue)
                .onPlayerStateChanged,
            builder: (context, snapshot) => Asset.load<SvgPicture>(
                snapshot.data == PlayerState.playing ? "stop" : "play",
                width: size * 0.3),
          ),
          onPressed: () => serviceLocator<Speaker>()
              .play(pattern.targetValue, narrator: pattern.type.narrator),
        ),
        SizedBox(width: 10.d),
        Expanded(
          child: ValueListenableBuilder(
              valueListenable: stt.recognizedWords,
              builder: (context, value, child) {
                return Column(
                  children: [
                    _answeringBuilder(value),
                    SizedBox(height: 4.d),
                    DirText(pattern.nativeValue,
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

  Widget _answeringBuilder(String value) {
    if (challengeMode) {
      var items = <Widget>[];
      var patterns = pattern.targetValue.toLowerCase().split(" ");
      var values = value.split(" ");
      for (var i = 0; i < patterns.length; i++) {
        var style = _defaultStyle;
        if (i < values.length) {
          if (values[i].toLowerCase() == patterns[i]) {
            style = _correctStyle;
          }
        }
        items.add(Widgets.rect(
          radius: 6.d,
          color: TColors.primary10,
          margin: EdgeInsets.all(4.d),
          padding: EdgeInsets.fromLTRB(6.d, 4.d, 6.d, 1.d),
          child: Text(patterns[i], style: style),
        ));
      }
      return Wrap(children: items);
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: _defaultStyle,
        children: _getWords(value),
      ),
    );
  }

  List<TextSpan> _getWords(String value) {
    var target = pattern.targetValue;
    if (pattern.targetValue == value) {
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
