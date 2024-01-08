import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/adam.dart';
import '../../mixins/background_mixin.dart';
import '../../services/device_info.dart';
import '../../services/localization.dart';
import '../../services/sounds.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/indicator_level.dart';
import '../widgets/loader_widget.dart';
import '../widgets/skinned_text.dart';
import 'screen.dart';

enum FightMode { quest, battle }

class AttackOutScreen extends AbstractScreen {
  AttackOutScreen(super.mode,
      {required super.args, super.closable = false, super.key});
  @override
  createState() => _AttackOutScreenState();
}

class _AttackOutScreenState extends AbstractScreenState<AttackOutScreen>
    with BackgroundMixin {
  bool _isWin = false;
  String _color = "green";

  List<MapEntry<String, int>> _prizes = [];
  List<MapEntry<String, int>> _heroBenefits = [];
  late Account _account;
  late AnimationController _animationController;

  @override
  List<Widget> appBarElementsLeft() => [];
  @override
  List<Widget> appBarElementsRight() => [];

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, upperBound: 3, duration: const Duration(seconds: 2));
    _animationController.forward();

    _account = accountBloc.account!;
    _isWin = widget.args['outcome'];
    _color = _isWin ? "green" : "red";
    getService<Sounds>().play(_isWin ? "won" : "lose");
    if (widget.args.containsKey("attacker_hero_benefits_info") &&
        widget.args["attacker_hero_benefits_info"].length > 0) {
      var benefits = widget.args["attacker_hero_benefits_info"];
      var map = <String, int>{
        "benefit_gold": benefits['gold_benefit'] ?? 0,
        "benefit_power": benefits['power_benefit'] ?? 0,
        "benefit_cooldown": benefits['cooldown_benefit'] ?? 0
      };
      _heroBenefits = map.entries.toList();
    }
    _prizes = [
      MapEntry("gold", widget.args['gold_added'] ?? 0),
      MapEntry("xp", widget.args['xp_added'] ?? 0),
    ];
    if (widget.type == Routes.battleOut) {
      _prizes.add(MapEntry("league_bonus", widget.args['league_bonus'] ?? 0));
      _prizes.add(MapEntry("seed", widget.args['seed_added'] ?? 0));
    }
    super.initState();
  }

  @override
  Widget contentFactory() {
    return Widgets.touchable(
        child: Stack(alignment: Alignment(0, _isWin ? 0.5 : 0.2), children: [
          backgroundBuilder(animated: true, color: _isWin ? 4 : 2),
          _isWin
              ? Positioned(
                  top: 120.d,
                  width: 600.d,
                  height: 600.d,
                  child: LoaderWidget(AssetType.animation, "outcome_crown",
                      onRiveInit: (Artboard artboard) {
                    artboard.addController(StateMachineController.fromArtboard(
                        artboard, 'Crown')!);
                  }))
              : const SizedBox(),
          SizedBox(
              height: 700.d,
              child: Stack(children: [
                LoaderWidget(AssetType.animation, "outcome_panel",
                    onRiveInit: (Artboard artboard) {
                  var controller = StateMachineController.fromArtboard(
                      artboard, "State Machine 1")!;
                  controller.findInput<double>("color")?.value = _isWin ? 1 : 0;
                  artboard.addController(controller);
                }, fit: BoxFit.fitWidth),
                Widgets.rect(
                    child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(top: -360.d, child: _ribbonTopBuilder()),
                        Positioned(
                            top: -210.d,
                            width: 800.d,
                            child: _profileBuilder()),
                        Align(
                            alignment: const Alignment(0, -0.3),
                            child: _prizeList(700.d)),
                        Positioned(
                            height: 322.d,
                            width: 720.d,
                            bottom: 50.d,
                            child: Opacity(
                                opacity: (_animationController.value - 1.9)
                                    .clamp(0, 1),
                                child: SkinnedText("card_available".l()))),
                        Positioned(
                            height: 322.d,
                            width: 720.d,
                            bottom: 0,
                            child: Opacity(
                                opacity: (_animationController.value - 2)
                                    .clamp(0, 1),
                                child: SkinnedText(
                                    "${_account.getReadyCards().length}",
                                    style: TStyles.large))),
                      ]),
                ))
              ])),
        ]),
        onTap: _close);
  }

  void _close() {
    accountBloc.account!.update(context, widget.args);
    accountBloc.add(SetAccount(account: accountBloc.account!));
    var lastRoute =
        widget.type == Routes.questOut ? Routes.quest : Routes.popupOpponents;
    Navigator.popUntil(
        context, (route) => route.settings.name == lastRoute.routeName);
  }

  Widget _ribbonTopBuilder() {
    return Opacity(
        opacity: (_animationController.value / 2).clamp(0, 1),
        child: Widgets.rect(
            width: 622.d,
            height: 114.d,
            alignment: Alignment.center,
            decoration: Widgets.imageDecorator("ui_ribbon_$_color"),
            child: SkinnedText("fight_label_$_color".l())));
  }

  Widget _profileBuilder() {
    var hasBenefits = _isWin && _heroBenefits.isNotEmpty;
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LevelIndicator(size: 180.d),
          SizedBox(width: 12.d),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 36.d),
              SkinnedText(_account.name),
              _account.tribeId > 0
                  ? SkinnedText(_account.tribeName)
                  : const SizedBox(),
            ],
          ),
          hasBenefits ? const Expanded(child: SizedBox()) : const SizedBox(),
          hasBenefits
              ? SizedBox(
                  width: 260.d,
                  child: ListView.builder(
                      itemCount: _heroBenefits.length,
                      itemBuilder: (c, i) => _benefitItemBuilder(
                          _heroBenefits[i].key, _heroBenefits[i].value)))
              : const SizedBox()
        ]);
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

  Widget? _benefitItemBuilder(String type, int value) {
    return SizedBox(
        height: 76.d,
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Asset.load<Image>(type, height: 62.d),
          SkinnedText("  ${value > 0 ? '+' : ""}${value.compact()}")
        ]));
  }

  @override
  void dispose() {
    _animationController.stop();
    super.dispose();
  }
}
