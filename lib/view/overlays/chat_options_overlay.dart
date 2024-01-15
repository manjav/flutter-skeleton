import 'package:flutter/material.dart';

import '../../app_export.dart';

enum ChatOptions { pin, reply }

class ChatOptionsOverlay extends AbstractOverlay {
  final double? y;
  final Function(ChatOptions)? onSelect;
  final List<ChatOptions> options;
  const ChatOptionsOverlay(
      {required this.options, this.y, this.onSelect, super.key})
      : super(type: OverlayType.chatOptions);

  @override
  createState() => _ChatOptionsOverlayState();
}

class _ChatOptionsOverlayState
    extends AbstractOverlayState<ChatOptionsOverlay> {
  @override
  Widget build(BuildContext context) {
    return Material(
        color: TColors.transparent,
        child: Widgets.button(context,
            child: Stack(children: [
              Positioned(
                  left: 540.d,
                  width: 320.d,
                  top: widget.y,
                  child: Widgets.rect(
                    padding: EdgeInsets.fromLTRB(16.d, 16.d, 16.d, 16.d),
                    decoration: Widgets.imageDecorator(
                        "tribe_item_bg", ImageCenterSliceData(56)),
                    child: Column(children: [
                      for (var option in widget.options) _button(option)
                    ]),
                  ))
            ]),
            onPressed: close));
  }

  Widget _button(ChatOptions option) {
    return Widgets.skinnedButton(context,
        height: 110.d,
        padding: EdgeInsets.only(bottom: 20.d, left: 32.d),
        color:
            option == ChatOptions.reply ? ButtonColor.yellow : ButtonColor.teal,
        child: Row(children: [
          Asset.load<Image>("icon_${option.name}", height: 52.d),
          SizedBox(width: 18.d),
          SkinnedText("chat_${option.name}".l(), style: TStyles.large),
        ]), onPressed: () {
      close();
      widget.onSelect?.call(option);
    });
  }
}
