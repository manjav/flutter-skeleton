import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../app_export.dart';

enum FightMode { quest, battle }

class AttackOutcomeFeastOverlay extends AbstractOverlay {
  final Map<String, dynamic> args;
  final String type;

  const AttackOutcomeFeastOverlay(
      {required this.args,required this.type, super.onClose, super.key})
      : super(route: OverlaysName.feastAttackOutcome);

  @override
  createState() => _AttackOutcomeStateFeastOverlay();
}

class _AttackOutcomeStateFeastOverlay
    extends AbstractOverlayState<AttackOutcomeFeastOverlay>
    with RewardScreenMixin, BackgroundMixin, TickerProviderStateMixin {
  bool _isWin = false;
  String _color = "green";

  List<MapEntry<String, int>> _prizes = [];
  // List<MapEntry<String, int>> _heroBenefits = [];
  late Account _account;
  late Opponent _opponent;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, upperBound: 3, duration: const Duration(seconds: 2));

    _account = accountProvider.account;
    _isWin = widget.args['outcome'];
    waitingSFX = _isWin ? "won" : "lose";
    _opponent = widget.args['opponent'];
    _color = _isWin ? "green" : "red";

    if (widget.args.containsKey("attacker_hero_benefits_info") &&
        widget.args["attacker_hero_benefits_info"].length > 0) {
      // var benefits = widget.args["attacker_hero_benefits_info"];
      // var map = <String, int>{
      //   "benefit_gold": benefits['gold_benefit'] ?? 0,
      //   "benefit_power": benefits['power_benefit'] ?? 0,
      //   "benefit_cooldown": benefits['cooldown_benefit'] ?? 0
      // };
      // _heroBenefits = map.entries.toList();
    }
    _prizes = [
      MapEntry("gold", widget.args['gold_added'] ?? 0),
      MapEntry("xp", widget.args['xp_added'] ?? 0),
    ];
    if (widget.type == Routes.battleOut) {
      _prizes.add(MapEntry("league_bonus", widget.args['league_bonus'] ?? 0));
      _prizes.add(MapEntry("seed", widget.args['seed_added'] ?? 0));
    }

    children = [
      // Container(
      //   color: TColors.transparent,
      // ),
      animationBuilder("outcome"),
      Material(
        color: TColors.transparent,
        child: _body(),
      ),
    ];

    super.initState();

    process(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      _animationController.forward();
      return true;
    });
  }

  Widget _body() {
    return Widgets.rect(
      height: 900.d,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Positioned(top: -430.d, child: _ribbonTopBuilder()),
              Align(
                  alignment: const Alignment(0, 0.5),
                  child: _prizeList(700.d)),
              Positioned(
                  height: 100.d,
                  width: 720.d,
                  bottom: 0.d,
                  child: Opacity(
                      opacity: (_animationController.value - 1.9).clamp(0, 1),
                      child: SkinnedText("card_available".l()))),
              Positioned(
                  height: 100.d,
                  width: 720.d,
                  bottom: -50.d,
                  child: Opacity(
                      opacity: (_animationController.value - 2).clamp(0, 1),
                      child: SkinnedText("${_account.getReadyCards().length}",
                          style: TStyles.large))),
            ]),
      ),
    );
    // return Stack(alignment: Alignment(0, _isWin ? 0.5 : 0.2), children: [
    //   Stack(
    //     children: [

    //     ],
    //   ),
    // ]);
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);

    controller.findInput<double>("cardsUsedOpponent")?.value =
        widget.args["opponent_cards"].length.toDouble();
    controller.findInput<double>("cardsUsedPlayer")?.value =
        widget.args["attack_cards"].length.toDouble();
    controller.findInput<double>("xp")?.value = widget.args['xp'].toDouble();
    controller.findInput<double>("xpNew ")?.value =
        widget.args['xp_added'].toDouble();

    updateRiveText("titleText", "fight_label_$_color".l());
    updateRiveText("titleText_stroke", "fight_label_$_color".l());
    updateRiveText("titleText_shadow", "fight_label_$_color".l());

    updateRiveText("playerLevelText", _account.level.toString());
    updateRiveText("playerLevelText_stroke", _account.level.toString());
    updateRiveText("playerLevelText_shadow", _account.level.toString());

    updateRiveText("playerNameText", _account.name);
    updateRiveText("playerNameText_stroke", _account.name);
    updateRiveText("playerNameText_shadow", _account.name);

    updateRiveText("playerXpText", _account.xp.toString());
    updateRiveText("playerXpText_stroke", _account.xp.toString());
    updateRiveText("playerXpText_shadow", _account.xp.toString());

    updateRiveText("playerTribeText", _account.tribeName);
    updateRiveText("playerTribeText_stroke", _account.tribeName);
    updateRiveText("playerTribeText_shadow", _account.tribeName);

    updateRiveText("opponentLevelText", _opponent.level.toString());
    updateRiveText("opponentLevelText_stroke", _opponent.level.toString());
    updateRiveText("opponentLevelText_shadow", _opponent.level.toString());

    updateRiveText("opponentNameText", _opponent.name);
    updateRiveText("opponentNameText_stroke", _opponent.name);
    updateRiveText("opponentNameText_shadow", _opponent.name);

    updateRiveText("opponentTribeText", _opponent.tribeName);
    updateRiveText("opponentTribeText_stroke", _opponent.tribeName);
    updateRiveText("opponentTribeText_shadow", _opponent.tribeName);

    artboard.addController(controller);
    return controller;
  }

  @override
  Future<bool> onRiveAssetLoad(
      FileAsset asset, Uint8List? embeddedBytes) async {
    if (asset is ImageAsset) {
      if (asset.name == "playerAvatar") {
        asset.image = await loadImage("avatar_${_account.avatarId}",
            subFolder: "avatars");
        return true;
      } else if (asset.name == "opponentAvatar") {
        asset.image = await loadImage("avatar_${_opponent.avatarId}",
            subFolder: "avatars");
        return true;
      }
    }
    return super.onRiveAssetLoad(asset, embeddedBytes);
  }

  @override
  void onRiveEvent(RiveEvent event) {
    super.onRiveEvent(event);
    if (state == RewardAnimationState.closing) {
      _animationController.animateBack(0,
          duration: const Duration(milliseconds: 500));
    }
  }

  @override
  void dismiss() {
    accountProvider.update(context, widget.args);
    _animationController.stop();
    super.dismiss();
  }

  Widget _prizeList(double width) {
    var crossAxisCount = 3.max(_prizes.length);
    return SizedBox(
        height: 300.d,
        width: 700.d,
        child: GridView.builder(
            padding: EdgeInsets.zero,
            // physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.7,
              crossAxisCount: crossAxisCount,
            ),
            itemCount: _prizes.length,
            itemBuilder: (c, i) =>
                _prizeItemBuilder(_prizes[i].key, _prizes[i].value)));
  }

  Widget? _prizeItemBuilder(String type, int value) {
    if (type == "league_bonus") {
      type = "league_${LeagueData.getIndices(_account.leagueId).$1}";
    }
    return Opacity(
        opacity: (_animationController.value - 1.2).clamp(0, 1),
        child: Row(children: [
          Widgets.rect(
              width: 100.d,
              height: 130.d,
              padding: EdgeInsets.all(16.d),
              decoration: Widgets.imageDecorator("ui_prize_frame"),
              child: Asset.load<Image>("icon_$type")),
          SkinnedText(" ${value > 0 ? '+' : ""}${value.compact()}")
        ]));
  }
}
