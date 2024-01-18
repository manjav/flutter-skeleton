import 'package:flutter/material.dart';

import '../../app_export.dart';

class RankingPopup extends AbstractPopup {
  RankingPopup({super.key}) : super(Routes.popupRanking, args: {});

  @override
  createState() => _RankingPopupState();
}

class _RankingPopupState extends AbstractPopupState<RankingPopup>
    with TabBuilderMixin {
  late Account _account;

  @override
  void initState() {
    selectedTabIndex = 0;
    _account = accountProvider.account;
    if (Ranks.lists.isEmpty) {
      Ranks.lists.addAll({
        RpcId.rankingGlobal: null,
        RpcId.rankingExpertTribes: null,
        RpcId.rankingTopTribes: null
      });
    }
    super.initState();
  }

  @override
  EdgeInsets get contentPadding => EdgeInsets.only(top: 192.d, bottom: 32.d);

  @override
  contentFactory() {
    return SizedBox(
        width: DeviceInfo.size.width * 0.95,
        height: DeviceInfo.size.height * 0.75,
        child: Column(
          children: [
            tabsBuilder(
                data: [for (var i = 0; i < 3; i++) TabData("rank_tab_$i".l())]),
            SizedBox(height: 6.d),
            _getSelectedHeader(),
            _getSelectedPage(),
          ],
        ));
  }

  Widget _getSelectedHeader() {
    var items = <Widget>[];
    if (selectedTabIndex == 0) {
      items.addAll([
        SkinnedText("tribe_name".l(), style: TStyles.small),
        SizedBox(width: 128.d)
      ]);
    }
    items.add(Asset.load<Image>(selectedTabIndex == 0 ? "icon_xp" : "icon_seed",
        height: 56.d));
    if (selectedTabIndex == 2) {
      items.addAll([
        SizedBox(width: 8.d),
        SkinnedText("weekly_l".l(), style: TStyles.tiny.copyWith(height: 1)),
        SizedBox(width: 10.d)
      ]);
    } else {
      items.add(SizedBox(width: 32.d));
    }
    return Widgets.rect(
        height: 92.d,
        color: TColors.teal,
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: items));
  }

  Widget _getSelectedPage() {
    var api = Ranks.lists.keys.toList()[selectedTabIndex];
    // var icons = ["xp", "xp", "seed"];
    _loadRanking(api);
    return _listView(api);
  }

  _loadRanking(RpcId api) async {
    try {
      var data = await rpc(api);
      if (api == RpcId.rankingGlobal) {
        Ranks.lists[api] = Ranks.createList<Record>(data, _account.id);
      } else {
        Ranks.lists[api] =
            Ranks.createList<TribeRank>(data, _account.tribe!.id);
      }
      setState(() {});
    } finally {}
  }

  _listView(RpcId api) {
    return Ranks.lists[api] == null
        ? const SizedBox()
        : Expanded(
            child: ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(104.d),
                    bottomRight: Radius.circular(104.d)),
                child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 40.d),
                    itemBuilder: (c, i) => _itemBuilder(c, i, api),
                    itemCount: Ranks.lists[api]!.length)));
  }

  _itemBuilder(BuildContext context, int index, RpcId rpcId) {
    Rank record = Ranks.lists[rpcId]![index];
    if (record.name.isEmpty) {
      return SizedBox(height: 120.d, child: SkinnedText("rank_near".l()));
    }
    var color = index % 2 == 0 ? TColors.primary : TColors.primary90;
    if (record.itsMe) {
      color = TColors.orange;
      record.name = rpcId == RpcId.rankingGlobal ? "You" : record.name;
    }
    var rank = rpcId == RpcId.rankingTopTribes
        ? (record as TribeRank).weeklyRank
        : record.rank;
    var score = rpcId == RpcId.rankingTopTribes
        ? (record as TribeRank).weeklyScore
        : record.score;

    return Widgets.button(context,
        height: 100.d,
        radius: 0,
        color: color,
        padding: EdgeInsets.only(left: 8.d, right: 16.d),
        child: Row(children: [
          Widgets.rect(
              radius: 24.d,
              width: 144.d,
              height: 76.d,
              alignment: Alignment.center,
              color: rank < 4 ? TColors.transparent : TColors.primary20,
              child: rank < 4
                  ? Asset.load<Image>("medal_$rank")
                  : Text('$rank', style: TStyles.smallInvert)),
          SizedBox(width: 16.d),
          Expanded(child: Text(record.name, style: TStyles.tiny)),
          SizedBox(width: 4.d),
          SizedBox(
              width: 220.d,
              child: rpcId == RpcId.rankingGlobal
                  ? Text((record as Record).tribeName,
                      style: TStyles.small, textAlign: TextAlign.center)
                  : null),
          SizedBox(width: 79.d),
          Text(score.compact(), style: TStyles.small),
        ]), onPressed: () async {
      if (rpcId == RpcId.rankingGlobal && !record.itsMe) {
        services
            .get<RouteService>()
            .to(Routes.popupProfile, args: {"id": record.id});
      }
    });
  }
}
