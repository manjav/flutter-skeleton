import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../services/deviceinfo.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/widgets/loaderwidget.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/skinnedtext.dart';
import 'iscreen.dart';

class LevelupScreen extends AbstractScreen {
  LevelupScreen({required super.args, super.key}) : super(Routes.levelup);

  @override
  createState() => _LevelupScreenState();
}

class _LevelupScreenState extends AbstractScreenState<LevelupScreen> {
  @override
  List<Widget> appBarElementsLeft() => [];
  @override
  List<Widget> appBarElementsRight() => [];
  late AnimationController _animationController;
  int _gold = 0;

  @override
  void initState() {
    super.initState();
    _gold = widget.args["levelup_gold_added"] ?? 100;
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  Widget contentFactory() {
    return Widgets.button(
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        child: Stack(children: [
          _rewardsBuilder(),
        ]),
        onPressed: () {
          if (_animationController.isCompleted) {
            Navigator.pop(context);
          }
        });
  }

  Widget _rewardsBuilder() {
    return Align(
        alignment: const Alignment(0, 0.4),
        child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                  opacity: _animationController.value,
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.ltr,
                      children: [
                        Widgets.rect(
                            width: 100.d,
                            height: 130.d,
                            padding: EdgeInsets.all(16.d),
                            decoration: Widgets.imageDecore("ui_prize_frame"),
                            child: Asset.load<Image>("icon_gold")),
                        SizedBox(width: 12.d),
                        SkinnedText("+ ${_gold.compact()}",
                            textDirection: TextDirection.ltr),
                      ]));
            }));
  }

  @override
  void dispose() {
    _animationController.stop();
    super.dispose();
  }
}
