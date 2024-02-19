import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_export.dart';

class ListenerBox extends StatelessWidget {
  final Chat pattern;
  const ListenerBox(this.pattern, {super.key});

  @override
  Widget build(BuildContext context) {
    var correctStyle = TStyles.medium
        .copyWith(color: TColors.green, fontWeight: FontWeight.w900);
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
                  .play(pattern.value, narrator: pattern.narrator),
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
                          children: _getWords(value, correctStyle),
                        )),
                        SizedBox(height: 4.d),
                        Text(pattern.nativeLanguage,
                            style: TStyles.small
                                .copyWith(color: TColors.primary40),
                            textDirection:
                                pattern.nativeLanguage.getDirection()),
                        SizedBox(height: 6.d),
                        stt.state.value == STTState.fail
                            ? Text(value,
                                style: TStyles.small
                                    .copyWith(color: TColors.error),
                                textDirection: value.getDirection())
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
                  Asset.load<SvgPicture>(
                    "mic",
                    width: size * 0.3,
                    svgColorFilter:
                        ColorFilter.mode(_getIconColor(), BlendMode.srcIn),
                  ),
                ],
              ),
              onPressed: stt.startListening,
            ),
          ],
        );
  }
  }

  List<TextSpan> _getWords(String value, TextStyle correctStyle) {
    if (pattern.value == value) {
      return [TextSpan(text: pattern.value, style: correctStyle)];
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
            style: correctStyle));
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
