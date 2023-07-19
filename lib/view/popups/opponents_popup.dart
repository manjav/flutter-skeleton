import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services.dart';
import '../../data/core/account.dart';
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
import '../widgets/level_indicator.dart';
import '../widgets/loaderwidget.dart';
import '../widgets/skinnedtext.dart';

class OpponentsPopup extends AbstractPopup {
  const OpponentsPopup({super.key, required super.args})
      : super(Routes.popupCard);

  @override
  createState() => _OpponentsPopupState();
}

class _OpponentsPopupState extends AbstractPopupState<OpponentsPopup> {
  int get floatingCost {
    var scoutCostRelCoef = 0.05;
    var scoutCostMax = 20000;
    var scoutCostBase = 80;
    return ((_account.get<int>(AccountField.q) * scoutCostRelCoef)
                .clamp(0, scoutCostMax) +
            scoutCostBase)
        .floor();
  }

  List<Opponent> _opponents = [];
  final ValueNotifier<Opponent> _selectedOpponent =
      ValueNotifier(Opponent(null));
  late Account _account;

  final _mapSize = 924.d;
  final _pageController =
      PageController(viewportFraction: 1 + (32.d * 2 / 924.d));

  @override
  void initState() {
    _findOpponents();
    _account = BlocProvider.of<AccountBloc>(context).account!;
    contentPadding = EdgeInsets.fromLTRB(12.d, 210.d, 12.d, 64.d);
    super.initState();
  }

  _findOpponents() async {
    var data = await BlocProvider.of<Services>(context)
        .get<HttpConnection>()
        .tryRpc(context, RpcId.getOpponents);
    _opponents = Opponent.fromMap(data);
    _selectedOpponent.value = _opponents[0];
    setState(() {});
  }

  @override
  titleBuilder() => "opponent_select".l();

  @override
  contentFactory() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [_maps(), _groups(), _buttons()]);
  }

  _maps() {
    return ClipRRect(
        borderRadius: BorderRadius.circular(32.d),
        child: SizedBox(
            width: _mapSize,
            height: _mapSize,
            child: Stack(
              children: [
                PageView.builder(
                    itemBuilder: _pageItemBuilder,
                    itemCount: _opponents.length,
                    onPageChanged: (value) =>
                        _selectMap(value + 0.0, pageChange: false),
                    controller: _pageController),
                ValueListenableBuilder<Opponent>(
                    valueListenable: _selectedOpponent,
                    builder: (context, value, child) {
                      if (value.id == 0) return const SizedBox();
                      var color = TColors.white;
                      if (value.status == 1) {
                        color = TColors.green;
                      } else if (value.status == 2) {
                        color = TColors.accent;
                      }
                      return Widgets.rect(
                          radius: 32.d,
                          color: color.withOpacity(0.6),
                          padding: EdgeInsets.all(16.d),
                          height: 220.d,
                          child: Row(
                            children: [
                              LevelIndicator(
                                  size: 190.d,
                                  level: value.level,
                                  xp: value.xp,
                                  avatarId: value.avatarId),
                              SizedBox(width: 16.d),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    SkinnedText(
                                      value.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SkinnedText(value.tribeName,
                                        style: TStyles.small),
                                  ])),
                              SizedBox(width: 16.d),
                              Indicator("origin", AccountField.league_rank,
                                  clickable: false,
                                  width: 220.d,
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
                        "my_max_power".l(),
                        SkinnedText(value.defPower.compact(),
                            style: TStyles.big
                                .copyWith(color: TColors.accent, height: 3.d)))
                    : _group(
                        "scout_l".l(),
                        Widgets.labeledButton(
                            width: 320.d,
                            color: "green",
                            padding: EdgeInsets.fromLTRB(16.d, 8.d, 16.d, 22.d),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Asset.load<Image>("ui_gold", width: 96.d),
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
    var bgCenterSlice = ImageCenterSliceDate(144, 144);
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

  _buttons() {
    return ValueListenableBuilder<Opponent>(
        valueListenable: _selectedOpponent,
        builder: (context, value, child) {
    return Widgets.rect(
        height: 196.d,
        padding: EdgeInsets.symmetric(horizontal: 24.d),
        child: Row(children: [
                Opacity(
                    opacity: value.index <= 0 ? 0.4 : 1,
                    child: Widgets.labeledButton(
              size: "",
              child: Asset.load<Image>("ui_arrow_back", width: 68.d),
              color: "green",
              width: 230.d,
                        onPressed: () =>
                            _selectMap(_pageController.page! - 1))),
          SizedBox(width: 8.d),
          Expanded(
              child: Widgets.labeledButton(
                  padding: EdgeInsets.fromLTRB(32.d, 28.d, 42.d, 42.d),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const LoaderWidget(AssetType.image, "icon_battle"),
                      SkinnedText("attack_l".l(), style: TStyles.large),
                    ],
                  ),
                  size: "",
                  onPressed: _attack)),
          SizedBox(width: 8.d),
                Opacity(
                    opacity: value.index >= _opponents.length - 1 ? 0.4 : 1,
                    child: Widgets.labeledButton(
              size: "",
                        child:
                            Asset.load<Image>("ui_arrow_forward", width: 68.d),
              color: "green",
              width: 230.d,
                        onPressed: () =>
                            _selectMap(_pageController.page! + 1))),
        ]));
        });
  }

  _selectMap(double page, {bool pageChange = true}) {
    var index = page.clamp(0, _opponents.length - 1).round();
    if (pageChange) {
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 700), curve: Curves.ease);
    }
    _selectedOpponent.value = _opponents[index];
  }

  _scout() async {
    try {
      await BlocProvider.of<Services>(context)
          .get<HttpConnection>()
          .tryRpc<List>(context, RpcId.scout);
      _selectedOpponent.value.isRevealed = true;
      setState(() {});
    } finally {}
  }

  _attack() {
    _selectedOpponent.value.increaseAttacksCount();
    Navigator.pushNamed(context, Routes.deck.routeName,
        arguments: {"opponent": _selectedOpponent.value});
  }
}
