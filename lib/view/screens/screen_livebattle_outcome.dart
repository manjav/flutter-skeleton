import 'package:flutter/material.dart';

import '../../data/core/adam.dart';
import '../../mixins/background_mixin.dart';
import '../../services/device_info.dart';
import '../../services/localization.dart';
import '../../services/sounds.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/widgets.dart';
import '../route_provider.dart';
import '../widgets/live_battle/live_warrior.dart';
import '../widgets/skinned_text.dart';
import 'screen.dart';

class LiveOutScreen extends AbstractScreen {
  LiveOutScreen({required super.args, super.key}) : super(Routes.livebattleOut);
  @override
  createState() => _LiveOutScreenState();
}

class _LiveOutScreenState extends AbstractScreenState<LiveOutScreen>
    with BackgroundMixin {
  // late AnimationController _animationController;
  late LiveWarrior _friendsHead, _oppositeHead;
  final List<LiveWarrior> _friends = [], _opposites = [];

  @override
  List<Widget> appBarElementsLeft() => [];
  @override
  List<Widget> appBarElementsRight() => [];

  @override
  void initState() {
    var warriors = widget.args["warriors"] as List<LiveWarrior>;
    for (var warrior in warriors) {
      if (warrior.teamOwnerId == widget.args["friendsId"]) {
        if (warrior.base.id == widget.args["friendsId"]) {
          _friendsHead = warrior;
        } else {
          _friends.add(warrior);
        }
      } else {
        if (warrior.base.id == widget.args["oppositesId"]) {
          _oppositeHead = warrior;
        } else {
          _opposites.add(warrior);
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
    getService<Sounds>().play(_friendsHead.won ? "won" : "lose");
    return Widgets.button(
        padding: EdgeInsets.all(32.d),
        child: Stack(alignment: Alignment.center, children: [
          backgroundBuilder(),
          _positioned(-740.d, _ribbon(_friendsHead.won ? "green" : "red")),
          _positioned(-500.d, _fractionBuilder(_oppositeHead, _opposites)),
          _positioned(180.d, _fractionBuilder(_friendsHead, _friends)),
          _positioned(100.d, _vsBuilder()),
        ]),
        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst));
  }

  Widget _positioned(double top, Widget child) => Positioned(
      width: DeviceInfo.size.width * 0.9,
      top: DeviceInfo.size.height * 0.5 + top,
      child: child);

  Widget _ribbon(String color) {
    return Widgets.rect(
        width: DeviceInfo.size.width,
        height: 130.d,
        margin: EdgeInsets.all(44.d),
        decoration: Widgets.imageDecorator("ui_ribbon_$color"),
        child: SkinnedText("fight_label_$color".l()));
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

  Widget _fractionBuilder(LiveWarrior opponent, List<LiveWarrior> team) {
    return Widgets.rect(
        padding: EdgeInsets.fromLTRB(80.d, 90.d, 80.d, 60.d),
        decoration: Widgets.imageDecorator(
            "liveout_bg_${opponent.side.name}", ImageCenterSliceData(201, 158)),
        height: 580.d,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            team.isEmpty
                ? LiveWarriorView(opponent, isExpanded: true)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LiveWarriorView(opponent, isExpanded: true),
                      SizedBox(width: 20.d),
                      _helpersBuilder(team),
                    ],
                  ),
            _headerBuilder(opponent),
          ],
        ));
  }

  Widget _headerBuilder(LiveWarrior opponent) {
    return Positioned(
        top: -80.d,
        height: 70.d,
        child: Widgets.rect(
            padding: EdgeInsets.fromLTRB(64.d, 0, 64.d, 12.d),
            decoration: Widgets.imageDecorator(
                "liveout_bg_header", ImageCenterSliceData(64, 59)),
            child: SkinnedText(opponent.tribeName,
                style: TStyles.medium.copyWith(height: 1))));
  }

  Widget _helpersBuilder(List<LiveWarrior> team) {
    return Expanded(
        child: GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 42.d),
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 0.65, crossAxisCount: 2),
      itemCount: team.length,
      itemBuilder: (context, index) => LiveWarriorView(team[index]),
    ));
  }
}
