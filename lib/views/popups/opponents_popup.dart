import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

import '../../app_export.dart';

class OpponentsPopup extends AbstractPopup {
  const OpponentsPopup({super.key}) : super(Routes.popupOpponents);

  @override
  createState() => _OpponentsPopupState();
}

class _OpponentsPopupState extends AbstractPopupState<OpponentsPopup> {
  static int _fetchAt = 0;
  static int _requestsCount = 0;

  int get floatingCost {
    var scoutCostRelCoef = 0.05;
    var scoutCostMax = 20000;
    var scoutCostBase = 80;
    return ((_account.q * scoutCostRelCoef).clamp(0, scoutCostMax) +
            scoutCostBase)
        .floor();
  }

  final ValueNotifier<Opponent> _selectedOpponent =
      ValueNotifier(Opponent.initialize(null, 0));
  late Account _account;

  final _mapSize = 924.d;
  final _pageController =
      PageController(viewportFraction: 1 + (32.d * 2 / 924.d));

  @override
  void initState() {
    _account = accountProvider.account;
    _findOpponents();
    super.initState();
  }

  @override
  EdgeInsets get contentPadding => EdgeInsets.fromLTRB(12.d, 210.d, 12.d, 64.d);

  @override
  List<Widget> appBarElements() => [
        Indicator(widget.route, Values.potion, width: 256.d),
        Indicator(widget.name, Values.gold),
        Indicator(widget.name, Values.nectar, width: 310.d),
      ];

  _findOpponents() async {
    var deltaTime = _account.getTime() - _fetchAt;
    var opponentBloc = serviceLocator<OpponentsProvider>();
    if ((deltaTime > 30 && _requestsCount % 5 == 0) || deltaTime > 120) {
      var data = await rpc(RpcId.getOpponents);

      opponentBloc.list = Opponent.fromMap(data, 0);
      if (mounted) {
        serviceLocator<OpponentsProvider>().update();
      }
      _fetchAt = _account.getTime();
    }
    ++_requestsCount;
    _selectedOpponent.value = opponentBloc.list[0];
    if (mounted) setState(() {});
  }

  @override
  titleBuilder() => "opponent_select".l();

  @override
  contentFactory() {
    return Consumer<OpponentsProvider>(
        builder: (_, state, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [_maps(state.list), _groups(), _buttons(state.list)]));
  }

