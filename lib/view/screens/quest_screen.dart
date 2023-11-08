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
              onRiveInit: (Artboard artboard) {
            var controller =
                StateMachineController.fromArtboard(artboard, "Map");
            controller?.addEventListener(
                (event) => _riveEventsListener(mapIndex, event));
            artboard.addController(controller!);
          }),
          ValueListenableBuilder<List<Offset>>(
              valueListenable: _lands[mapIndex],
              builder: (context, value, child) {
                return Stack(children: [
                  for (var i = 0; i < value.length; i++)
                    _buttonRenderer(mapIndex, i, value[i])
                ]);
              }),
        ]));
  }

  void _riveEventsListener(int mapIndex, RiveEvent event) {
    WidgetsBinding.instance.addPostFrameCallback((d) async {
      if (event.name == "click") {
        await Navigator.pushNamed(context, Routes.deck.routeName);
        _lands[mapIndex].value.clear();
        _lands[mapIndex].value = _lands[mapIndex].value;
      } else if (event.name == "loading") {
        var positions = <Offset>[];
        var buttons = event.properties["buttons"].split(",");
        for (var button in buttons) {
          var offset = button.split(":");
          positions
              .add(Offset(double.parse(offset[0]), double.parse(offset[1])));
        }
        _lands[mapIndex].value = positions;
      }
    });
  }

  Widget _buttonRenderer(int mapIndex, int index, Offset position) {
    var size = index == 12 ? 200.d : 170.d;
    return Positioned(
      left: position.dx.d - size * 0.5,
      top: position.dy.d - size * 0.5,
      child: LoaderWidget(AssetType.animation, "quest_map_button",
          width: size, height: size, onRiveInit: (Artboard artboard) {
        var controller =
            StateMachineController.fromArtboard(artboard, "Button");
        controller?.findInput<double>("state")?.value =
            (-mapIndex * 130 - index * 10 + _questsCount).toDouble();
        controller?.findInput<double>("level")?.value = (index + 1).toDouble();
        controller?.findInput<bool>("button")?.value = false;
        controller
            ?.addEventListener((event) => _riveEventsListener(mapIndex, event));
        artboard.addController(controller!);
      }),
    );
  }
}
