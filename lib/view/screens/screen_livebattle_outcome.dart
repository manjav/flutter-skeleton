import 'package:flutter/material.dart';

import '../../data/core/adam.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/sounds.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/widgets.dart';
import '../../view/widgets/live_battle/live_opponent.dart';
import '../../view/widgets/skinnedtext.dart';
import '../route_provider.dart';
import 'iscreen.dart';

class LiveOutScreen extends AbstractScreen {
  LiveOutScreen({required super.args, super.key}) : super(Routes.livebattleOut);
  @override
  createState() => _LiveOutScreenState();
}

class _LiveOutScreenState extends AbstractScreenState<LiveOutScreen> {
  // late AnimationController _animationController;
  late LiveOpponent _alliseOwner, _axisOwner;
  final List<LiveOpponent> _allise = [], _axis = [];

  @override
  List<Widget> appBarElementsLeft() => [];
  @override
  List<Widget> appBarElementsRight() => [];

  @override
  void initState() {
    getService<Sounds>().play("won");
    var opponents = widget.args["opponents"] as List<LiveOpponent>;
    for (var opponent in opponents) {
      if (opponent.teamOwnerId == widget.args["alliseId"]) {
        if (opponent.id == widget.args["alliseId"]) {
          _alliseOwner = opponent;
        } else {
          _allise.add(opponent);
        }
      } else {
        if (opponent.id == widget.args["axisId"]) {
          _axisOwner = opponent;
        } else {
          _axis.add(opponent);
        }
      }
    }

    // _animationController = AnimationController(
    //     vsync: this, upperBound: 3, duration: const Duration(seconds: 2));
    // _animationController.forward();

    super.initState();
  }

  @override
  Widget contentFactory() {
    var color = _alliseOwner.won ? "green" : "red";
    getService<Sounds>().play(_alliseOwner.won ? "won" : "lose");
    return Widgets.button(
        padding: EdgeInsets.all(32.d),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _fractionBuilder(_axisOwner, _axis),
              SizedBox(height: 40.d),
              _vsBuilder(),
              SizedBox(height: 40.d),
              _fractionBuilder(_alliseOwner, _allise),
              Widgets.rect(
                  margin: EdgeInsets.all(44.d),
                  height: 130.d,
                  decoration: Widgets.imageDecore("ui_ribbon_$color"),
                  child: SkinnedText("fight_lebel_$color".l()))
            ]),
        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst));
  }

  Widget _vsBuilder() {
    var sliceData =
        ImageCenterSliceData(86, 10, const Rect.fromLTWH(8, 2, 70, 2));
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

  Widget _fractionBuilder(LiveOpponent opponent, List<LiveOpponent> team) {
    return Widgets.rect(
        padding: EdgeInsets.fromLTRB(80.d, 90.d, 80.d, 60.d),
        decoration: Widgets.imageDecore("liveout_bg_${opponent.fraction.name}",
            ImageCenterSliceData(201, 158)),
        height: 580.d,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            team.isEmpty
                ? LiveOpponentView(opponent, isExpanded: true)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LiveOpponentView(opponent, isExpanded: true),
                      SizedBox(width: 20.d),
                      _helpersBuilder(team),
                    ],
                  ),
            _headerBuilder(opponent),
          ],
        ));
  }

  Widget _headerBuilder(LiveOpponent opponent) {
    return Positioned(
        top: -80.d,
        height: 70.d,
        child: Widgets.rect(
            padding: EdgeInsets.fromLTRB(64.d, 0, 64.d, 12.d),
            decoration: Widgets.imageDecore(
                "liveout_bg_header", ImageCenterSliceData(64, 59)),
            child: SkinnedText(opponent.tribeName,
                style: TStyles.medium.copyWith(height: 1))));
  }

  Widget _helpersBuilder(List<LiveOpponent> team) {
    return Expanded(
        child: GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 42.d),
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 0.65, crossAxisCount: 2),
      itemCount: team.length,
      itemBuilder: (context, index) => LiveOpponentView(team[index]),
    ));
  }
}
