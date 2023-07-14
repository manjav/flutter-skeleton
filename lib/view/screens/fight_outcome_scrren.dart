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
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/level_indicator.dart';
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
  late Account _account;

  @override
  List<Widget> appBarElementsLeft() => [];
  @override
  List<Widget> appBarElementsRight() => [];

  @override
  void initState() {
    _account = BlocProvider.of<AccountBloc>(context).account!;
    _isWin = widget.result['outcome'];
    _color = _isWin ? "green" : "red";
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
      Widgets.rect(
          height: DeviceInfo.size.width,
          alignment: Alignment.center,
          child: Stack(alignment: Alignment.center, children: [
            Positioned(
                top: 0.d,
                width: 622.d,
                height: 114.d,
                child: Widgets.rect(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image:
                                Asset.load<Image>("ui_ribbon_$_color").image)),
                    child: SkinnedText("fight_lebel_$_color".l()))),
            Positioned(
                bottom: -180.d,
                width: 1050.d,
                height: 980.d,
                child:
                    LoaderWidget(AssetType.animation, "outcome_panel_$_color",
                        onRiveInit: (Artboard artboard) {
                  final controller =
                      StateMachineController.fromArtboard(artboard, 'Panel');
                  artboard.addController(controller!);
                }, fit: BoxFit.fitWidth)),
            Positioned(
                top: 140.d, height: 240.d, width: 800.d, child: _outResults()),
            Positioned(
                height: 322.d,
                width: 720.d,
                bottom: 180.d,
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisExtent: 130.d,
                      // childAspectRatio: 3,
                      crossAxisCount: 3,
                    ),
                    itemCount: _prizes.length,
                    itemBuilder: (c, i) =>
                        _prizeItemBuilder(_prizes[i].key, _prizes[i].value))),
          ])),
      Positioned(
          height: 180.d,
          bottom: 240.d,
          child: Row(children: [
            Widgets.labeledButton(
                child: Asset.load<Image>("ui_back"),
                width: 160.d,
                color: "green",
                onPressed: () => Navigator.pop(context)),
            SizedBox(width: 20.d),
            Widgets.labeledButton(
                padding: EdgeInsets.fromLTRB(32.d, 32.d, 48.d, 48.d),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const LoaderWidget(AssetType.image, "icon_battle"),
                    SizedBox(width: 32.d),
                    SkinnedText("battle_more".l(), style: TStyles.large),
                  ],
                ),
                onPressed: () => print("dfdsf"))
          ]))
    ]);
  }

  _outResults() {
    if (!_isWin) return const SizedBox();
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(
          width: 160.d, height: 160.d, child: LevelIndicator(key: GlobalKey())),
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
      const Expanded(child: SizedBox()),
      SizedBox(
          width: 260.d,
          child: ListView.builder(
              itemCount: 3, itemBuilder: (c, i) => _heroItemBuilder("", 12)))
    ]);
  }

  Widget? _prizeItemBuilder(String type, int value) {
    return Row(children: [
      Widgets.rect(
          width: 100.d,
          height: 130.d,
          padding: EdgeInsets.all(16.d),
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: Asset.load<Image>("ui_prize_frame").image)),
          child: Asset.load<Image>("ui_xp")),
      SizedBox(width: 16.d),
      SkinnedText(value.toString())
    ]);
  }

  Widget? _heroItemBuilder(String type, int value) {
    return SizedBox(
        height: 76.d,
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Asset.load<Image>("ui_xp"),
          SizedBox(width: 8.d),
          SkinnedText(value.toString())
        ]));
  }
}
