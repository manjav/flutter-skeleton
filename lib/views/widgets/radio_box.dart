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
  final ValueNotifier<PlayerState> _playerState =
      ValueNotifier(PlayerState.stopped);

  @override
  void initState() {
    serviceLocator<Sounds>()
        .getPlayer(widget.text)
        .onPlayerStateChanged
        .listen((PlayerState s) => _playerState.value = s);
    super.initState();
  }

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
                margin: EdgeInsets.fromLTRB(margin, 26.d, margin, margin),
                padding:
                    EdgeInsets.fromLTRB(margin * 2, 26.d, margin * 2, margin),
                decoration:
                    BalloonDecoration(tipPosition: widget.ballonPosition),
                child: Column(
                  children: [
                    Text(widget.text,
                        style: TStyles.medium,
                        textDirection: widget.text.getDirection()),
                    SizedBox(height: widget.translation == null ? 0 : 4.d),
                    widget.translation == null
                        ? const SizedBox()
                        : Text(widget.translation!,
                            style: TStyles.small
                                .copyWith(color: TColors.primary40),
                            textDirection: widget.translation!.getDirection()),
                  ],
                )),
            Positioned(
                top: 0,
                right: widget.translation != null ? null : 30.d,
                child: _button(
                  ValueListenableBuilder(
                      valueListenable: _playerState,
                      builder: (context, value, child) =>
                          Asset.load<SvgPicture>(
                              value == PlayerState.playing ? "stop" : "play")),
                  margin * 2,
                  () => serviceLocator<Speaker>()
                      .play(widget.text, narrator: widget.narrator!),
                )),
            widget.translation != null
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
