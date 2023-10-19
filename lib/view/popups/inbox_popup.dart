import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/core/account.dart';
import '../../data/core/message.dart';
import '../../data/core/tribe.dart';
import '../../services/deviceinfo.dart';
import '../../services/inbox.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/popups/ipopup.dart';
import '../../view/widgets.dart';
import '../route_provider.dart';

class InboxPopup extends AbstractPopup {
  InboxPopup({super.key}) : super(Routes.popupInbox, args: {});

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
    await getService<Inbox>().initialize(args: [context, accountBloc.account!]);
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
        padding: EdgeInsets.fromLTRB(32.d, 32.d, 16.d, 16.d),
        decoration:
            Widgets.imageDecore("ui_popup_group", ImageCenterSliceData(144)),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(message.getText(), textDirection: message.text.getDirection()),
          SizedBox(height: 22.d),
          _getConfirmButtons(message)
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
    var padding = EdgeInsets.fromLTRB(32.d, 12.d, 32.d, 32.d);
    if (message.type == Messages.text) {
      return Widgets.skinnedButton(
          padding: padding,
          color: ButtonColor.yellow,
          label: "go_l".l(),
          onPressed: () => launchUrl(Uri.parse(message.metadata)));
    }
    if (!message.type.isConfirm) return SizedBox(height: 22.d);
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Widgets.skinnedButton(
          padding: padding,
          color: ButtonColor.yellow,
          label: "reject_l".l(),
          onPressed: () =>
              message.decideTribeRequest(context, message.intData[0], false)),
      SizedBox(width: 24.d),
      Widgets.skinnedButton(
          padding: padding,
          color: ButtonColor.green,
          label: "accept_l".l(),
          onPressed: () async {
            if (accountBloc.account!.get<Tribe?>(AccountField.tribe) != null) {
              toast("error_195".l());
              return;
            }
            var data = await message.decideTribeRequest(
                context, message.intData[0], true);
            accountBloc.account!.installTribe(data["tribe"]);
            if (mounted) Navigator.pop(context);
          }),
    ]);
  }
}
