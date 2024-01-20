import 'package:flutter/material.dart';
import '../../views.dart';
import '../../../skeleton/skeleton.dart';

class MessagePopup extends AbstractPopup {
  //todo: check routes here
  const MessagePopup({super.key})
      : super("popupMessage");

  @override
  createState() => _MessagePopupState();
}

class _MessagePopupState extends AbstractPopupState<MessagePopup> {
  @override
  titleBuilder() => widget.args["title"];

  @override
  contentFactory() {
    var items = <Widget>[
      SizedBox(height: 64.d),
      Text(widget.args["message"], style: TStyles.medium),
      SizedBox(height: 86.d),
    ];
    if (widget.args.containsKey("isConfirm")) {
      items.addAll([
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _button(ButtonColor.gray, "decline_l".l(), null),
          _button(ButtonColor.green, "accept_l".l(), true),
        ])
      ]);
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: items);
  }

  _button(ButtonColor color, String label, dynamic result) {
    return Widgets.skinnedButton(context,
        width: 360.d,
        label: label,
        color: color,
        onPressed: () => Navigator.pop(context, result));
  }
}
