import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/building.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/indicator_level.dart';
import '../widgets/loaderwidget.dart';
import '../widgets/skinnedtext.dart';
import 'iscreen.dart';

enum FightMode { quest, battle }

class FightOutcomeScreen extends AbstractScreen {
  final Map<String, dynamic> result;
  FightOutcomeScreen(super.mode, this.result, {super.key});
  @override
  createState() => _FightOutcomeScreenState();
}

class _FightOutcomeScreenState extends AbstractScreenState<FightOutcomeScreen> {
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

    _account = BlocProvider.of<AccountBloc>(context).account!;
    _isWin = widget.result['outcome'];
    _color = _isWin ? "green" : "red";
    if (widget.result["attacker_hero_benefits_info"].length > 0) {
      var benefits = widget.result["attacker_hero_benefits_info"];
      var map = <String, int>{
        "benefit_gold": benefits['gold_benefit'] ?? 0,
        "benefit_power": benefits['power_benefit'] ?? 0,
        "benefit_cooldown": benefits['cooldown_benefit'] ?? 0
      };
      _heroBenefits = map.entries.toList();
    }
    _prizes = [
      MapEntry("gold", widget.result['gold_added'] ?? 0),
      MapEntry("xp", widget.result['xp_added'] ?? 0),
    ];
    if (widget.type == Routes.battleOutcome) {
      _prizes.add(MapEntry("league_bonus", widget.result['league_bonus'] ?? 0));
      _prizes.add(MapEntry("seed", widget.result['seed_added'] ?? 0));
    }
    super.initState();
  }

  @override
  Widget contentFactory() {
    return Stack(alignment: Alignment.center, children: [
      _isWin
          ? Positioned(
              top: 20.d,
              width: 780.d,
              height: 780.d,
              child: LoaderWidget(AssetType.animation, "outcome_crown",
                  onRiveInit: (Artboard artboard) {
                final controller =
                    StateMachineController.fromArtboard(artboard, 'Crown');
                // _closeInput = controller!.findInput<bool>('close') as SMIBool;
                artboard.addController(controller!);
              }))
          : const SizedBox(),
      AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => Widgets.rect(
              height: DeviceInfo.size.width,
              alignment: Alignment.center,
              child: Stack(alignment: Alignment.center, children: [
                Positioned(
                    top: 32.d,
                    width: 622.d,
                    height: 114.d,
                    child: Opacity(
                        opacity: (_animationController.value / 2).clamp(0, 1),
                        child: Widgets.rect(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image:
                                        Asset.load<Image>("ui_ribbon_$_color")
                                            .image)),
                            child: SkinnedText("fight_lebel_$_color".l())))),
                Positioned(
                    bottom: -180.d,
                    width: 1050.d,
                    height: 980.d,
                    child: LoaderWidget(
                        AssetType.animation, "outcome_panel_$_color",
                        onRiveInit: (Artboard artboard) {
                      artboard.addController(
                          StateMachineController.fromArtboard(
                              artboard, 'Panel')!);
                    }, fit: BoxFit.fitWidth)),
                Positioned(
                    bottom: 660.d,
                    height: 240.d,
                    width: 800.d,
                    child: _outResults()),
                Positioned(
                    height: 322.d,
                    right: 60.d,
                    left: 180.d,
                    bottom: 180.d,
                    child: _prizeList()),
                Positioned(
                    height: 322.d,
                    width: 720.d,
                    bottom: 12.d,
                    child: Opacity(
                        opacity: (_animationController.value - 1.9).clamp(0, 1),
                        child: SkinnedText("card_available".l()))),
                Positioned(
                    height: 322.d,
                    width: 720.d,
                    bottom: -42.d,
                    child: Opacity(
                        opacity: (_animationController.value - 2).clamp(0, 1),
                        child: SkinnedText("${_account.getReadyCards().length}",
                            style: TStyles.large))),
              ]))),
      Positioned(
          height: 180.d,
          bottom: 240.d,
          child: Row(children: [
            Widgets.skinnedButton(
                padding: EdgeInsets.fromLTRB(48.d, 48.d, 48.d, 60.d),
                child: Asset.load<Image>("ui_arrow_back"),
                width: 160.d,
                color: ButtonColor.green,
                onPressed: () => Navigator.pop(context)),
            SizedBox(width: 20.d),
            Widgets.skinnedButton(
                padding: EdgeInsets.fromLTRB(32.d, 32.d, 48.d, 48.d),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const LoaderWidget(AssetType.image, "icon_battle"),
                    SizedBox(width: 32.d),
                    SkinnedText("battle_more".l(), style: TStyles.large),
                  ],
                ),
                onPressed: () {
                  if (widget.type == Routes.battleOutcome) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(
                        context, Routes.deck.routeName);
                  }
                })
          ]))
    ]);
  }

  _outResults() {
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
              SkinnedText(_account.get<String>(AccountField.name)),
              SkinnedText(_account
                  .getBuilding(Buildings.tribe)!
                  .get<String>(BuildingField.name)),
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

  _prizeList() {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: 130.d,
        ),
        itemCount: _prizes.length,
        itemBuilder: (c, i) =>
            _prizeItemBuilder(_prizes[i].key, _prizes[i].value));
  }

  Widget? _prizeItemBuilder(String type, int value) {
    return Opacity(
        opacity: (_animationController.value - 1.2).clamp(0, 1),
        child: Row(children: [
          Widgets.rect(
              width: 100.d,
              height: 130.d,
              padding: EdgeInsets.all(16.d),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: Asset.load<Image>("ui_prize_frame").image)),
              child: Asset.load<Image>("icon_$type")),
          SkinnedText(" ${value > 0 ? '+' : ''}${value.compact()}")
        ]));
  }

  Widget? _benefitItemBuilder(String type, dynamic value) {
    return SizedBox(
        height: 76.d,
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Asset.load<Image>(type, height: 62.d),
          SkinnedText("  ${value > 0 ? '+' : ''}$value")
        ]));
  }
}
