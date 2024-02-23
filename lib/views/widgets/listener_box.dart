import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_export.dart';

class ListenerBox extends StatelessWidget {
  final Chat pattern;
  final _defaultStyle = TStyles.medium.copyWith(color: TColors.transparent);
  final _correctStyle = TStyles.medium
      .copyWith(color: TColors.green, fontWeight: FontWeight.w900);
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
                .getPlayer(pattern.value)
                .onPlayerStateChanged,
            builder: (context, snapshot) => Asset.load<SvgPicture>(
                snapshot.data == PlayerState.playing ? "stop" : "play",
                width: size * 0.3),
          ),
          onPressed: () => serviceLocator<Speaker>()
              .play(pattern.value, narrator: pattern.type.narrator),
        ),
        Expanded(
          child: ValueListenableBuilder(
              valueListenable: stt.recognizedWords,
              builder: (context, value, child) {
                return Column(
                  children: [
                    RichText(
                        text: TextSpan(
                      style: TStyles.medium,
                      children: _getWords(value),
                    )),                    SizedBox(height: 4.d),
                    DirText(pattern.nativeLanguage,
                        style:
                            TStyles.small.copyWith(color: TColors.primary40)),
                    SizedBox(height: 6.d),
                    stt.state.value == STTState.fail
                        ? DirText(value,
                            style: TStyles.small.copyWith(color: TColors.error))
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
            if (stt.state.value == STTState.ready) {
              stt.startListening();
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

  List<TextSpan> _getWords(String value) {
    if (pattern.value == value) {
      return [TextSpan(text: pattern.value, style: _correctStyle)];
    }
    var index = pattern.value.toLowerCase().indexOf(value);
    if (index > -1) {
      var spans = <TextSpan>[];
      if (index > 0) {
        spans.add(TextSpan(text: pattern.value.substring(0, index)));
      }
      if (value.isNotEmpty) {
        spans.add(TextSpan(
            text: pattern.value.substring(index, index + value.length),
            style: _correctStyle));
      }
      if (index + value.length < pattern.value.length - 1) {
        spans
            .add(TextSpan(text: pattern.value.substring(index + value.length)));
      }
      return spans;
    } else {
      return [TextSpan(text: pattern.value)];
    }
  }
}
