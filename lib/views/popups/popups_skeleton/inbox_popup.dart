import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app_export.dart';

class InboxPopup extends AbstractPopup {

  //todo: check routes here
  InboxPopup({super.key}) : super(Routes.popupInbox);

  @override
  createState() => _InboxPopupState();
}

class _InboxPopupState extends AbstractPopupState<InboxPopup> {
  List<Message> _messages = [];

  @override
  void initState() {
    _loadMessages();
    super.initState();
  }

  _loadMessages() async {
    await getService<Inbox>()
        .initialize(args: [context, accountProvider.account]);
    setState(() {});
  }

  @override
  contentFactory() {
    _messages = getService<Inbox>().messages;
    var titleStyle = TStyles.small.copyWith(color: TColors.primary30);
    var now = DateTime.now().secondsSinceEpoch;

    return SizedBox(
        height: DeviceInfo.size.height * 0.7,
        child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (c, i) =>
                _itemBuilder(_messages[i], titleStyle, now)));
  }

  Widget _itemBuilder(Message message, TextStyle titleStyle, int now) {
    return Column(children: [
      Widgets.rect(
        padding: EdgeInsets.fromLTRB(24.d, 10.d, 16.d, 16.d),
        decoration: Widgets.imageDecorator("iconed_item_bg",
            ImageCenterSliceData(132, 68, const Rect.fromLTWH(100, 30, 2, 2))),
        child: Row(
          textDirection: TextDirection.ltr,
          children: [
          Asset.load<Image>("inbox_item_${message.type.subject.name}",
              width: 60.d),
          SizedBox(width: 32.d),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                SizedBox(height: 24.d),
                Text(message.getText(),
                    textDirection: message.text.getDirection()),
                SizedBox(height: 16.d),
                _getConfirmButtons(message),
              ])),
        ]),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Text((now - message.createdAt).toElapsedTime(), style: titleStyle),
        SizedBox(width: 24.d),
      ]),
      SizedBox(height: 20.d)
    ]);
  }

  _getConfirmButtons(Message message) {
    var padding = EdgeInsets.fromLTRB(44.d, 20.d, 44.d, 40.d);
    if (message.type == Messages.text) {
      return SkinnedButton(
          padding: padding,
          color: ButtonColor.yellow,
          label: "go_l".l(),
          onPressed: () => launchUrl(Uri.parse(message.metadata)));
    }
    if (!message.type.isConfirm) return SizedBox(height: 22.d);
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      SkinnedButton(
          padding: padding,
          color: ButtonColor.yellow,
          label: "˦",
          onPressed: () =>
              message.decideTribeRequest(context, message.intData[0], false)),
      SizedBox(width: 8.d),
      SkinnedButton(
          padding: padding,
          color: ButtonColor.green,
          label: "˥", onPressed: () async {
        if (accountProvider.account.tribe != null) {
          toast("error_195".l());
          return;
        }
        var data =
            await message.decideTribeRequest(context, message.intData[0], true);
        accountProvider.account.installTribe(data["tribe"]);
        if (mounted) Navigator.pop(context);
      }),
    ]);
  }
}
