import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../../skeleton/skeleton.dart';

class LeaguePopup extends AbstractPopup {
  LeaguePopup({super.key}) : super(Routes.popupLeague, args: {});

  @override
  createState() => _LeaguePopupState();
}

class _LeaguePopupState extends AbstractPopupState<LeaguePopup>
    with TabBuilderMixin {
  late Account _account;
  LeagueData? _leagueData;
  LeagueHistory? _leagueHistory;

  @override
  void initState() {
    _account = accountProvider.account;
    selectedTabIndex = 0;
    super.initState();
  }

  @override
  EdgeInsets get contentPadding => EdgeInsets.fromLTRB(0, 176.d, 0, 32.d);

  @override
  Widget contentFactory() {
    return SizedBox(
        width: DeviceInfo.size.width * 0.95,
        height: DeviceInfo.size.height * 0.75,
        child: Column(
          children: [
            tabsBuilder(data: [
              for (var i = 0; i < 3; i++) TabData("league_tab_$i".l()),
            ]),
            Expanded(child: _getSelectedPage())
          ],
        ));
  }

  Widget _getSelectedPage() {
    return switch (selectedTabIndex) {
      0 => _myLeaguePage(),
      1 => _roadMap(),
      _ => _historyPage(),
    };
  }

  _loadLeagueData() async {
    try {
      var data = await rpc(RpcId.league);
      _leagueData = LeagueData.initialize(data, _account.id);
      setState(() {});
    } finally {}
  }

  _myLeaguePage() {
    if (_leagueData == null) {
      _loadLeagueData();
      return const SizedBox();
    }
    var indices = LeagueData.getIndices(_leagueData!.id);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 16.d),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoaderWidget(AssetType.image, "league_${indices.$1}",
                    subFolder: "leagues", height: 170.d),
                SkinnedText(
                    "${'league_${indices.$1}'.l()}  ${'l_${indices.$2}'.l()}"),
                Widgets.rect(
                    radius: 24.d,
                    padding: EdgeInsets.all(20.d),
                    color: TColors.primary70,
                    child: SkinnedText(
                        (_account.league_remaining_time).toRemainingTime()))
              ],
            ),
            Widgets.rect(
                width: 500.d,
                height: 320.d,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Asset.load<Image>('rank_platform'),
                    _prizeItem(0, null, null, 115.d),
                    _prizeItem(1, 8.d, null, 53.d),
                    _prizeItem(2, null, 8.d, 30.d)
                  ],
                )),
          ],
        ),
        SizedBox(height: 16.d),
        Widgets.rect(
            height: 92.d,
            color: TColors.teal,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              SkinnedText("tribe_name".l(), style: TStyles.small),
              SizedBox(width: 60.d),
              Asset.load<Image>("icon_seed", height: 56.d),
              SizedBox(width: 8.d),
              SkinnedText("weekly_l".l(),
                  style: TStyles.tiny.copyWith(height: 1)),
              SizedBox(width: 10.d),
            ])),
        Expanded(
            child: ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(104.d),
                    bottomRight: Radius.circular(104.d)),
                child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 40.d),
                    itemBuilder: (c, i) =>
                        _itemBuilder(c, _leagueData!.list[i]),
                    itemCount: _leagueData!.list.length))),
      ],
    );
  }

  _prizeItem(int index, double? left, double? right, double bottom) {
    return Positioned(
        bottom: bottom,
        left: left,
        right: right,
        width: 150.d,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Asset.load<Image>("icon_card", height: 46.d),
            SkinnedText(" ${3 - index}")
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Asset.load<Image>("icon_power", height: 46.d),
            SkinnedText("+${_leagueData!.rewardAvgCardPower.round().compact()}",
                style: TStyles.small)
          ]),
          SizedBox(height: 30.d),
          SkinnedText(_leagueData!.winnerRanges[index].join("~"),
              style: TStyles.small)
        ]));
  }

  _itemBuilder(BuildContext context, LeagueRank record) {
    if (record.name.isEmpty) {
      return SizedBox(height: 120.d, child: SkinnedText("rank_near".l()));
    }
    var color = record.index % 2 == 0 ? TColors.primary : TColors.primary90;
    if (record.itsMe) {
      color = TColors.orange;
      record.name = record.itsMe ? "You" : record.name;
    }

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
              color: record.rank < 4 ? TColors.transparent : TColors.primary20,
              child: record.rank < 4
                  ? Asset.load<Image>("medal_${record.rank}")
                  : Text("${record.rank}", style: TStyles.smallInvert)),
          SizedBox(width: 16.d),
          Expanded(child: Text(record.name, style: TStyles.tiny)),
          SizedBox(width: 4.d),
          SizedBox(
              width: 200.d,
              child: Text(record.tribeName,
                  style: TStyles.small.copyWith(height: 1),
                  textAlign: TextAlign.center)),
          SizedBox(width: 100.d),
          Text(record.weeklyScore.compact(), style: TStyles.small),
        ]), onPressed: () async {
      if (!record.itsMe) {
        Routes.popupProfile.navigate(context, args: {"id": record.id});
      }
    });
  }

  Widget _roadMap() {
    return Padding(
        padding: EdgeInsets.all(24.d),
        child: Stack(
          children: [
            Positioned(
                top: 100.d,
                left: 0,
                right: 0,
                bottom: 0,
                child: const LoaderWidget(AssetType.image, "league_roadmap")),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("league_bonus_current".l(), style: TStyles.small),
              Text("league_bonus_next".l(), style: TStyles.small)
            ]),
            Positioned(
                top: 50.d,
                right: 0,
                left: 0,
                child: Row(children: [
                  Asset.load<Image>("icon_gold", width: 60.d),
                  Text("  ${_leagueData!.currentBonus}"),
                  const Expanded(child: SizedBox()),
                  Asset.load<Image>("icon_gold", width: 60.d),
                  Text("  ${_leagueData!.nextBonus}"),
                ])),
          ],
        ));
  }

  Widget _historyPage() {
    if (_leagueHistory == null) {
      _loadLeagueHistory();
      return const SizedBox();
    }
    return ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(104.d),
            bottomRight: Radius.circular(104.d)),
        child: ListView.builder(
            padding: EdgeInsets.only(bottom: 32.d),
            itemBuilder: _historyItemBuilder,
            itemCount: LeagueData.stages.length));
  }

  _loadLeagueHistory([int round = 1]) async {
    try {
      var data = await rpc(RpcId.leagueHistory,
          params: {RpcParams.rounds.name: "[$round]"});
      _leagueHistory = LeagueHistory.initialize(data, round, _account.id);
      setState(() {});
    } finally {}
  }

  Widget? _historyItemBuilder(BuildContext context, int index) {
    var stage = LeagueData.stages[index];
    var steps = <Widget>[
      Padding(
          padding: EdgeInsets.all(18.d),
          child: LoaderWidget(AssetType.image, "league_${index + 1}",
              subFolder: "leagues", height: 140.d))
    ];
    for (var step in stage) {
      steps.add(_stepBuilder(step));
    }
    return Column(mainAxisSize: MainAxisSize.min, children: steps);
  }

  Widget _stepBuilder(int step) {
    var indices = LeagueData.getIndices(step);
    var lines = <Widget>[];
    if (step > 1) {
      lines.add(Widgets.rect(
          height: 92.d,
          color: TColors.teal,
          alignment: Alignment.center,
          child: Text("l_${indices.$2}".l(), style: TStyles.mediumInvert)));
    }
    for (var rank in _leagueHistory!.lists["$step"]!) {
      lines.add(_itemBuilder(context, rank));
    }
    return Column(mainAxisSize: MainAxisSize.min, children: lines);
  }
}
