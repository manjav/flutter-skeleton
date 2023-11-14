import 'dart:math';

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
  int _questsCount = 0;
  List<ValueNotifier<List<City>>> _lands = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _questsCount = accountBloc.account!.questsCount - 1;
    _lands = List.generate(4, (index) => ValueNotifier([]));
    super.initState();
  }

  @override
  void onRender(Duration timeStamp) {
    super.onRender(timeStamp);
    _scrollController.jumpTo(_questsCount / 130 * DeviceInfo.size.height * 0.7 +
        Random().nextDouble() * DeviceInfo.size.height * 0.1);
  }

  @override
  Widget contentFactory() {
    super.contentFactory();
    return SizedBox(
        width: DeviceInfo.size.width,
        height: DeviceInfo.size.height,
        child: ListView.builder(
            reverse: true,
            itemCount: _lands.length,
            controller: _scrollController,
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
                (event) => _riveEventsListener(event, mapIndex));
            artboard.addController(controller!);
          }),
          ValueListenableBuilder<List<City>>(
              valueListenable: _lands[mapIndex],
              builder: (context, value, child) {
                return Stack(children: [
                  for (var i = 0; i < value.length; i++)
                    _cityRenderer(mapIndex, i, value[i])
                ]);
              }),
        ]));
  }

  void _riveEventsListener(RiveEvent event, int mapIndex) {
    WidgetsBinding.instance.addPostFrameCallback((d) async {
      if (event.name == "click") {
        await Navigator.pushNamed(context, Routes.deck.routeName);
        _questsCount = accountBloc.account!.questsCount - 1;
        // Update city levels after quest
        for (var i = 0; i < _lands[mapIndex].value.length; i++) {
          _lands[mapIndex].value[i].state?.value =
              (_questsCount - mapIndex * 130 - i * 10).toDouble();
        }
      } else if (event.name == "loading") {
        // Load city positions
        var positions = <City>[];
        var cities = event.properties["buttons"].split(",");
        for (var i = 0; i < cities.length; i++) {
          var offset = cities[i].split(":");
          positions.add(City(
              i, Offset(double.parse(offset[0]), double.parse(offset[1]))));
        }
        _lands[mapIndex].value = positions;
      }
    });
  }

  Widget _cityRenderer(int mapIndex, int index, City city) {
    var size = index == 12 ? 200.d : 170.d;
    return Positioned(
      left: city.position.dx.d - size * 0.5,
      top: city.position.dy.d - size * 0.5,
      child: LoaderWidget(AssetType.animation, "quest_map_button",
          width: size, height: size, onRiveInit: (Artboard artboard) {
        var controller =
            StateMachineController.fromArtboard(artboard, "Button");
        city.state = controller?.findInput<double>("state") as SMINumber;
        city.state?.value =
            (_questsCount - mapIndex * 130 - index * 10).toDouble();
        controller?.findInput<double>("level")?.value = (index + 1).toDouble();
        controller
            ?.addEventListener((event) => _riveEventsListener(event, mapIndex));
        artboard.addController(controller!);
      }),
    );
  }
}

class City {
  final int index;
  SMINumber? state;
  final Offset position;
  City(this.index, this.position);
}
