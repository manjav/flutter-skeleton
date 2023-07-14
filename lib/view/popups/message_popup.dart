import 'package:flutter/material.dart';

import '../../services/deviceinfo.dart';
import '../../services/theme.dart';
import '../../view/popups/ipopup.dart';
import '../route_provider.dart';

class MessagePopup extends AbstractPopup {
  const MessagePopup({super.key, required super.args})
      : super(Routes.popupCard);

  @override
  createState() => _MessagePopupState();
}

class _MessagePopupState extends AbstractPopupState<MessagePopup> {
  @override
  titleBuilder() => widget.args['title'];

  @override
  contentFactory() {
    return SizedBox(
        height: 220.d,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.args['message'], style: TStyles.medium),
            // SizedBox(height: 48.d),
            // Widgets.labeledButton(
            //     label: "card_sell".l(), color: "green", width: 370.d),
          ],
        ));
  }
}
