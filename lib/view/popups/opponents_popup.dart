import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/opponents_bloc.dart';
import '../../blocs/services_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/ranking.dart';
import '../../data/core/rpc.dart';
import '../../services/connection/http_connection.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/popups/ipopup.dart';
import '../../view/widgets/indicator.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/indicator_level.dart';
import '../widgets/loaderwidget.dart';
import '../widgets/skinnedtext.dart';

class OpponentsPopup extends AbstractPopup {
  OpponentsPopup({super.key}) : super(Routes.popupOpponents, args: {});

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
    return ((_account.get<int>(AccountField.q) * scoutCostRelCoef)
                .clamp(0, scoutCostMax) +
            scoutCostBase)
        .floor();
  }

  final ValueNotifier<Opponent> _selectedOpponent =
      ValueNotifier(Opponent.init(null, 0));
  late Account _account;

  final _mapSize = 924.d;
  final _pageController =
      PageController(viewportFraction: 1 + (32.d * 2 / 924.d));

  @override
  void initState() {
    _account = BlocProvider.of<AccountBloc>(context).account!;
    _findOpponents();
    contentPadding = EdgeInsets.fromLTRB(12.d, 210.d, 12.d, 64.d);
    super.initState();
  }

  _findOpponents() async {
    var deltaTime = _account.now - _fetchAt;
    // if ((deltaTime > 60 && _requestsCount % 10 == 0) || deltaTime > 180) {
    var data = await BlocProvider.of<ServicesBloc>(context)
        .get<HttpConnection>()
        .tryRpc(context, RpcId.getOpponents);

    var opponents = Opponent.fromMap(data);
    if (mounted) {
      BlocProvider.of<OpponentsBloc>(context)
          .add(SetOpponents(list: opponents));
    }
    _fetchAt = _account.now;
    // }
    ++_requestsCount;
    _selectedOpponent.value = opponents[0];
    if (mounted) setState(() {});
  }

  @override
  titleBuilder() => "opponent_select".l();

  @override
  contentFactory() {
    return BlocBuilder<OpponentsBloc, OpponentsState>(
        builder: (BuildContext context, OpponentsState state) {
      return Column(
          mainAxisSize: MainAxisSize.min,
          children: [_maps(state.list), _groups(), _buttons(state.list)]);
    });
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
                    itemBuilder: _pageItemBuilder,
                    itemCount: opponents.length,
                    onPageChanged: (value) =>
                        _selectMap(opponents, value + 0.0, pageChange: false),
                    controller: _pageController),
                ValueListenableBuilder<Opponent>(
                    valueListenable: _selectedOpponent,
                    builder: (context, value, child) {
                      if (value.id == 0) return const SizedBox();
                      var color = switch (value.status) {
                        1 => TColors.green,
                        2 => TColors.accent,
                        _ => TColors.white
                      };
                      return Widgets.rect(
                          radius: 32.d,
                          color: color.withOpacity(0.6),
                          padding: EdgeInsets.all(16.d),
                          height: 200.d,
                          child: Row(
                            children: [
                              LevelIndicator(
                                  size: 170.d,
                                  level: value.level,
                                  xp: value.score,
                                  avatarId: value.avatarId),
                              SizedBox(width: 16.d),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    SizedBox(height: 36.d),
                                    SkinnedText(
                                      value.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SkinnedText(value.tribeName,
                                        style: TStyles.small),
                                  ])),
                              SizedBox(width: 16.d),
                              Indicator(
                                  widget.type.name, AccountField.league_rank,
                                  width: 240.d,
                                  hasPlusIcon: false,
                                  data: value.leagueId,
                                  value: _selectedOpponent.value.leagueRank)
                            ],
                          ));
                    }),
              ],
            )));
  }

  Widget? _pageItemBuilder(BuildContext context, int index) {
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
            artboard.addController(controller);
            controller.findInput<double>('weather')?.value = 0;
            controller.findInput<double>('money')?.value = _selectedOpponent
                .value
                .getGoldLevel(_account.get<int>(AccountField.level))
                .floorToDouble();
            controller.findInput<double>('building')?.value =
                random.nextInt(4).floorToDouble();
          },
        ));
  }

  _groups() {
    return Widgets.rect(
      padding: EdgeInsets.all(28.d),
      height: 280.d,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _group(
              "my_max_power".l(),
              SkinnedText(_account.get<int>(AccountField.def_power).compact(),
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
                        Widgets.skinnedButton(
                            width: 320.d,
                            color: ButtonColor.green,
                            padding: EdgeInsets.fromLTRB(16.d, 8.d, 16.d, 22.d),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Asset.load<Image>("icon_gold", width: 96.d),
                                SizedBox(width: 8.d),
                                SkinnedText(floatingCost.compact(),
                                    style: TStyles.large),
                              ],
                            ),
                            onPressed: _scout));
              }),
          SizedBox(width: 32.d),
        ],
      ),
    );
  }

  _group(String title, Widget child) {
    var bgCenterSlice = ImageCenterSliceData(144, 144);
    return Expanded(
        child: Widgets.rect(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    centerSlice: bgCenterSlice.centerSlice,
                    image: Asset.load<Image>(
                      'ui_popup_group',
                      centerSlice: bgCenterSlice,
                    ).image)),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SkinnedText(title),
              child,
            ])));
  }

  _buttons(List<Opponent> opponents) {
    return ValueListenableBuilder<Opponent>(
        valueListenable: _selectedOpponent,
        builder: (context, value, child) {
          return Widgets.rect(
              height: 196.d,
              padding: EdgeInsets.symmetric(horizontal: 24.d),
              child: Row(children: [
                Widgets.skinnedButton(
                    alignment: Alignment.center,
                    width: 230.d,
                    size: ButtonSize.medium,
                    color: ButtonColor.green,
                    isEnable: value.index > 0,
                    child: Asset.load<Image>("ui_arrow_back", width: 68.d),
                    onPressed: () =>
                        _selectMap(opponents, _pageController.page! - 1)),
                SizedBox(width: 8.d),
                Expanded(
                    child: Widgets.skinnedButton(
                        padding: EdgeInsets.fromLTRB(32.d, 28.d, 42.d, 42.d),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const LoaderWidget(AssetType.image, "icon_battle"),
                            SkinnedText("attack_l".l(), style: TStyles.large),
                          ],
                        ),
                        size: ButtonSize.medium,
                        onPressed: _attack)),
                SizedBox(width: 8.d),
                Widgets.skinnedButton(
                    width: 230.d,
                    alignment: Alignment.center,
                    size: ButtonSize.medium,
                    color: ButtonColor.green,
                    isEnable: value.index < opponents.length - 1,
                    child: Asset.load<Image>("ui_arrow_forward", width: 68.d),
                    onPressed: () =>
                        _selectMap(opponents, _pageController.page! + 1)),
              ]));
        });
  }

  _selectMap(List<Opponent> opponents, double page, {bool pageChange = true}) {
    var index = page.clamp(0, opponents.length - 1).round();
    if (pageChange) {
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 700), curve: Curves.ease);
    }
    _selectedOpponent.value = opponents[index];
  }

  _scout() async {
    try {
      await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc<List>(context, RpcId.scout);
      _selectedOpponent.value.isRevealed = true;
      setState(() {});
    } finally {}
  }

  _attack() async {
    if (_selectedOpponent.value.status == 2) {
      toast("error_139".l());
      return;
    }
    var opponent = _selectedOpponent.value;
    opponent.increaseAttacksCount();
    if (_selectedOpponent.value.status == 1) {
      try {
        var result = await BlocProvider.of<ServicesBloc>(context)
            .get<HttpConnection>()
            .tryRpc(context, RpcId.battleLive,
                params: {RpcParams.opponent_id.name: opponent.id});
        if (mounted) {
          result["opponent"] = opponent;
          Navigator.pushNamed(context, Routes.livebattle.routeName,
              arguments: result);
        }
      } finally {}
      return;
    }
    Navigator.pushNamed(context, Routes.deck.routeName,
        arguments: {"opponent": opponent});
  }
}
