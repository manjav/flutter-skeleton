import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../services/deviceinfo.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/widgets/loaderwidget.dart';
import '../route_provider.dart';
import 'iscreen.dart';

class QuestScreen extends AbstractScreen {
  QuestScreen({required super.args, super.key}) : super(Routes.quest);

  @override
  createState() => _QuestScreenState();
}

class _QuestScreenState extends AbstractScreenState<QuestScreen> {
  List<ValueNotifier<List<Offset>>> _lands = [];
  int _questsCount = 0;

  @override
  void initState() {
    _lands = List.generate(4, (index) => ValueNotifier([]));
    super.initState();
  }

  @override
  Widget contentFactory() {
    super.contentFactory();
    _questsCount = accountBloc.account!.questsCount;
    return SizedBox(
        width: DeviceInfo.size.width,
        height: DeviceInfo.size.height,
        child: ListView.builder(
            reverse: true,
            itemCount: _lands.length,
            itemBuilder: _mapItemRenderer));
  }

  Widget _mapItemRenderer(BuildContext context, int mapIndex) {
    return SizedBox(
        width: DeviceInfo.size.width,
        height: DeviceInfo.size.height,
        child: Stack(alignment: Alignment.center, children: [
          LoaderWidget(AssetType.animation, "quest_map_${mapIndex.max(0)}",
        ]));
  }

