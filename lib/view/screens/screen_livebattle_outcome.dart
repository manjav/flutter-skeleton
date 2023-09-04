import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/core/card.dart';
import '../../services/connection/noob_socket.dart';
import '../../services/deviceinfo.dart';
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
  late NoobFineMessage _result;

  @override
  List<Widget> appBarElementsLeft() => [];
  @override
  List<Widget> appBarElementsRight() => [];

  @override
  void initState() {
    _result = widget.args["result"] as NoobFineMessage;
    super.initState();
  }

  @override
  Widget contentFactory() {
    return Padding(
      padding: EdgeInsets.all(32.d),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _fractionBuilder("axis", _result.axisOwner, _result.axis),
            SizedBox(height: 40.d),
            _vsBuilder(),
            SizedBox(height: 40.d),
          ]),
    );
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
  }
