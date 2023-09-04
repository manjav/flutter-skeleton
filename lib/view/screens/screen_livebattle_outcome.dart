import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/core/card.dart';
import '../../data/core/ranking.dart';
import '../../services/connection/noob_socket.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/widgets.dart';
import '../../view/widgets/skinnedtext.dart';
import '../route_provider.dart';
import '../widgets/loaderwidget.dart';
import 'iscreen.dart';

class LiveOutScreen extends AbstractScreen {
  LiveOutScreen({required super.args, super.key}) : super(Routes.livebattleOut);
  @override
  createState() => _LiveOutScreenState();
}

class _LiveOutScreenState extends AbstractScreenState<LiveOutScreen> {
  // late AnimationController _animationController;
  late NoobFineMessage _result;

  @override
  List<Widget> appBarElementsLeft() => [];
  @override
  List<Widget> appBarElementsRight() => [];

  @override
  void initState() {
    _result = widget.args["result"] as NoobFineMessage;
    // _animationController = AnimationController(
    //     vsync: this, upperBound: 3, duration: const Duration(seconds: 2));
    // _animationController.forward();

    super.initState();
  }

  @override
  Widget contentFactory() {
    var color = _result.alliseOwner.won ? "green" : "red";
    return Widgets.button(
        padding: EdgeInsets.all(32.d),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _fractionBuilder(_result.axisOwner, _result.axis),
              SizedBox(height: 40.d),
              _vsBuilder(),
              SizedBox(height: 40.d),
              _fractionBuilder(_result.alliseOwner, _result.allies),
              Widgets.rect(
                  margin: EdgeInsets.all(44.d),
                  height: 130.d,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: Asset.load<Image>("ui_ribbon_$color").image)),
                  child: SkinnedText("fight_lebel_$color".l()))
            ]),
        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst));
  }

  Widget _vsBuilder() {
    var sliceData =
        ImageCenterSliceDate(86, 10, const Rect.fromLTWH(8, 2, 70, 2));
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
              child: Asset.load<Image>("liveout_vs_line",
                  centerSlice: sliceData, height: 12.d)),
          Asset.load<Image>("liveout_vs", height: 40.d),
          Expanded(
              child: Asset.load<Image>("liveout_vs_line",
                  centerSlice: sliceData, height: 12.d)),
        ]);
  }

  Widget _fractionBuilder(OpponentResult opponent, List<OpponentResult> team) {
    var sliceData = ImageCenterSliceDate(201, 158);
    return Widgets.rect(
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(80.d, 90.d, 80.d, 60.d),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: Asset.load<Image>("liveout_bg_${opponent.fraction.name}",
                        centerSlice: sliceData)
                    .image,
                centerSlice: sliceData.centerSlice)),
        height: 680.d,
        child: team.isEmpty
            ? _ownerBuilder(opponent, isExpanded: true)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ownerBuilder(opponent, isExpanded: true),
                  SizedBox(width: 20.d),
                  _helpersBuilder(team),
                ],
              ));
  }

  Widget _helpersBuilder(List<OpponentResult> team) {
    return Expanded(
        child: GridView.builder(
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 0.5,
        crossAxisCount: 3,
      ),
      itemCount: team.length,
      itemBuilder: (context, index) => _ownerBuilder(team[index]),
    ));
  }

  Widget _ownerBuilder(OpponentResult opponent, {bool isExpanded = false}) {
    var sliceData =
        ImageCenterSliceDate(68, 92, const Rect.fromLTWH(32, 34, 4, 4));
    var items = <Widget>[_titleBuilder(opponent)];
    if (isExpanded) {
      items.addAll([
        SizedBox(height: 10.d),
        _rewardItemBuilder("icon_seed", opponent.score, "power", opponent),
        _rewardItemBuilder("icon_gold", opponent.gold, "gold", opponent),
        _rewardItemBuilder("icon_xp", opponent.xp, "cooldown", opponent)
      ]);
    }
    items.addAll([
      const Expanded(child: SizedBox()),
      SkinnedText(opponent.name),
    ]);
    return Widgets.rect(
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(24.d, 12.d, 24.d, 0),
        decoration: BoxDecoration(
            image: DecorationImage(
                image:
                    Asset.load<Image>("liveout_frame", centerSlice: sliceData)
                        .image,
                centerSlice: sliceData.centerSlice)),
        width: 400.d,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, children: items));
  }

  _titleBuilder(OpponentResult opponent) {
    return SizedBox(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
      Widgets.rect(
          radius: 24.d,
          padding: EdgeInsets.all(6.d),
          color: TColors.black.withOpacity(0.3),
          child: LoaderWidget(AssetType.image, "avatar_${Random().nextInt(10)}",
              width: 92.d, height: 92.d, subFolder: "avatars")),
      SizedBox(width: 12.d),
      Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _usedCards(opponent),
            SkinnedText("ˢ${opponent.power.compact()}", style: TStyles.small)
          ])
    ]));
  }

  Widget _usedCards(OpponentResult opponent) {
    var slots = _result.slots[opponent.id]!.value;
    return SizedBox(
        width: 128.d,
        height: 56.d,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _usedCard(opponent.fraction, slots[0], -0.15, 0, 2.d),
            _usedCard(opponent.fraction, slots[1], -0.05, 16.d, 0),
            _usedCard(opponent.fraction, slots[4], 0.05, 37.d, 0),
            _usedCard(opponent.fraction, slots[2], 0.15, 60.d, 1.d),
            _usedCard(opponent.fraction, slots[3], 0.25, 86.d, 5.d),
          ],
        ));
  }

  Widget _usedCard(OpponentSide fraction, AccountCard? card, double angle,
      double left, double top) {
    return Positioned(
        top: top,
        left: left,
        width: 36.d,
        child: Transform.rotate(
            angle: angle,
            child: Asset.load<Image>(
                "liveout_card_${card == null ? "missed" : fraction.name}")));
  }

  Widget _rewardItemBuilder(
      String icon, int value, String benefit, OpponentResult opponent) {
    space(s) => SizedBox(width: s);
    format(int v) => benefit == "cooldown" ? v.toRemainingTime() : v.compact();

    return Row(mainAxisSize: MainAxisSize.min, children: [
      Asset.load<Image>(icon, width: 70.d, height: 78.d),
      space(10.d),
      SkinnedText(value.compact(), style: TStyles.small),
      const Expanded(child: SizedBox()),
      SkinnedText(format(opponent.heroBenefits[benefit]!),
          style: TStyles.small.copyWith(color: TColors.orange)),
      space(10.d),
      Asset.load<Image>("benefit_$benefit", width: 56.d)
    ]);
  }
}