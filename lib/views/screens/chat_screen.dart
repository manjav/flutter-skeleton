import 'package:flutter/material.dart';
import 'package:lingai/data/message.dart';
import 'package:lingai/views/avatar.dart';

import '../../app_export.dart';

class ChatScreen extends AbstractScreen {
  ChatScreen({super.key}) : super(Routes.chat, args: {});

  @override
  createState() => _ChatScreenState();
}

class _ChatScreenState extends AbstractScreenState<ChatScreen> {
  final Messages _messages = Messages([]);
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();

  @override
  Widget contentFactory() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(height: 10.d),
      _chatList(),
      SizedBox(height: 5.d),
      _inputView(),
      SizedBox(height: 10.d),
    ]);
  }

  Widget _chatList() {
    var titleStyle = TStyles.small.copyWith(color: TColors.primary30);
    var now = DateTime.now().secondsSinceEpoch;
    return ValueListenableBuilder<List<Message>>(
        valueListenable: _messages,
        builder: (context, value, child) {
          _scrollDown(delay: 10);
          // account.tribe!.chat.value
          //     .sort((a, b) => a.creationDate - b.creationDate);
          return Expanded(
              child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: EdgeInsets.all(48.d),
                  itemCount: value.length,
                  itemBuilder: (c, i) =>
                      _chatItemRenderer(value[i], titleStyle, now)));
        });
  }

  _chatItemRenderer(Message message, TextStyle titleStyle, int now) {
    // if (message.messageType.isConfirm) {
    //   return _confirmItemRenderer(account, message);
    // }
    // if (message.messageType != Messages.text) return _logItemRenderer(message);
    var padding = 120.d;
    var avatar = Avatar(padding);
    return Column(children: [
      Row(
          textDirection: TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            message.itsMe ? SizedBox(width: padding) : avatar,
            Expanded(
                child: Widgets.button(context,
                    padding: EdgeInsets.fromLTRB(36.d, 12.d, 36.d, 16.d),
                    decoration: Widgets.imageDecorator(
                        "chat_balloon_${message.itsMe ? "right" : "left"}",
                        ImageCenterSliceData(
                            80, 78, const Rect.fromLTWH(39, 16, 2, 2))),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(message.sender,
                              style: titleStyle,
                              textAlign: message.itsMe
                                  ? TextAlign.right
                                  : TextAlign.left),
                          Text(message.text,
                              textDirection: message.text.getDirection())
                        ]),
                    onTapUp: (details) => _onChatItemTap(details, message))),
            message.itsMe ? avatar : SizedBox(width: padding),
          ]),
      Row(children: [
        SizedBox(width: padding + 24.d),
        Text((now - message.creationDate).toElapsedTime(),
            style: TStyles.smallInvert)
      ]),
      SizedBox(height: 20.d)
    ]);
  }

  // Widget _confirmItemRenderer(Message message) {
  //   var padding = EdgeInsets.fromLTRB(32.d, 12.d, 32.d, 32.d);
  //   return Widgets.rect(
  //       margin: EdgeInsets.only(bottom: 48.d),
  //       padding: EdgeInsets.fromLTRB(32.d, 26.d, 16.d, 16.d),
  //       decoration:
  //           Widgets.imageDecorator("ui_popup_group", ImageCenterSliceData(144)),
  //       child: Column(
  //           crossAxisAlignment: getService<Localization>().columnAlign,
  //           children: [
  //             Text(message.text),
  //             SizedBox(height: 16.d),
  //             Row(mainAxisAlignment: MainAxisAlignment.end, children: [
  //               Widgets.skinnedButton(context,
  //                   padding: padding,
  //                   label: "reject_l".l(),
  //                   color: ButtonColor.yellow,
  //                   onPressed: () => _decide(account.tribe!, message, false)),
  //               SizedBox(width: 24.d),
  //               Widgets.skinnedButton(context,
  //                   padding: padding,
  //                   label: "accept_l".l(),
  //                   color: ButtonColor.green,
  //                   onPressed: () => _decide(account.tribe!, message, true)),
  //             ])
  //           ]));
  // }

  // Widget _logItemRenderer(Message message) {
  //   return Padding(
  //       padding: EdgeInsets.only(bottom: 64.d),
  //       child: SkinnedText(message.text));
  // }

  void _onChatItemTap(TapUpDetails details, Message message) {}

  _scrollDown({int duration = 500, int delay = 0}) async {
    if (_scrollController.positions.isEmpty ||
        _scrollController.position.pixels <= 0) return;
    await Future.delayed(Duration(milliseconds: delay));
    await _scrollController.animateTo(0,
        duration: Duration(milliseconds: duration),
        curve: Curves.fastOutSlowIn);
  }

  Widget _inputView() {
    return Widgets.rect(
        radius: 70.d,
        margin: EdgeInsets.symmetric(horizontal: 32.d),
        padding: EdgeInsets.all(12.d),
        color: TColors.white,
        child: Row(textDirection: TextDirection.ltr, children: [
          Expanded(
              child: Widgets.skinnedInput(
            radius: 56.d,
            maxLines: null,
            controller: _inputController,
            onChange: (text) {
              if (text.contains("\n")) {
                _inputController.text = text.substring(0, text.length - 1);
                _sendMessage();
              }
            },
            onSubmit: (text) => _sendMessage(),
          )),
          SizedBox(width: 12.d),
          Widgets.button(context,
              color: TColors.primary80,
              height: 128.d,
              radius: 200.d,
              padding: EdgeInsets.all(30.d),
              child: Asset.load<Image>("icon_send"),
              onPressed: () => _sendMessage())
        ]));
  }

  _sendMessage() async {
    FocusManager.instance.primaryFocus?.unfocus();
    _messages.add(Message(
        text: _inputController.text,
        creationDate: DateTime.now().secondsSinceEpoch));
    _inputController.text = "";
  }
}
