import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/service_provider.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/widgets/loaderwidget.dart';
import '../../view/widgets/skinnedtext.dart';
import '../route_provider.dart';
import 'iscreen.dart';

class QuestScreen extends AbstractScreen {
  QuestScreen({required super.args, super.key}) : super(Routes.quest);

  @override
  createState() => _QuestScreenState();
}

class _QuestScreenState extends AbstractScreenState<QuestScreen> {
  final int _padding = 10;
  int _questsCount = 0;
  int _firstArena = 0, _lastArena = 0;
  bool _waitingMode = true;
  late ScrollController _scrollController;
  List<ValueNotifier<List<City>>> _arenas = [];

  double _mapHeight = 0;

  @override
  void initState() {
    _questsCount = accountBloc.account!.questsCount - 1;
    _mapHeight = DeviceInfo.size.width * 2.105;
    var arenaIndex = (_questsCount / 130).floor();
    var location = _questsCount % 130;
    _firstArena = (arenaIndex - _padding).min(0);
    _lastArena = arenaIndex + _padding;
    _arenas = List.generate(4, (index) => ValueNotifier([]));
    _scrollController = ScrollController(
        keepScrollOffset: false,
        initialScrollOffset:
            (arenaIndex - _firstArena - 0.1 - Random().nextDouble() * 0.6) *
                    _mapHeight +
                location * 20.d);

    super.initState();
  }

  @override
  void onRender(Duration timeStamp) => _waitingMode = false;

  @override
  Widget contentFactory() {
    return ListView.builder(
        reverse: true,
        itemExtent: _mapHeight,
        itemCount: _lastArena - _firstArena,
        controller: _scrollController,
        itemBuilder: (context, index) => _mapItemRenderer(index + _firstArena));
  }

  Widget _mapItemRenderer(int index) =>
      ArenaItemRenderer(index, _getArena(index), _questsCount, _waitingMode);

  ValueNotifier<List<City>> _getArena(int index) {
    return _arenas[index >= _arenas.length ? _arenas.length - 1 : index];
  }
}

class ArenaItemRenderer extends StatefulWidget {
  final int index;
  final int questsCount;
  final bool waitingMode;
  final ValueNotifier<List<City>> arena;
  const ArenaItemRenderer(
      this.index, this.arena, this.questsCount, this.waitingMode,
      {super.key});

  @override
  State<ArenaItemRenderer> createState() => _ArenaItemRendererState();
}

class _ArenaItemRendererState extends State<ArenaItemRenderer>
    with ServiceProviderMixin {
  int _questsCount = 0;
  bool _waitingMode = true;
  @override
  void initState() {
    super.initState();
    _questsCount = widget.questsCount;
    if (widget.waitingMode) {
      WidgetsBinding.instance.addPostFrameCallback((d) {
        _waitingMode = false;
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      _waitingMode = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_waitingMode) return SizedBox(height: DeviceInfo.size.height);
    return SizedBox(
      width: DeviceInfo.size.width,
      child: Stack(alignment: Alignment.center, children: [
        LoaderWidget(AssetType.animation, "quest_map_0",
            onRiveInit: (Artboard artboard) {
          var controller = StateMachineController.fromArtboard(artboard, "Map");
          controller?.addEventListener((event) => _riveEventsListener(event));
          artboard.addController(controller!);
        }, fit: BoxFit.fitWidth),
        ValueListenableBuilder<List<City>>(
            valueListenable: widget.arena,
            builder: (context, value, child) {
              return Stack(children: [
                for (var i = 0; i < value.length; i++)
                  _cityRenderer(
                      value.length - i - 1, value[value.length - i - 1])
              ]);
            }),
        Positioned(
            top: 140.d,
            child: SkinnedText("arena_l".l([widget.index + 1]),
                style: TStyles.large)),
      ]),
    );
  }

  void _riveEventsListener(RiveEvent event) {
    WidgetsBinding.instance.addPostFrameCallback((d) async {
      if (event.name == "click") {
        await Navigator.pushNamed(context, Routes.deck.routeName);
        _questsCount = accountBloc.account!.questsCount - 1;
        // Update city levels after quest
        for (var i = 0; i < widget.arena.value.length; i++) {
          widget.arena.value[i].state?.value =
              (_questsCount - widget.index * 130 - i * 10).toDouble();
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
        widget.arena.value = positions;
      }
    });
  }

  Widget _cityRenderer(int index, City city) {
    var size = index == 12 ? 200.d : 170.d;
    return Positioned(
      left: city.position.dx.d - size * 0.5,
      top: city.position.dy.d - size * 0.5,
      child: LoaderWidget(AssetType.animation, "quest_map_button",
          width: size, height: size, onRiveInit: (Artboard artboard) {
        void setText(String name, String value) {
          artboard.component<TextValueRun>(name)?.text = value;
          artboard.component<TextValueRun>("${name}_stroke")?.text = value;
          artboard.component<TextValueRun>("${name}_shadow")?.text = value;
        }

        var controller =
            StateMachineController.fromArtboard(artboard, "State Machine 1");
        city.state = controller?.findInput<double>("state") as SMINumber;
        var state = (_questsCount - widget.index * 130 - index * 10).toDouble();
        city.state?.value = state;
        setText("levelText", "${index + 1}");
        controller?.addEventListener((event) => _riveEventsListener(event));
        if (widget.index < 390) {
          if (index == 1 ||
              index == 4 ||
              index == 7 ||
              index == 10 ||
              index == 12) {
            controller?.findInput<double>("bubble")?.value = state > 10 ? 2 : 1;
            controller?.findInput<double>("bubbleIndex")?.value =
                index == 12 ? 0 : 1;
          }
        }
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
