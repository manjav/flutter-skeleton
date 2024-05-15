import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';

import '../../app_export.dart';

class QuestScreen extends AbstractScreen {
  QuestScreen({super.key}) : super(Routes.quest);

  @override
  createState() => _QuestScreenState();
}

class _QuestScreenState extends AbstractScreenState<QuestScreen> {
  final int _padding = 1;
  int _questsCount = 0;
  int _arenaIndex = 0, _firstArena = 0, _lastArena = 0;
  bool _waitingMode = true;
  late ScrollController _scrollController;
  List<RxList<City>> _arenas = [];

  double _mapHeight = 0;

  @override
  onTutorialFinish(data) {
    if (data["id"] == 300) {
      serviceLocator<RouteService>().to(Routes.deck);
    }
    super.onTutorialFinish(data);
  }

  @override
  void initState() {
    _questsCount = accountProvider.account.questsCount - 1;
    _mapHeight = DeviceInfo.size.width * 2.105;
    _arenaIndex = (_questsCount / 130).floor();
    var location = _questsCount % 130;
    _firstArena = (_arenaIndex - _padding).min(0);
    _lastArena = _arenaIndex + _padding + 1;
    _arenas = List.generate(4, (index) => <City>[].obs);
    _scrollController = ScrollController(
        keepScrollOffset: false,
        initialScrollOffset:
            (_arenaIndex - _firstArena - 0.1 - Random().nextDouble() * 0.6) *
                    _mapHeight +
                location * 20.d);
    _loadCityButton();
    super.initState();
  }

  _loadCityButton() async {
    await LoaderWidget.load(AssetType.animation, "quest_map_button");
    _waitingMode = false;
  }

  @override
  Widget contentFactory() {
    return Widgets.rect(
      color: const Color(0xFF04B2BB),
      child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          reverse: true,
          itemExtent: _mapHeight,
          itemCount: _lastArena - _firstArena,
          controller: _scrollController,
          itemBuilder: (context, index) =>
              _mapItemRenderer(index + _firstArena)),
    );
  }

  Widget _mapItemRenderer(int index) => ArenaItemRenderer(
      _arenaIndex, index, _getArena(index), _questsCount, _waitingMode);

  RxList<City> _getArena(int index) {
    return _arenas[index >= _arenas.length ? _arenas.length - 1 : index];
  }
}

class ArenaItemRenderer extends StatefulWidget {
  final int index;
  final int questsCount;
  final int currentIndex;
  final bool waitingMode;
  final RxList<City> arena;
  const ArenaItemRenderer(this.currentIndex, this.index, this.arena,
      this.questsCount, this.waitingMode,
      {super.key});

  @override
  State<ArenaItemRenderer> createState() => _ArenaItemRendererState();
}

