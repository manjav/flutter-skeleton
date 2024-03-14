import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lingai/app_export.dart';

class RadioBox extends StatefulWidget {
  final String text;
  final String? translation;
  final Narrator? narrator;
  final BalloonTipPosition? ballonPosition;

  const RadioBox(
    this.text, {
    this.translation,
    this.ballonPosition = BalloonTipPosition.bottomRight,
    this.narrator = Narrator.onyx,
    super.key,
  });

  @override
  State<RadioBox> createState() => _RadioBoxState();
}

class _RadioBoxState extends State<RadioBox> {
  @override
  Widget build(BuildContext context) {
    var margin = 14.d;
    var alignment = MainAxisAlignment.center;
    if (widget.ballonPosition != BalloonTipPosition.none) {
      alignment = widget.ballonPosition == BalloonTipPosition.leftTop
          ? MainAxisAlignment.start
          : MainAxisAlignment.end;
    }
    return Row(
      mainAxisAlignment: alignment,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Widgets.rect(
                constraints:
                    BoxConstraints(maxWidth: DeviceInfo.size.width * 0.84),
                margin:
                    EdgeInsets.fromLTRB(margin, margin * 2 - 2.d, margin, 0),
                padding: EdgeInsets.fromLTRB(
                    margin * 2, margin * 2, margin * 2, margin),
                decoration:
                    BalloonDecoration(tipPosition: widget.ballonPosition),
                child: Column(
                  children: [
                    DirText(widget.text, style: TStyles.medium),
                    SizedBox(height: widget.translation == null ? 0 : 4.d),
                    widget.translation == null
                        ? const SizedBox()
                        : DirText(widget.translation!,
                            style: TStyles.small
                                .copyWith(color: TColors.primary40)),
                  ],
                )),
            Positioned(
              top: margin - 2.d,
              right: translation != null ? null : 30.d,
              child: SpeakerBox(
                narrator: narrator!,
                value: text,
                width: margin * 2,
              ),
            ),
            translation != null
                ? const SizedBox()
                : Positioned(
                    top: 0,
                    right: 76.d,
                    child: _button(
                        Asset.load<SvgPicture>("?"), margin * 2, _translate))
          ],
        ),
      ],
    );
  }

  Widget _button(Widget child, double size, Function() onPressed) {
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

  _translate() {}
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
      radius: size,
      color: TColors.primary20,
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      child: StreamBuilder(
        stream: serviceLocator<Sounds>().getPlayer(value).onPlayerStateChanged,
        builder: (context, snapshot) => Asset.load<SvgPicture>(
            snapshot.data == PlayerState.playing ? "stop" : "play",
            width: size * 0.35),
      ),
      onPressed: () =>
          serviceLocator<Speaker>().play(value, narrator: narrator),
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
        "https://s1.matnyaar.ir/gpt/dalle.php?input=$name",
        width: width,
        height: height,
      ),
    );
  }
}
