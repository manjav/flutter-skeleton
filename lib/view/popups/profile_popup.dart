import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../data/core/account.dart';
import '../../data/core/achievement.dart';
import '../../data/core/adam.dart';
import '../../data/core/building.dart';
import '../../data/core/rpc.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/popups/ipopup.dart';
import '../../view/tab_provider.dart';
import '../../view/widgets/indicator_level.dart';
import '../../view/widgets/loaderwidget.dart';
import '../../view/widgets/skinnedtext.dart';
import '../route_provider.dart';
import '../widgets.dart';

class ProfilePopup extends AbstractPopup {
  final int playerId;

  ProfilePopup(this.playerId, {super.key})
      : super(Routes.popupProfile, args: {});

  @override
  createState() => _ProfilePopupState();
}

class _ProfilePopupState extends AbstractPopupState<ProfilePopup>
    with TabProviderMixin {
  Player? _player;
  @override
  EdgeInsets get contentPadding => EdgeInsets.fromLTRB(24.d, 200.d, 24.d, 92.d);
  @override
  String titleBuilder() => "profile_tab_0".l();

  @override
  void initState() {
    selectedTabIndex = 0;
    super.initState();
  }

  @override
  Widget contentFactory() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      tabsBuilder(data: [
        for (var i = 0; i < 2; i++) TabData("profile_tab_$i".l()),
      ]),
      SizedBox(
          height: DeviceInfo.size.height * 0.6,
          child: switch (selectedTabIndex) {
            < 1 => _profileSegment(),
            _ => _achievementSegment(),
          })
    ]);
  }

  _loadPlayer() async {
    if (_player != null) return;
    if (widget.playerId > 0) {
      var result = await rpc(RpcId.getProfileInfo,
          params: {RpcParams.player_id.name: widget.playerId});
      setState(() => _player = Player.initialize(result, 0));
    } else {
      _player = accountBloc.account!;
    }
  }

  Widget _profileSegment() {
    _loadPlayer();
    return SizedBox(
      child: _player == null
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                  _headerBuilder(),
                  _medalsBuilder(),
                  _leagueBuilder(),
                ]),
    );
  }

  Widget _headerBuilder() {
    return Widgets.rect(
        padding: EdgeInsets.symmetric(horizontal: 10.d, vertical: 7.d),
        decoration: Widgets.imageDecore("frame_header_cheese",
            ImageCenterSliceData(114, 226, const Rect.fromLTWH(58, 61, 2, 2))),
        width: 940.d,
        height: 510.d,
        child: Stack(clipBehavior: Clip.none, children: [
          Widgets.rect(
              height: 192.d,
              decoration: Widgets.imageDecore(
                  "frame_hatch", ImageCenterSliceData(80, 100))),
          Positioned(
              top: -48.d,
              left: 24.d,
              child: const LevelIndicator(showLevel: false)),
          Positioned(
              top: 10.d,
              left: 250.d,
              child: SkinnedText(_player!.name, style: TStyles.large)),
          Positioned(
              top: 80.d,
              left: 250.d,
              child: Row(children: [
                SkinnedText("mood_l".l()),
                SizedBox(width: 16.d),
                LoaderWidget(AssetType.image, "mood_${_player!.moodId}",
                    subFolder: "moods", width: 50.d)
              ])),
          Positioned(
              top: 220.d,
              left: 60.d,
              child: _indicator("total_rank".l(), _player!.rank.toString(),
                  icon: "icon_rank")),
          Positioned(
              top: 360.d,
              left: 60.d,
              child: _indicator(
                  "last_played".l(),
                  (DateTime.now().secondsSinceEpoch - _player!.lastLoadAt)
                      .toElapsedTime())),
          Positioned(
              top: 220.d,
              left: 500.d,
              child: Widgets.divider(direction: Axis.vertical, height: 220.d)),
          Positioned(
              top: 210.d, right: 12.d, width: 380.d, child: _tribeSection())
        ]));
  }

  Widget _indicator(String label, String value,
      {String? icon, TextStyle? valueStyle}) {
    return Widgets.rect(
      constraints: BoxConstraints(minWidth: 250.d),
      height: 96.d,
      padding: EdgeInsets.zero,
      decoration: Widgets.imageDecore("frame_hatch", ImageCenterSliceData(60)),
      child: Stack(
          alignment: const Alignment(0, -0.2),
          clipBehavior: Clip.none,
          children: [
            Positioned(
                top: -34.d,
                left: 10.d,
                child: Text(label, style: TStyles.tiny)),
            Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(width: icon == null ? 16.d : 8.d),
              icon != null
                  ? Asset.load<Image>(icon, width: 68.d)
                  : const SizedBox(),
              SizedBox(width: icon == null ? 0 : 16.d),
              SkinnedText(value, style: valueStyle ?? TStyles.medium),
              SizedBox(width: 16.d),
            ])
          ]),
    );
  }

  Widget _tribeSection() {
    return Column(children: [
      LoaderWidget(AssetType.animation, "tab_3", fit: BoxFit.fitWidth,
          onRiveInit: (Artboard artboard) {
        final controller = StateMachineController.fromArtboard(artboard, "Tab");
        var level = _player!.tribeName == accountBloc.account!.tribeName &&
                _player!.tribeId > 0
            ? accountBloc.account!.tribe!.levels[Buildings.base.id]!.toDouble()
            : 0.0;
        controller?.findInput<double>("level")!.value = level;
        controller?.findInput<bool>("hideBackground")!.value = true;
        controller?.findInput<bool>("active")!.value = true;
        artboard.addController(controller!);
      }, width: 130.d, height: 130.d),
      SizedBox(height: 20.d),
      SkinnedText(_player!.tribeName, style: TStyles.large),
    ]);
  }

  Widget _medalsBuilder() {
    return SizedBox(
        height: 280.d,
        child: Stack(alignment: Alignment.bottomCenter, children: [
          Positioned(
              bottom: 50.d,
              child: Widgets.rect(
                  height: 71.d,
                  width: 880.d,
                  margin: EdgeInsets.fromLTRB(16.d, 44.d, 16.d, 0),
                  decoration: Widgets.imageDecore(
                      "shelf", ImageCenterSliceData(108, 71)))),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 10001; i < 10007; i++)
                  _medalBuilder(i, _player!.medals[i])
              ])
        ]));
  }

  Widget _medalBuilder(int name, int? count) {
    var size = 140.d;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColorFiltered(
            colorFilter: ColorFilter.mode(
              count == null ? TColors.black80 : TColors.white,
              count == null ? BlendMode.srcIn : BlendMode.dstIn,
            ),
            child: LoaderWidget(AssetType.image, "medal_$name",
                subFolder: "medals", width: size, height: size)),
        SizedBox(height: 30.d),
        count != null ? Text("x$count") : SizedBox(height: 48.d)
      ],
    );
  }

  Widget _leagueBuilder() {
    if (_player!.leagueId <= 0) return const SizedBox();
    var battles = _player!.wonBattlesCount + _player!.lostBattlesCount;
    var battleRate = battles == 0 ? 0 : _player!.wonBattlesCount / battles;
    return Widgets.rect(
        margin: EdgeInsets.only(top: 30.d),
        decoration: Widgets.imageDecore("frame_header_cheese",
            ImageCenterSliceData(114, 226, const Rect.fromLTWH(58, 61, 2, 2))),
        width: 940.d,
        height: 410.d,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
              top: -25.d, left: 60.d, child: SkinnedText("popupleague".l())),
          Positioned(
              top: 50.d,
              left: 80.d,
              child: Asset.load<Image>(
                  "icon_league_${LeagueData.getIndices(_player!.prevLeagueId).$1}",
                  width: 160.d)),
          Positioned(
              top: 260.d,
              left: 40.d,
              child: _indicator(
                  "prev_league_rank".l(), "${_player!.prevLeagueRank}",
                  icon: "icon_rank")),
          Positioned(
              top: 60.d,
              left: 320.d,
              child: Widgets.divider(direction: Axis.vertical, height: 260.d)),
          Positioned(
              top: 50.d,
              left: 400.d,
              child: Asset.load<Image>(
                  "icon_league_${LeagueData.getIndices(_player!.leagueId).$1}",
                  width: 160.d)),
          Positioned(
              top: 260.d,
              left: 370.d,
              child: _indicator("league_rank".l(), "${_player!.leagueRank}",
                  icon: "icon_rank")),
          Positioned(
              top: 120.d,
              left: 630.d,
              child: _indicator("battles_count".l(), "$battles",
                  icon: "icon_attacks")),
          Positioned(
              top: 260.d,
              left: 630.d,
              child: _indicator(
                  "battles_win_rate".l(), "${(battleRate * 100).round()}%",
                  icon: "icon_attacks")),
        ]));
  }

  _achievementSegment() {
    var achievements =
        accountBloc.account!.loadingData.achievements.values.toList();
    return ListView.builder(
        itemCount: achievements.length,
        itemBuilder: (c, i) =>
            _achievementsItemBuilder(accountBloc.account!, achievements[i]));
  }

  Widget _achievementsItemBuilder(Account account, AchievementLine line) {
    var title = "";
    if (line.steps.last.max > line.getAccountValue(account)) {
      title =
          "   ( ${line.countFormat(line.getAccountValue(account))} / ${line.countFormat(line.currentStep.max)} )";
    }
    return ValueListenableBuilder(
        valueListenable: line.selectedIndex,
        builder: (context, value, child) {
          return Widgets.rect(
              margin: EdgeInsets.only(top: 60.d),
              decoration: Widgets.imageDecore(
                  "frame_header_cheese",
                  ImageCenterSliceData(
                      114, 226, const Rect.fromLTWH(58, 61, 2, 2))),
              height: 386.d,
              child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                Positioned(
                        top: -25.d,
                    left: 80.d,
                        child: SkinnedText(
                            "${"achievement_${line.type.id}_title".l()} $title")),
                Positioned(
                        bottom: 25.d,
                    child: Text("achievement_${line.type.id}_message"
                        .l([line.format(line.steps[value].max)]))),
                Positioned(
                        top: 40.d,
                        width: line.steps.length == 1 ? 230.d : null,
                        left: line.steps.length > 1 ? 40.d : null,
                        right: line.steps.length > 1 ? 40.d : null,
                        height: 260.d,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: line.steps.length,
                        itemBuilder: (c, i) =>
                            _achievementItemBuilder(account, line, i)))
              ]));
        });
  }

  Widget _achievementItemBuilder(
      Account account, AchievementLine line, int index) {
    var state = line.getAccountValue(account);
    var isSelected = line.selectedIndex.value == index;
    var achieved = state >= line.steps[index].max;
    var isCurrent = state >= line.steps[index].min &&
        (state < line.steps[index].max || index == line.steps.length - 1);
    var ratio = 0.0;
    if (isCurrent) {
      ratio = ((state - line.steps[index].min) /
              (line.steps[index].max - line.steps[index].min))
          .clamp(0, 1);
    }
    return Widgets.button(
        width: 183.d,
        margin: EdgeInsets.fromLTRB(16.d, 18.d, 16.d, 12.d),
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Opacity(
                  opacity: isSelected ? 1 : 0.4,
                  child: Widgets.rect(
                      decoration: Widgets.imageDecore(
                          "frame_hatch", ImageCenterSliceData(80, 100)))),
              Opacity(
      opacity: isSelected ? 1 : 0.7,
                  child: state >= line.steps[index].min
                      ? Align(
                          alignment: const Alignment(0, -0.5),
                          child: Asset.load<Image>(
                              "achievement_${line.type.id}_${index + 1}",
                              height: 128.d))
                      : SkinnedText("?", style: TStyles.large)),
              achieved
                  ? Positioned(
                      top: -20.d,
                      right: -10.d,
                      child: Asset.load<Image>("tick", width: 40.d))
                  : const SizedBox(),
              isCurrent && !achieved
                  ? Positioned(
                      top: -20.d,
                      right: -15.d,
                      child: SkinnedText("${(ratio * 100).floor()}%"))
                  : const SizedBox(),
              isCurrent
                ? Positioned(
                      bottom: 45.d,
                      child: Widgets.slider(0, ratio, 1,
                          height: 18.d, width: 122.d, padding: 5.d))
                  : const SizedBox(),
  }
}
