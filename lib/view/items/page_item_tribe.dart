import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/building.dart';
import '../../data/core/ranking.dart';
import '../../data/core/tribe.dart';
import '../../services/connection/noob_socket.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/popups/tribe_search_popup.dart';
import '../../view/widgets/skinnedtext.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/loaderwidget.dart';
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
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      // Show unavailable message
      if (state.account.get<int>(AccountField.level) <
          Account.availablityLevels["tribe"]!) {
        return SkinnedText("unavailable_l"
            .l(["tribe_l".l(), Account.availablityLevels["tribe"]]));
      }

      var tribe = state.account.get<Tribe?>(AccountField.tribe);
      if (tribe == null || tribe.id <= 0) {
        return Column(children: [
          Expanded(child: TribeSearchPopup()),
          Widgets.skinnedButton(
              label: "tribe_new".l(),
              width: 380.d,
              onPressed: () async {
                await Navigator.pushNamed(
                    context, Routes.popupTribeEdit.routeName);
                setState(() {});
              }),
          SizedBox(height: 200.d),
        ]);
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(height: 10.d),
        _headerBuilder(tribe),
        _pinnedMessage(),
        _chatList(tribe),
        SizedBox(height: 32.d),
        _inputView(state.account, tribe),
        SizedBox(height: 220.d)
      ]);
    });
  }

  Widget _headerBuilder(Tribe tribe) {
    var margin = 12.d;
    return Stack(children: [
      Positioned(
          top: margin,
          right: margin,
          left: margin,
          bottom: margin * 1.5,
          child: Widgets.rect(
              decoration: Widgets.imageDecore(
                  "tribe_header", ImageCenterSliceData(267, 256)))),
      Widgets.button(
        onPressed: () async {
          await Navigator.of(context).pushNamed(
              Routes.popupTribeOptions.routeName,
              arguments: {"index": 0});
          setState(() {});
        },
        padding: EdgeInsets.fromLTRB(48.d, 44.d, 48.d, 0),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Asset.load<Image>("tribe_icon", width: 120.d),
            SizedBox(width: 16.d),
            _informationBuilder(tribe),
            const Expanded(child: SizedBox()),
            _membersButtonBuilder(tribe),
          ]),
          SizedBox(height: 24.d),
          SizedBox(
              height: (tribe.description.length / 50).round() * 44.d,
              child: SkinnedText(tribe.description,
                  alignment: Alignment.centerLeft,
                  style: TStyles.medium.copyWith(height: 1.1))),
          SizedBox(height: 32.d),
          _upgradeLineBuilder(tribe)
        ]),
      )
    ]);
  }

  Widget _informationBuilder(Tribe tribe) {
    var name = tribe.name.substring(0, tribe.name.length.max(18));
    if (tribe.name.length > 18) {
      name += " ...";
    }
    return Widgets.button(
        padding: EdgeInsets.zero,
        onPressed: () async {
          await Navigator.pushNamed(context, Routes.popupTribeEdit.routeName);
          setState(() {});
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            SkinnedText(name, style: TStyles.large),
            SizedBox(width: 16.d),
            Widgets.rect(
                padding: EdgeInsets.all(10.d),
                decoration: Widgets.imageDecore(
                    "ui_frame_inside", ImageCenterSliceData(42)),
                child: Asset.load<Image>("tribe_edit", width: 42.d))
          ]),
          Row(children: [
            _indicator("icon_score", tribe.weeklyRank.compact(), 100.d,
                EdgeInsets.only(right: 16.d)),
            SizedBox(width: 16.d),
            _indicator("icon_gold", tribe.gold.compact(), 100.d,
                EdgeInsets.only(right: 16.d)),
          ]),
        ]));
  }

  Widget _membersButtonBuilder(Tribe tribe) {
    return Widgets.rect(
      width: 260.d,
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _indicator("icon_population",
            "${tribe.population}/${tribe.getOption(Buildings.base.id)}", 40.d),
        SizedBox(height: 8.d),
        _indicator("tribe_online", "2 onlines", 32.d),
      ]),
    );
  }

  Widget _upgradeLineBuilder(Tribe tribe) {
    return SizedBox(
        width: 840.d,
        height: 96.d,
        child: Row(
          children: [
            _upgradable(ButtonColor.wooden, "tribe_upgrade_1002",
                "${tribe.getOption(Buildings.offense.id)}%"),
            _upgradable(ButtonColor.wooden, "tribe_upgrade_1003",
                "${tribe.getOption(Buildings.defense.id)}%"),
            _upgradable(ButtonColor.wooden, "tribe_upgrade_1004",
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
        decoration:
            Widgets.imageDecore("ui_frame_inside", ImageCenterSliceData(42)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Asset.load<Image>(icon, height: iconSize),
          SizedBox(width: 12.d),
          SkinnedText(label)
        ]));
  }

  Widget _upgradable(ButtonColor color, String icon, String label) {
    return Widgets.skinnedButton(
        padding: EdgeInsets.fromLTRB(24.d, 0, 28.d, 20.d),
        color: color,
        size: ButtonSize.small,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Asset.load<Image>(icon, width: 50.d),
          SizedBox(width: 8.d),
          SkinnedText(label),
        ]),
        onPressed: () async {
          await Navigator.pushNamed(context, Routes.popupTribeOptions.routeName,
              arguments: {"index": 1});
          setState(() {});
        });
  }

  Widget _pinnedMessage() {
    return Widgets.button(
      color: TColors.accent,
      onPressed: () {},
      child: const Text("pin"),
    );
  }

  _chatList(Tribe tribe) {
    var titleStyle = TStyles.small.copyWith(color: TColors.primary70);
    var now = DateTime.now().secondsSinceEpoch;
    return ValueListenableBuilder<List<NoobChatMessage>>(
      valueListenable: tribe.chat,
      builder: (context, value, child) {
        _scrollDown(delay: 100);
        return Expanded(
            child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(48.d),
                itemCount: tribe.chat.length,
                itemBuilder: (c, i) =>
                    _chatItemRenderer(tribe.chat.value[i], titleStyle, now)));
      },
    );
  }

  _chatItemRenderer(NoobChatMessage message, TextStyle titleStyle, int now) {
    var padding = 120.d;
    var avatar = Widgets.rect(
        width: padding,
        height: padding,
        radius: padding,
        padding: EdgeInsets.all(6.d),
        decoration:
            Widgets.imageDecore("ui_frame_inside", ImageCenterSliceData(42)),
        child: LoaderWidget(AssetType.image, "avatar_${message.avatarId + 1}",
            width: 76.d, height: 76.d, subFolder: "avatars"));
    return Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        message.itsMe ? SizedBox(width: padding) : avatar,
        Expanded(
            child: Widgets.rect(
                padding: EdgeInsets.fromLTRB(36.d, 12.d, 36.d, 16.d),
                decoration: Widgets.imageDecore(
                    "chat_balloon_${message.itsMe ? "right" : "left"}",
                    ImageCenterSliceData(
                        80, 78, const Rect.fromLTWH(39, 13, 2, 2))),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(message.sender,
                          style: titleStyle,
                          textAlign:
                              message.itsMe ? TextAlign.right : TextAlign.left),
                      Text(message.text,
                          textDirection: message.text.getDirection())
                    ]))),
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

  _scrollDown({int duration = 500, int delay = 0}) async {
    await Future.delayed(Duration(milliseconds: delay));
    await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: duration),
        curve: Curves.fastOutSlowIn);
  }

  Widget _inputView(Account account, Tribe tribe) {
    return Widgets.rect(
        height: 136.d,
        radius: 200.d,
        margin: EdgeInsets.symmetric(horizontal: 32.d),
        padding: EdgeInsets.all(12.d),
        color: TColors.white,
        child: Row(children: [
          Expanded(
              child: Widgets.skinnedInput(
            controller: _inputController,
            radius: 56.d,
            onSubmit: (text) => _sendMessage(account, tribe),
          )),
          SizedBox(width: 12.d),
          Widgets.button(
              color: TColors.primary80,
              radius: 200.d,
              padding: EdgeInsets.all(30.d),
              child: Asset.load<Image>("icon_send"),
              onPressed: () => _sendMessage(account, tribe))
        ]));
  }

  _sendMessage(Account account, Tribe tribe) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tribe.sendMessage(context, account, _inputController.text);
    _inputController.text = "";
  }
}
