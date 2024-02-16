import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class ChatScreen extends AbstractScreen {
  ChatScreen({super.key}) : super(Routes.chat);

  @override
  createState() => _ChatScreenState();
}

class _ChatScreenState extends AbstractScreenState<ChatScreen> {
  dynamic topic;
  final Messages _messages = Messages([]);
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();

  String _userName = "";
  String _conversationId = "";
  final ValueNotifier<bool> _isWriting = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    topic = Get.arguments;
    _loadData();
    _addMessage("Merhaba");
  }

  Future<void> _loadData() async {
    var result = await serviceLocator<HttpConnection>()
        .tryRpc(context, HttpConnection.rpcDialogue, params: {
      "scenario": topic["id"],
      "promptAddition": topic["prompt"],
      "destLanguage": "turkish"
    });
    _parseResponse(result);
  }

  @override
  Widget appBarFactory(double paddingTop) {
    var appBarElements = <Widget>[];
    appBarElements.addAll(appBarElementsLeft());
    appBarElements.add(const Avatar("avatar_0", 50));
    appBarElements.add(const SizedBox(width: 10));
    appBarElements.add(
      ValueListenableBuilder(
        valueListenable: _isWriting,
        builder: (context, value, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(_userName),
              value ? WritingBuilder(name: _userName) : const SizedBox(),
            ],
          );
        },
      ),
    );
    return PositionedDirectional(
      top: 0,
      start: 0,
      end: 0,
      height: 64,
      child: Widgets.rect(
        color: TColors.cyan,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: appBarElements),
      ),
    );
  }

  @override
  Widget contentFactory() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 70),
      _chatList(),
      const SizedBox(height: 5),
      _choicesRenderer(),
      const SizedBox(height: 5),
      _inputView(),
      const SizedBox(height: 5),
    ]);
  }

  Widget _chatList() {
    var now = DateTime.now().secondsSinceEpoch;
    return ValueListenableBuilder<List<Message>>(
        valueListenable: _messages,
        builder: (context, value, child) {
          _scrollDown(delay: 10);
          return Expanded(
              child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: value.length,
                  itemBuilder: (c, i) => _chatItemRenderer(value[i], now)));
        });
  }

  Widget _chatItemRenderer(Message message, int now) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _defaultChatItemRenderer(message),
      // _footerChatItemRenderer(message, now),
      SizedBox(height: 16.d),
    ]);
  }

  Widget _choicesRenderer() {
    return ValueListenableBuilder<List<Message>>(
      valueListenable: _messages,
      builder: (context, value, child) {
        if (value.isEmpty || value.first is! ChoiceMessage) {
          return const SizedBox();
        }
        var message = value.first as ChoiceMessage;
        var items = <Widget>[];
        for (var choice in message.choices) {
          items.add(
            Widgets.button(
              context,
              radius: 32.d,
              padding: EdgeInsets.symmetric(horizontal: 12.d, vertical: 4.d),
              margin: EdgeInsets.all(3.d),
              color: TColors.primary40,
              child: SkinnedText(choice["destLanguage"]!,
                  style: TStyles.largeInvert),
              onPressed: () {
                message.choices.clear();
                _sendMessage(choice["destLanguage"]);
              },
            ),
          );
        }
        return Widgets.rect(
          color: TColors.primary10,
          padding: EdgeInsets.all(12.d),
          child: Wrap(verticalDirection: VerticalDirection.up, children: items),
        );
      },
    );
  }

  Widget _defaultChatItemRenderer(Message message) {
    return Widgets.button(
      context,
      margin: EdgeInsets.symmetric(horizontal: 16.d),
      padding: EdgeInsets.symmetric(horizontal: 16.d, vertical: 18.d),
      decoration: BalloonDecoration(
          mainColor: message.itsMe ? TColors.primary0 : TColors.primary10,
          tipPosition: message.itsMe
              ? BalloonTipPosition.rightBottom
              : BalloonTipPosition.leftTop),
      child: Text(
        message.text,
        textDirection: message.text.getDirection(),
      ),
    );
  }

/*   Widget _footerChatItemRenderer(Message message, int now) {
    return Row(
      mainAxisAlignment:
          message.itsMe ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        SizedBox(width: 24.d),
        Text((now - message.creationDate).toElapsedTime(),
            style: TStyles.small.copyWith(color: TColors.primary40)),
        SizedBox(width: 24.d),
      ],
    );
  }
 */
  Future<void> _scrollDown({int duration = 500, int delay = 0}) async {
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
        color: TColors.primary20,
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.symmetric(horizontal: 4),
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
              height: 56.d,
              radius: 200.d,
              padding: EdgeInsets.all(16.d),
              child: Asset.load<Image>("icon_send"),
              onPressed: () => _sendMessage())
        ]));
  }

  void _addMessage(String text) {
    FocusManager.instance.primaryFocus?.unfocus();
    var message = Message(
      "منصور",
      text,
      DateTime.now().secondsSinceEpoch,
    )..itsMe = true;
    _messages.add(message);
    _inputController.text = "";
  }

  Future<void> _sendMessage([String? text]) async {
    text = text ?? _inputController.text;
    _addMessage(text);
    _isWriting.value = true;
    var result = await serviceLocator<HttpConnection>().tryRpc(
        context, HttpConnection.rpcDialogue, params: {
      "scenario": topic["id"],
      "conversationId": _conversationId,
      "replyWith": text
    });
    _isWriting.value = false;
    _parseResponse(result);
  }

  void _parseResponse(result) {
    _conversationId = result["conversationId"];
    Message message;
    var response = result["response"];
    var now = DateTime.now().secondsSinceEpoch;
    if (result.containsKey("choices")) {
      message = ChoiceMessage(
        response["name"],
        response["text"],
        now,
        List.castFrom<dynamic, Map<String, dynamic>>(result["choices"]),
      );
    } else {
      message = Message(response["name"], response["text"], now);
    }
    _userName = response["name"];
    _messages.add(message);
  }
}

// ignore: must_be_immutable
class WritingBuilder extends StatelessWidget {
  final String name;
  final ValueNotifier<int> _counter = ValueNotifier(0);

  String _firstName = "";
  WritingBuilder({required this.name, super.key}) {
    _firstName = "${name.split(" ")[0]}'s writing ";
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _counter.value++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _counter,
      builder: (context, value, child) =>
          Text("$_firstName${_getDots(value % 3)}"),
    );
  }

  _getDots(int length) {
    var result = "";
    for (var i = 0; i < length; i++) {
      result += ".";
    }
    return result;
  }
}