  _maps(List<Opponent> opponents) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(32.d),
        child: SizedBox(
            width: _mapSize,
            height: _mapSize,
            child: Stack(
              children: [
                PageView.builder(
                    itemBuilder: (ctx, index) =>
                        _pageItemBuilder(opponents[index]),
                    itemCount: opponents.length,
                    onPageChanged: (value) =>
                        _selectMap(opponents, value + 0.0, pageChange: false),
                    controller: _pageController),
                _headerBuilder()
              ],
            )));
  }

  Widget? _pageItemBuilder(Opponent opponent) {
    var random = Random();
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.d),
        child: LoaderWidget(
          AssetType.animation,
          "map_opponent",
          fit: BoxFit.fitWidth,
          onRiveInit: (artboard) {
            final controller =
                StateMachineController.fromArtboard(artboard, 'Map')!;

            controller.findInput<double>('money')?.value =
                opponent.getGoldLevel(_account.level).floorToDouble();

            controller.findInput<double>('building')?.value =
                random.nextInt(4).floorToDouble();
            controller.findInput<double>('theme')?.value =
                opponent.theme.toDouble();

            artboard.addController(controller);
          },
        ));
  }

  Widget _headerBuilder() {
    return ValueListenableBuilder<Opponent>(
        valueListenable: _selectedOpponent,
        builder: (context, value, child) {
          if (value.id == 0) return const SizedBox();
          var color = switch (value.status) {
            1 => TColors.green,
            2 => TColors.accent,
            _ => TColors.black
          };
          var tribeStyle = TStyles.small.copyWith(height: 1);
          var raduis = Radius.circular(32.d);
          return Widgets.rect(
              borderRadius:
                  BorderRadius.only(topLeft: raduis, topRight: raduis),
              color: color.withOpacity(0.3),
              padding: EdgeInsets.all(16.d),
              height: 200.d,
              child: Row(
                children: [
                  LevelIndicator(
                      size: 170.d,
                      level: value.level,
                      xp: value.xp,
                      avatarId: value.avatarId),
                  SizedBox(width: 16.d),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        SizedBox(height: 24.d),
                        SkinnedText(value.name,
                            overflow: TextOverflow.ellipsis),
                        SkinnedText(value.tribeName, style: tribeStyle),
                      ])),
                  SizedBox(width: 16.d),
                  Indicator(
                    widget.name,
                    Values.leagueRank,
                    width: 240.d,
                    hasPlusIcon: false,
                    data: value.leagueId,
                    value: _selectedOpponent.value.leagueRank,
                    disableHero: true,
                  )
                ],
              ));
        });
  }

  Widget _groups() {
    return Widgets.rect(
      padding: EdgeInsets.all(28.d),
      height: 280.d,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _group(
              "my_max_power".l(),
              SkinnedText(_account.defPower.compact(),
                  style: TStyles.big.copyWith(
                      color: TColors.orange.withGreen(10700), height: 3.d))),
          SizedBox(width: 32.d),
          ValueListenableBuilder<Opponent>(
              valueListenable: _selectedOpponent,
              builder: (context, value, child) {
                return value.isRevealed
                    ? _group(
                        "enemy_max_power".l(),
                        SkinnedText(value.defPower.compact(),
                            style: TStyles.big
                                .copyWith(color: TColors.accent, height: 3.d)))
                    : _group(
                        "scout_l".l(),
                        SkinnedButton(
                            width: 320.d,
                            color: ButtonColor.green,
                            padding: EdgeInsets.fromLTRB(16.d, 8.d, 16.d, 22.d),
                            onPressed: _scout,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Asset.load<Image>("icon_gold", width: 96.d),
                                SizedBox(width: 8.d),
                                SkinnedText(floatingCost.compact(),
                                    style: TStyles.large),
                              ],
                            )));
              }),
          SizedBox(width: 32.d),
        ],
      ),
    );
  }

  Widget _group(String title, Widget child) {
    return Expanded(
        child: Widgets.rect(
            alignment: Alignment.center,
            decoration: Widgets.imageDecorator(
                "ui_popup_group", ImageCenterSliceData(144)),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SkinnedText(title),
              child,
            ])));
  }

  Widget _buttons(List<Opponent> opponents) {
    return ValueListenableBuilder<Opponent>(
        valueListenable: _selectedOpponent,
        builder: (context, value, child) {
          return Widgets.rect(
            height: 196.d,
            padding: EdgeInsets.symmetric(horizontal: 24.d),
            child: Row(children: [
              SkinnedButton(
                  alignment: Alignment.center,
                  width: 230.d,
                  size: ButtonSize.medium,
                  color: ButtonColor.green,
                  isEnable: value.index > 0,
                  child: Asset.load<Image>(
                      "ui_arrow_${Localization.isRTL ? "forward" : "back"}",
                      width: 68.d),
                  onPressed: () =>
                      _selectMap(opponents, _pageController.page! - 1)),
              SizedBox(width: 8.d),
              Expanded(
                  child: SkinnedButton(
                      padding: EdgeInsets.fromLTRB(32.d, 28.d, 42.d, 42.d),
                      alignment: Alignment.center,
                      size: ButtonSize.medium,
                      onPressed: _attack,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const LoaderWidget(AssetType.image, "icon_battle"),
                          SkinnedText("attack_l".l(), style: TStyles.large),
                        ],
                      ))),
              SizedBox(width: 8.d),
              SkinnedButton(
                  width: 230.d,
                  alignment: Alignment.center,
                  size: ButtonSize.medium,
                  color: ButtonColor.green,
                  isEnable: value.index < opponents.length - 1,
                  child: Asset.load<Image>(
                      "ui_arrow_${Localization.isRTL ? "back" : "forward"}",
                      width: 68.d),
                  onPressed: () =>
                      _selectMap(opponents, _pageController.page! + 1)),
            ]),
          );
        });
  }

  void _selectMap(List<Opponent> opponents, double page,
      {bool pageChange = true}) {
    var index = page.clamp(0, opponents.length - 1).round();
    if (pageChange) {
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 700), curve: Curves.ease);
    }
    _selectedOpponent.value = opponents[index];
  }

  void _scout() async {
    try {
      await rpc(RpcId.scout);
      _selectedOpponent.value.isRevealed = true;
      setState(() {});
    } finally {}
  }

  void _attack() async {
    if (_selectedOpponent.value.status == 2) {
      toast("error_139".l());
      return;
    }
    var opponent = _selectedOpponent.value;
    opponent.increaseAttacksCount();
    if (_selectedOpponent.value.status == 1) {
      try {
        var result = await rpc(RpcId.battleLive,
            params: {RpcParams.opponent_id.name: opponent.id});
        if (mounted) {
          result["friendsHead"] = accountProvider.account;
          result["oppositesHead"] = opponent;
          serviceLocator<RouteService>().to(Routes.liveBattle, args: result);
        }
      } finally {}
      return;
    }
    serviceLocator<RouteService>()
        .to(Routes.deck, args: {"opponent": opponent});
  }
}