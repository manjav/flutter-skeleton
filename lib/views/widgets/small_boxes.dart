import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lifetalk/app_export.dart';

class RadioBox extends StatelessWidget {
  final String text;
  final String? translation;
  final Narrator? narrator;
  final BalloonTipPosition? ballonPosition;
  final Color? color;
  final Color? strokeColor;
  final TextStyle? textStyle;

  const RadioBox(
    this.text, {
    this.translation,
    this.ballonPosition = BalloonTipPosition.bottomRight,
    this.narrator = Narrator.onyx,
    this.color,
    this.strokeColor,
    this.textStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var margin = 6.d;
    var alignment = MainAxisAlignment.center;
    if (ballonPosition != BalloonTipPosition.none) {
      alignment = ballonPosition == BalloonTipPosition.leftBottom
          ? MainAxisAlignment.start
          : MainAxisAlignment.end;
    }

    return Row(
      mainAxisAlignment: alignment,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Widgets.rect(
                constraints: BoxConstraints(
                    maxWidth: DeviceInfo.size.width *
                        (ballonPosition == BalloonTipPosition.none
                            ? 0.75
                            : 0.85)),
                margin: EdgeInsets.fromLTRB(margin * 5, margin, margin, margin),
                padding: EdgeInsets.fromLTRB(
                    margin * 3, margin * 5, margin * 3, margin),
                decoration: BalloonDecoration(
                    tipPosition: ballonPosition,
                    mainColor: color,
                    strokeColor: strokeColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DirText(
                      text.simplify(),
                      style: textStyle ?? TStyles.big,
                    ),
                    SizedBox(height: translation == null ? 0 : 6.d),
                    Widgets.divider(),
                    SizedBox(height: translation == null ? 0 : 12.d),
                    translation == null
                        ? const SizedBox()
                        : DirText(translation!.simplify(),
                            style: TStyles.medium
                                .copyWith(color: TColors.primary40)),
                  ],
                )),
            Positioned(
              top: -margin * 4,
              child: SpeakerBox(
                narrator: narrator!,
                value: text,
                width: margin * 9,
              ),
            ),
            /* translation != null
                ? const SizedBox()
                : Positioned(
                    top: 0,
                    right: 76.d,
                    child: _button(context, Asset.load<SvgPicture>("?"),
                        margin * 2, _translate)) */
          ],
        ),
      ],
    );
  }

  /* Widget _button(
      BuildContext context, Widget child, double size, Function() onPressed) {
    return Widgets.button(context,
        color: TColors.transparent,
        padding: EdgeInsets.all(12.d),
        child: Widgets.rect(
          width: size,
          height: size,
          padding: EdgeInsets.all(6.d),
          decoration: BoxDecoration(
            color: TColors.primary0,
            border: Border.all(color: TColors.primary30, width: 2.d),
            borderRadius: BorderRadius.all(Radius.circular(12.d)),
          ),
          child: child,
        ),
        onPressed: onPressed);
  }

  _translate() {} */
}

class SpeakerBox extends StatelessWidget {
  final String value;
  final double? width;
  final Narrator narrator;
  const SpeakerBox({
    required this.narrator,
    required this.value,
    this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var size = width ?? 40.d;
    return Widgets.button(
      context,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: TColors.primary0,
        boxShadow: [
          BoxShadow(
              blurRadius: 1.d, offset: Offset(0, 1.d), color: TColors.primary10)
        ],
        borderRadius: BorderRadius.all(Radius.circular(size)),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      child: StreamBuilder(
        stream: serviceLocator<MediaService>()
            .getAudioPlayer(value)
            .onPlayerStateChanged,
        builder: (context, snapshot) => Asset.load<SvgPicture>(
            snapshot.data == PlayerState.playing ? "stop" : "play",
            width: size * 0.35),
      ),
      onPressed: () => serviceLocator<Speaker>().playLocal(value),
      onLongPress: () => serviceLocator<Speaker>()
          .play(value, narrator: narrator, reset: true),
    );
  }
}

class ImageBox extends StatelessWidget {
  final String name;
  final double? width, height, borderRadius;
  const ImageBox({
    required this.name,
    this.width,
    this.height,
    this.borderRadius = 8,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius!),
      child: Image.network(
        "https://s1.matnyaar.ir/gpt/dalle.php?input=$name&resize=${(width ?? 100.d).round()}",
        width: width,
        height: height,
      ),
    );
  }
}

class HiddenWords extends StatelessWidget with ILogger {
  final List<Choice> answerWords;
  final ValueNotifier<String> liveAnswer;
  HiddenWords(
    this.answerWords,
    this.liveAnswer, {
    super.key,
  });

  final _correctStyle = TStyles.huge.copyWith(height: 1, color: TColors.green);
  final _defaultStyle =
      TStyles.huge.copyWith(height: 1, color: TColors.primary30);
  final _hiddenStyle =
      TStyles.huge.copyWith(height: 1, color: TColors.transparent);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: liveAnswer,
      builder: (context, value, child) {
        var items = <Widget>[];
        var words = value.split(" ");
        for (var i = 0; i < answerWords.length; i++) {
          final answer = answerWords[i];
          final blankMode = Choice.blankMode(answer.text);

          var isCorrect = false;
          var style = _defaultStyle;
          if (i < words.length && answer.text.isEmpty) {
            final word = words[i];
            isCorrect = word == answer.text;
            // log("word:$word pattern: ${answer.pattern} Correct:$isCorrect");
            if (isCorrect) {
              style = _correctStyle;
            }
          }
          items.add(
            ValueListenableBuilder(
              valueListenable: answerWords[i].stateNotifier,
              builder: (context, value, child) {
                return Widgets.button(
                  context,
                  radius: 6.d,
                  color: blankMode ? TColors.primary10 : TColors.transparent,
                  margin: EdgeInsets.all(2.d),
                  padding: EdgeInsets.fromLTRB(4.d, 4.d, 4.d, 1.d),
                  child: Text(
                      answerWords[i].text.replaceAll(RegExp(r'[{}]'), ''),
                      style: blankMode &&
                              value != ChoiceState.selected &&
                              !isCorrect
                          ? _hiddenStyle
                          : style),
                  onPressed: () =>
                      answerWords[i].setState(ChoiceState.selected),
                );
              },
            ),
          );
        }
        return Wrap(children: items);
      },
    );
  }
}
