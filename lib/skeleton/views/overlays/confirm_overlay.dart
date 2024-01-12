import 'package:flutter/material.dart';

import '../../services/device_info.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../widgets.dart';
import 'overlay.dart';

class ConfirmOverlay extends AbstractOverlay {
  final String message, acceptLabel, declineLabel;
  final Function()? onAccept;
  final bool barrierDismissible;

  const ConfirmOverlay(
      this.message, this.acceptLabel, this.declineLabel, this.onAccept,
      {this.barrierDismissible = true, super.key})
      : super(type: OverlayType.confirm);

  @override
  createState() => _ConfirmOverlayState();
}

class _ConfirmOverlayState extends AbstractOverlayState<ConfirmOverlay> {
  @override
  Widget build(BuildContext context) {
    return Material(
        color: TColors.transparent,
        child: Widgets.button(context,
            padding: EdgeInsets.zero,
            child: Stack(children: [
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Widgets.rect(
                      padding: EdgeInsets.fromLTRB(40.d, 16.d, 12.d, 16.d),
                      decoration: Widgets.imageDecorator(
                          "tribe_item_bg", ImageCenterSliceData(56)),
                      child: _contentFactory()))
            ]), onPressed: () {
          if (widget.barrierDismissible) {
            close();
          }
        }));
  }

  Widget _contentFactory() {
    return Row(children: [
      Expanded(child: Text(widget.message)),
      SizedBox(width: 24.d),
      Column(children: [
        _button(widget.declineLabel, color: ButtonColor.yellow),
        SizedBox(height: 12.d),
        _button(widget.acceptLabel, onPressed: widget.onAccept),
      ]),
    ]);
  }

  Widget _button(String label,
      {ButtonColor color = ButtonColor.green, Function()? onPressed}) {
    return Widgets.skinnedButton(context,
        color: color,
        padding: EdgeInsets.fromLTRB(36.d, 12.d, 36.d, 32.d),
        label: label, onPressed: () {
      onPressed?.call();
      close();
    });
  }
}
