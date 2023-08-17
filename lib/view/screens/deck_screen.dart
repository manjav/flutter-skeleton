import 'dart:convert';
import 'dart:math';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services.dart';
import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../data/core/ranking.dart';
import '../../data/core/rpc.dart';
import '../../services/connection/http_connection.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/screens/iscreen.dart';
import '../../view/widgets/card_holder.dart';
import '../../view/widgets/indicator.dart';
import '../../view/widgets/skinnedtext.dart';
import '../items/card_item.dart';
import '../key_provider.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/indicator_level.dart';
import '../widgets/loaderwidget.dart';

class DeckScreen extends AbstractScreen {
  final Opponent? opponent;
  DeckScreen({this.opponent, super.key}) : super(Routes.deck);
  @override
  createState() => _DeckScreenState();
}

class _DeckScreenState extends AbstractScreenState<DeckScreen>
    with KeyProvider {
  final SelectedCards _selectedCards =
      SelectedCards(List.generate(5, (i) => null));

  @override
  List<Widget> appBarElementsRight() {
    return <Widget>[
      Indicator(widget.type.name, AccountField.gold),
      Indicator(widget.type.name, AccountField.nectar, width: 280.d),
      Indicator(widget.type.name, AccountField.potion_number, width: 256.d),
    ];
  }

  @override
  Widget contentFactory() {
    var paddingTop = 172.d;
    var headerSize = 509.d;
    var gap = 10.d;
    var crossAxisCount = 4;
    var itemSize =
        (DeviceInfo.size.width - gap * (crossAxisCount + 1)) / crossAxisCount;
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      var cards = state.account.getReadyCards();
      return Stack(alignment: Alignment.bottomCenter, children: [
        Positioned(
          top: paddingTop + headerSize,
          right: 0,
          bottom: 0,
          left: 0,
          child: ValueListenableBuilder<List<AccountCard?>>(
              valueListenable: _selectedCards,
              builder: (context, value, child) {
                return GridView.builder(
                    padding: EdgeInsets.fromLTRB(gap, gap, gap, 270.d),
                    itemCount: cards.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: CardItem.aspectRatio,
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: gap,
                        mainAxisSpacing: gap),
                    itemBuilder: (c, i) => _cardItemBuilder(
                        c, i, state.account, cards[i], itemSize));
              }),
        ),
        Positioned(
            top: paddingTop,
            right: 16.d,
            height: headerSize,
            left: 16.d,
            child: _header(state.account)),
        Positioned(
            height: 214.d,
            width: 420.d,
            bottom: 24.d,
            child: Widgets.skinnedButton(
                padding: EdgeInsets.fromLTRB(56.d, 48.d, 56.d, 64.d),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const LoaderWidget(AssetType.image, "icon_battle"),
                    SizedBox(width: 16.d),
                    SkinnedText("attack_l".l(), style: TStyles.large),
                  ],
                ),
                size: ButtonSize.medium,
                onPressed: () => _attack(state.account)))
      ]);
    });
  }

  Widget? _cardItemBuilder(BuildContext context, int index, Account account,
      AccountCard card, double itemSize) {
    return Widgets.button(
      foregroundDecoration: _selectedCards.value.contains(card)
          ? BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(28.d)),
              border: Border.all(color: TColors.white, width: 8.d))
          : null,
      padding: EdgeInsets.zero,
      onPressed: () {
        if (card.getRemainingCooldown() > 0) {
          card.coolOff(context);
        } else {
          if (card.base.isHero) {
            _selectedCards.setAtCard(2, card);
          } else {
            _selectedCards.setCard(card, exception: 2);
          }
        }
      },
      child: CardItem(card,
          showCooloff: true, size: itemSize, key: getGlobalKey(card.id)),
    );
  }

  Widget _header(Account account) {
    var slicingData = ImageCenterSliceDate(117, 509);
    return Widgets.rect(
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill,
                centerSlice: slicingData.centerSlice,
                image: Asset.load<Image>(
                  "deck_header",
                  centerSlice: slicingData,
                ).image)),
        padding: EdgeInsets.fromLTRB(28.d, 12.d, 28.d, 32.d),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  height: 168.d,
                  child: Row(
                    children: [
                      _avatar(TextAlign.left),
                      SizedBox(width: 8.d),
                      _opponentInfo(CrossAxisAlignment.start, account),
                      Asset.load<Image>("deck_battle_icon", height: 136.d),
                      _opponentInfo(CrossAxisAlignment.end, account),
                      SizedBox(width: 8.d),
                      _avatar(TextAlign.right),
                    ],
                  )),
              ValueListenableBuilder<List<AccountCard?>>(
                  valueListenable: _selectedCards,
                  builder: (context, value, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < _selectedCards.value.length; i++)
                          CardHolder(
                              card: _selectedCards.value[i],
                              heroMode: i == 2,
                              onTap: () => _selectedCards.setAtCard(i, null))
                      ],
                    );
                  }),
            ]));
  }

  Widget _avatar(TextAlign align) => LevelIndicator(align: align, size: 160.d);

  Widget _opponentInfo(CrossAxisAlignment align, Account account) {
    var itsMe = align == CrossAxisAlignment.start;
    var opponent = widget.opponent ??
        Opponent.init({
          "name": (itsMe ? "you_l" : "enemy_l").l(),
          "def_power": getQuestPower(account)[2]
        }, 0);
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: align,
        children: [
          SkinnedText(opponent.name,
              style: TStyles.small.copyWith(
                  height: 0.8, color: TColors.primary10, fontSize: 36.d)),
          itsMe
              ? ValueListenableBuilder<List<AccountCard?>>(
                  valueListenable: _selectedCards,
                  builder: (context, value, child) => SkinnedText(
                      account.calculatePower(_selectedCards.value).compact()),
                )
              : SkinnedText("~${opponent.defPower.compact()}"),
          SizedBox(height: 16.d)
        ],
      ),
    );
  }