class _ArenaItemRendererState extends State<ArenaItemRenderer>
    with ServiceFinderWidgetMixin, ClassFinderWidgetMixin {
  int _questsCount = 0;
  bool _waitingMode = true;
  SMIInput<double>? _boatPosition;
  SMINumber? _state;

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

    accountProvider.addListener(() {
      if (_state == null) return;
      if (_questsCount != accountProvider.account.questsCount - 1) {
        _questsCount = accountProvider.account.questsCount - 1;
        if (_state!.value >= 9) {
          widget.arena.refresh();
        } else {
          _state?.value++;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_waitingMode) return SizedBox(height: DeviceInfo.size.height);
    return SizedBox(
      width: DeviceInfo.size.width,
      child: Stack(alignment: Alignment.center, children: [
        LoaderWidget(AssetType.animation, "quest_map_${widget.index % 2}",
            onRiveInit: (Artboard artboard) {
          var controller = StateMachineController.fromArtboard(artboard, "Map");
          controller?.addEventListener((event) => _riveEventsListener(event));
          controller?.findInput<bool>("boatActive")?.value =
              widget.index == widget.currentIndex;
          _boatPosition = controller?.findInput<double>("boatPosition");
          artboard.addController(controller!);
        }, fit: BoxFit.fitWidth),
        StreamBuilder<List<City>>(
            stream: widget.arena.stream,
            builder: (context, snapshot) {
              if (snapshot.data == null) return const SizedBox();
              return Stack(children: [
                for (var i = 0; i < snapshot.data!.length; i++)
                  _cityRenderer(snapshot.data!.length - i - 1,
                      snapshot.data![snapshot.data!.length - i - 1])
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
      _questsCount = accountProvider.account.questsCount - 1;
      if (event.name == "click") {
        serviceLocator<RouteService>().to(Routes.deck);
      } else if (event.name == "loading") {
        // Load city positions
        var positions = <City>[];
        var cities = event.properties["buttons"].split(",");
        for (var i = 0; i < cities.length; i++) {
          var offset = cities[i].split(":");
          var city =
              City(i, Offset(double.parse(offset[0]), double.parse(offset[1])));
          positions.add(city);
          if (widget.index == widget.currentIndex) {
            var index = (_questsCount / 10).floor() * 10;
            if (index == widget.index * 130 + i * 10) {
              await Future.delayed(const Duration(seconds: 1));
              _boatPosition?.value = city.position.dy / 100;
            }
          }
        }
        widget.arena.value = positions;
      }
    });
  }

  Widget _cityRenderer(int index, City city) {
    var size = index == 12 ? 200.d : 170.d;
    var state = (_questsCount - widget.index * 130 - index * 10).toDouble();
    return Positioned(
      left: city.position.dx.d - size * 0.5,
      top: city.position.dy.d - size * 0.5,
      child: state >= 0 && state <= 10
          ? LoaderWidget(
              AssetType.animation,
              "quest_map_button",
              width: size,
              height: size,
              key: GlobalKey(),
              onRiveInit: (Artboard artboard) {
                void setText(String name, String value) {
                  artboard.component<TextValueRun>(name)?.text = value;
                  artboard.component<TextValueRun>("${name}_stroke")?.text =
                      value;
                  artboard.component<TextValueRun>("${name}_shadow")?.text =
                      value;
                }

                var controller = StateMachineController.fromArtboard(
                    artboard, "State Machine 1");
                _state = controller?.findInput<double>("state") as SMINumber;
                city.state = _state;
                city.state?.value = state;
                setText("levelText", "${index + 1}");
                controller
                    ?.addEventListener((event) => _riveEventsListener(event));
                if (widget.index < 390) {
                  if (index == 1 ||
                      index == 4 ||
                      index == 7 ||
                      index == 10 ||
                      index == 12) {
                    controller?.findInput<double>("bubble")?.value =
                        state > 10 ? 2 : 1;
                    controller?.findInput<double>("bubbleIndex")?.value =
                        index == 12 ? 0 : 1;
                  }
                }
                artboard.addController(controller!);
              },
            )
          : FutureBuilder(
              future: getImage(index, state),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox();
                }
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.memory(
                      snapshot.data!,
                      width: size,
                      height: size,
                    ),
                    state > 10 && index != 12
                        ? Padding(
                            padding: EdgeInsets.only(bottom: 10.d),
                            child: SkinnedText(
                              "${index + 1}",
                              style: TStyles.medium.copyWith(
                                color: TColors.primary,
                              ),
                            ),
                          )
                        : const SizedBox()
                  ],
                );
              },
            ),
    );
  }
}

Future<Uint8List> getImage(int index, double state) async {
  var image = state < 0 ? "quest_map_button2" : "quest_map_button0";
  if (index < 390) {
    if (index == 1 || index == 4 || index == 7) {
      image = state < 0 ? "quest_map_button3" : "quest_map_button1";
    }
    if (index == 10) {
      image = state < 0 ? "quest_map_button3" : "quest_map_button1";
    }
    if (index == 12) {
      image = "quest_map_button4";
    }
  }
  var loader =
      await LoaderWidget.load(AssetType.image, image, subFolder: "maps");
  while (loader.metadata == null) {
    await Future.delayed(const Duration(milliseconds: 100));
  }
  return loader.metadata as Uint8List;
}

class City {
  final int index;
  SMINumber? state;
  final Offset position;

  City(this.index, this.position);
}
