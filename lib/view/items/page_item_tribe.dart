import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

import '../../data/core/account.dart';
import '../../data/core/adam.dart';
import '../../data/core/building.dart';
import '../../data/core/message.dart';
import '../../data/core/tribe.dart';
import '../../providers/account_provider.dart';
import '../../services/connection/noob_socket.dart';
import '../../services/device_info.dart';
import '../../services/inbox.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/overlays/chat_options_overlay.dart';
import '../../view/popups/tribe_search_popup.dart';
import '../overlays/overlay.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/loader_widget.dart';
import '../widgets/skinned_text.dart';
import 'page_item.dart';

class TribePageItem extends AbstractPageItem {
  const TribePageItem({super.key}) : super("tribe");
  @override
  createState() => _TribePageItemState();
}

class _TribePageItemState extends AbstractPageItemState<TribePageItem> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(builder: (_, state, child) {
      // Show unavailable message
      var levels = state.account.loadingData.rules["availabilityLevels"]!;
      if (state.account.level < levels["tribe"]!) {
        return SkinnedText("unavailable_l".l(["tribe_l".l(), levels["tribe"]]));
      }

      if (state.account.tribe == null || state.account.tribe!.id <= 0) {
        return Column(children: [
          Expanded(child: TribeSearchPopup()),
          Widgets.skinnedButton(context, label: "tribe_new".l(), width: 380.d,
              onPressed: () async {
            await Routes.popupTribeEdit.navigate(context);
            setState(() {});
          }),
          SizedBox(height: 200.d),
        ]);
      }
      state.account.tribe!.loadMembers(context, state.account);
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(height: 10.d),
        _headerBuilder(state.account),
        _pinnedMessage(state.account),
        _chatList(state.account),
        SizedBox(height: 6.d),
        _inputView(state.account),
        SizedBox(height: 220.d)
      ]);
    });
  }

  Widget _headerBuilder(Account account) {
    var margin = 12.d;
    return Stack(children: [
      Positioned(
          top: margin,
          right: margin,
          left: margin,
          bottom: margin * 1.5,
          child: Widgets.rect(
              decoration: Widgets.imageDecorator(
                  "tribe_header", ImageCenterSliceData(267, 256)))),
      Widgets.button(
        context,
        onPressed: () async {
          await Routes.popupTribeOptions.navigate(context, args: {"index": 0});
          setState(() {});
        },
        padding: EdgeInsets.fromLTRB(48.d, 44.d, 48.d, 0),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            LoaderWidget(AssetType.animation, "tab_3", fit: BoxFit.fitWidth,
                onRiveInit: (Artboard artboard) {
              final controller =
                  StateMachineController.fromArtboard(artboard, "Tab");
              controller?.findInput<double>("level")!.value =
                  account.tribe!.levels[Buildings.tribe.id]!.toDouble();
              controller?.findInput<bool>("hideBackground")!.value = true;
              controller?.findInput<bool>("active")!.value = true;

              artboard.addController(controller!);
            }, width: 160.d, height: 160.d),
            SizedBox(width: 16.d),
            _informationBuilder(account, account.tribe!),
            const Expanded(child: SizedBox()),
            _membersButtonBuilder(account.tribe!),
          ]),
          SizedBox(height: 20.d),
          SizedBox(
              height: (account.tribe!.description.length / 50).round() * 44.d,
              child: Text(account.tribe!.description,
                  textDirection: account.tribe!.description.getDirection(),
                  style: TStyles.medium.copyWith(height: 1.1))),
          SizedBox(height: 32.d),
          _upgradeLineBuilder(account.tribe!)
        ]),
      )
    ]);
  }

  Widget _informationBuilder(Account account, Tribe tribe) {
    var hasPermission =
        account.tribePosition.index > TribePosition.member.index;
    var name = tribe.name.substring(0, tribe.name.length.max(18));
    if (tribe.name.length > 18) {
      name += " ...";
    }
    return IgnorePointer(
      ignoring: !hasPermission,
      child: Widgets.button(
        context,
        padding: EdgeInsets.zero,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            SkinnedText(name, style: TStyles.large),
            SizedBox(width: 16.d),
            hasPermission
                ? Widgets.rect(
                    padding: EdgeInsets.all(10.d),
                    decoration: Widgets.imageDecorator(
                        "frame_hatch_button", ImageCenterSliceData(42)),
                    child: Asset.load<Image>("tribe_edit", width: 42.d))
                : const SizedBox()
          ]),
          Row(children: [
            _indicator("icon_score", tribe.rank.compact(), 100.d,
                EdgeInsets.only(right: 16.d)),
            SizedBox(width: 16.d),
            _indicator("icon_gold", tribe.gold.compact(), 100.d,
                EdgeInsets.only(right: 16.d)),
          ]),
        ]),
        onPressed: () async {
          await Routes.popupTribeEdit.navigate(context);
          setState(() {});
        },
      ),
    );
  }

  Widget _membersButtonBuilder(Tribe tribe) {
    return ValueListenableBuilder<List<Opponent>>(
        valueListenable: tribe.members,
        builder: (context, value, child) => Widgets.rect(
              width: 260.d,
              padding: EdgeInsets.zero,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _indicator(
                        "icon_population",
                        "${tribe.population}/${tribe.getOption(Buildings.tribe.id)}"
                            .convert(),
                        40.d),
                    SizedBox(height: 8.d),
                    _indicator(
                        "tribe_online",
                        "tribe_onlines".l([tribe.onlineMembersCount.convert()]),
                        32.d),
                  ]),
            ));
  }

  Widget _upgradeLineBuilder(Tribe tribe) {
    return SizedBox(
        width: 840.d,
        height: 102.d,
        child: Row(
          children: [
            _upgradable(ButtonColor.wooden, "upgrade_1002",
                "${tribe.getOption(Buildings.offense.id)}%"),
            _upgradable(ButtonColor.wooden, "upgrade_1003",
                "${tribe.getOption(Buildings.defense.id)}%"),
            _upgradable(ButtonColor.wooden, "upgrade_1004",
                "${tribe.getOption(Buildings.cards.id)}%"),
            Expanded(
                child: _upgradable(
                    ButtonColor.green, "tribe_upgrade", "upgrade_l".l()))
          ],
        ));
  }

  Widget _indicator(String icon, String label, double iconSize,
      [EdgeInsetsGeometry? padding]) {
    return Widgets.rect(
        height: 64.d,
        padding: padding ?? EdgeInsets.only(left: 16.d, right: 16.d),
        decoration: Widgets.imageDecorator(
            "frame_hatch_button", ImageCenterSliceData(42)),
        child: Row(
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Asset.load<Image>(icon, height: iconSize),
              SizedBox(width: 12.d),
              SkinnedText(label)
            ]));
  }

  Widget _upgradable(ButtonColor color, String icon, String label) {
    return Widgets.skinnedButton(context,
        padding: EdgeInsets.fromLTRB(24.d, 0, 28.d, 20.d),
        color: color,
        child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.ltr,
            children: [
              Asset.load<Image>(icon, width: 50.d),
              SizedBox(width: 12.d),
              SkinnedText(label.convert()),
            ]), onPressed: () async {
      await Routes.popupTribeOptions.navigate(context, args: {"index": 1});
      setState(() {});
    });
  }

  Widget _pinnedMessage(Account account) {
    if (account.tribe!.pinnedMessage.value == null) {
      account.tribe!.loadPinnedMessage(context, account);
    }
    return ValueListenableBuilder<NoobChatMessage?>(
        valueListenable: account.tribe!.pinnedMessage,
        builder: (context, value, child) {
          if (value == null) return const SizedBox();
          return Widgets.rect(
              margin: EdgeInsets.fromLTRB(32.d, 16.d, 32.d, 0),
              padding: EdgeInsets.fromLTRB(32.d, 32.d, 32.d, 44.d),
              decoration: Widgets.imageDecorator(
                  "iconed_item_bg_selected",
                  ImageCenterSliceData(
                      132, 68, const Rect.fromLTWH(100, 30, 2, 2))),
              child: Row(children: [
                Asset.load<Image>("icon_pin", width: 50.d),
                SizedBox(width: 32.d),
                Expanded(
                    child: Text(value.text,
                        textDirection: value.text.getDirection())),
              ]));
        });
  }

  Widget _chatList(Account account) {
    var titleStyle = TStyles.small.copyWith(color: TColors.primary30);
    var now = DateTime.now().secondsSinceEpoch;

    // Initialize inbox
    getService<Inbox>().initialize(args: [context, account]);

    return ValueListenableBuilder<List<NoobChatMessage>>(
        valueListenable: account.tribe!.chat,
        builder: (context, value, child) {
          _scrollDown(delay: 10);
          account.tribe!.chat.value
              .sort((a, b) => a.creationDate - b.creationDate);
          return Expanded(
              child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: EdgeInsets.all(48.d),
                  itemCount: account.tribe!.chat.length,
                  itemBuilder: (c, i) => _chatItemRenderer(
                      account,
                      account.tribe!.chat
                          .value[account.tribe!.chat.length - i - 1],
                      titleStyle,
                      now)));
        });
  }

  _chatItemRenderer(
      Account account, NoobChatMessage message, TextStyle titleStyle, int now) {
    if (message.messageType.isConfirm) {
      return _confirmItemRenderer(account, message);
    }
    if (message.messageType != Messages.text) return _logItemRenderer(message);
    var padding = 120.d;
    var avatar = Widgets.button(context,
        width: padding,
        height: padding,
        radius: padding,
        padding: EdgeInsets.all(6.d), onTapUp: (details) async {
      await account.tribe!.loadMembers(context, account);
      if (!mounted) return;
      Overlays.insert(context, OverlayType.member, args: [
        account.tribe!.members.value
            .firstWhere((m) => m.name == message.sender),
        account,
        details.globalPosition.dy - 220.d
      ]);
    },
        decoration: Widgets.imageDecorator(
            "frame_hatch_button", ImageCenterSliceData(42)),
        child: LoaderWidget(AssetType.image, "avatar_${message.avatarId}",
            width: 76.d, height: 76.d, subFolder: "avatars"));
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
                    onTapUp: (details) =>
                        _onChatItemTap(account, details, message))),
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

  Widget _confirmItemRenderer(Account account, NoobChatMessage message) {
    var padding = EdgeInsets.fromLTRB(32.d, 12.d, 32.d, 32.d);
    return Widgets.rect(
        margin: EdgeInsets.only(bottom: 48.d),
        padding: EdgeInsets.fromLTRB(32.d, 26.d, 16.d, 16.d),
        decoration:
            Widgets.imageDecorator("ui_popup_group", ImageCenterSliceData(144)),
        child: Column(
            crossAxisAlignment: getService<Localization>().columnAlign,
            children: [
              Text(message.text),
              SizedBox(height: 16.d),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Widgets.skinnedButton(context,
                    padding: padding,
                    label: "reject_l".l(),
                    color: ButtonColor.yellow,
                    onPressed: () => _decide(account.tribe!, message, false)),
                SizedBox(width: 24.d),
                Widgets.skinnedButton(context,
                    padding: padding,
                    label: "accept_l".l(),
                    color: ButtonColor.green,
                    onPressed: () => _decide(account.tribe!, message, true)),
              ])
            ]));
  }

  Widget _logItemRenderer(NoobChatMessage message) {
    return Padding(
        padding: EdgeInsets.only(bottom: 64.d),
        child: SkinnedText(message.text));
  }

  void _onChatItemTap(
      Account account, TapUpDetails details, NoobChatMessage message) {
    var options = <ChatOptions>[];
    if (account.tribe!.members.value
            .firstWhere((m) => m.itsMe)
            .tribePosition
            .index >=
        TribePosition.owner.index) {
      options.add(ChatOptions.pin);
    }
    if (!message.itsMe) {
      options.add(ChatOptions.reply);
    }
    if (options.isNotEmpty) {
      Overlays.insert(context, OverlayType.chatOptions, args: [
        details.globalPosition.dy - 120.d,
        options,
        (ChatOptions option) {
          if (option == ChatOptions.pin) {
            account.tribe!.pinMessage(context, account, message);
          } else if (option == ChatOptions.reply) {
            _inputController.text =
                "@${message.sender}: ${message.text.truncate(16)}...\n${_inputController.text}";
            setState(() {});
          }
        }
      ]);
    }
  }

  _scrollDown({int duration = 500, int delay = 0}) async {
    if (_scrollController.positions.isEmpty ||
        _scrollController.position.pixels <= 0) return;
    await Future.delayed(Duration(milliseconds: delay));
    await _scrollController.animateTo(0,
        duration: Duration(milliseconds: duration),
        curve: Curves.fastOutSlowIn);
  }

  Widget _inputView(Account account) {
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
                _sendMessage(account);
              }
            },
            onSubmit: (text) => _sendMessage(account),
          )),
          SizedBox(width: 12.d),
          Widgets.button(context,
              color: TColors.primary80,
              height: 128.d,
              radius: 200.d,
              padding: EdgeInsets.all(30.d),
              child: Asset.load<Image>("icon_send"),
              onPressed: () => _sendMessage(account))
        ]));
  }

  _sendMessage(Account account) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await account.tribe!.sendMessage(context, account, _inputController.text);
    _inputController.text = "";
  }

  _decide(Tribe tribe, NoobChatMessage message, bool isAccept) async {
    var data = await message.base?.decideTribeRequest(
        context, message.base!.intData[0], isAccept, message.base!.intData[1]);
    if (data != null) {
      tribe.chat.remove(message);
    }
  }
}