/* This function returns the power of the next quest.
 @param tutorialPowerMultiplier, the number that will be multiplied to the real power.
 @return A table is returned with three children. 'realPower' is the actual power of the quest; 'minPower' is the approximate min value of the quest and 'maxPower'
 is the approximate maximum power of the quest. The min and max powers are only for display purposes and have no real effect on anything.
 */

  List<int> getQuestPower(Account account, {int tutorialPowerMultiplier = 1}) {
    var initialPower = 35;
    var initialGold = 40;
// var costPerPowerRatio = 230;
// var costPerPowerRatioExponent = 0.002;
// var defenceMultiplier = 14;
    var costPowerRatio = 230;
    var bossPowerMultiplier = 2;
// var purgeStep = 30;
    var coef = 0.4761;
    var exponent = 1.0786;
    var defenceMin = 40;
    var defenceValue = <int>[0, 0, 0];
    var multiplier = tutorialPowerMultiplier;
    var q = account.get<int>(AccountField.q);
    if (account.get<int>(AccountField.level) < 80) {
      defenceValue[1] = (initialPower +
                  (initialGold * q + (q * (q - 1)) / 80) / costPowerRatio)
              .floor() *
          multiplier;
    } else {
      defenceValue[1] = (coef * math.pow(q, exponent)).floor().min(defenceMin);
    }
    var random = Random();
    defenceValue[0] = (defenceValue[1] - random.nextInt(10) - 10).min(0);
    defenceValue[2] = defenceValue[1] + random.nextInt(10) + 10;

    //log3("Min:",defenceValue.minPower,"Real:",defenceValue.realPower,"Max:",defenceValue.maxPower)
    if (isBossQuest(account)) {
      defenceValue[1] = bossPowerMultiplier * defenceValue[1];
      defenceValue[0] = bossPowerMultiplier * defenceValue[0];
      defenceValue[2] = bossPowerMultiplier * defenceValue[2];
    }
    return defenceValue;
  }

  // every 10 quests is boss fight
  bool isBossQuest(Account account) =>
      ((account.get<int>(AccountField.total_quests) / 10) % 1 == 0);

  _attack(Account account) async {
    var bloc = BlocProvider.of<Services>(context);
    var params = <String, dynamic>{
      RpcParams.cards.name: _selectedCards.getIds(),
      RpcParams.check.name: md5
          .convert(utf8.encode("${account.get<int>(AccountField.q)}"))
          .toString()
    };
    var route =
        widget.opponent == null ? Routes.questOutcome : Routes.battleOutcome;
    if (route == Routes.battleOutcome) {
      params[RpcParams.opponent_id.name] = widget.opponent!.id;
      params[RpcParams.attacks_in_today.name] =
          widget.opponent!.todayAttacksCount;
    }
    if (_selectedCards.value[2] != null) {
      params[RpcParams.hero_id.name] = _selectedCards.value[2]!.id;
    }

    try {
      var data = await bloc
          .get<HttpConnection>()
          .tryRpc(context, RpcId.quest, params: params);
      account.update(data);
      if (mounted) {
        BlocProvider.of<AccountBloc>(context).add(SetAccount(account: account));
        Navigator.pop(context);
        Navigator.pushNamed(context, route.routeName, arguments: data);
      }
    } finally {}
  }
}
