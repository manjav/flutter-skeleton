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
import '../../data/core/rpc.dart';
import '../../services/connection/http_connection.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/screens/iscreen.dart';
import '../../view/widgets/level_indicator.dart';
import '../../view/widgets/skinnedtext.dart';
import '../items/card_item.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/loaderwidget.dart';

class DeckScreen extends AbstractScreen {
  DeckScreen({super.key}) : super(Routes.deck);

  @override
  createState() => _DeckScreenState();
}

class _DeckScreenState extends AbstractScreenState<AbstractScreen> {
  final SelectedCards _selectedCards =
      SelectedCards(List.generate(5, (i) => null));
  final GlobalKey<State<StatefulWidget>> _playerLevelKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _enemyLevelKey = GlobalKey();

  @override
  Widget contentFactory() {
    var paddingTop = 172.d;
    var headerSize = 509.d;
    var gap = 10.d;
    var crossAxisCount = 4;
    var itemSize =
        (DeviceInfo.size.width - gap * (crossAxisCount + 1)) / crossAxisCount;
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      var account = state.account;
      var cards = account.getReadyCards();
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
                        childAspectRatio: 0.74,
                        crossAxisCount: 4,
                        crossAxisSpacing: gap,
                        mainAxisSpacing: gap),
                    itemBuilder: (c, i) =>
                        _cardItemBuilder(c, i, cards[i], itemSize));
              }),
        ),
        Positioned(
            top: paddingTop,
            right: 16.d,
            height: headerSize,
            left: 16.d,
            child: _header(account)),
        Positioned(
            height: 214.d,
            bottom: 24.d,
            child: Widgets.labeledButton(
                padding: EdgeInsets.fromLTRB(56.d, 48.d, 56.d, 64.d),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const LoaderWidget(AssetType.image, "icon_battle"),
                    SizedBox(width: 16.d),
                    SkinnedText("fight_l".l(), style: TStyles.large),
                  ],
                ),
                size: "",
                onPressed: () => _fight(account)))
      ]);
    });
  }

  Widget? _cardItemBuilder(
      BuildContext context, int index, AccountCard card, double itemSize) {
    return Widgets.button(
      foregroundDecoration: _selectedCards.value.contains(card)
          ? BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(28.d)),
              border: Border.all(color: TColors.white, width: 8.d))
          : null,
      padding: EdgeInsets.zero,
      onPressed: () => _addCard(card),
      child: CardView(card, inDeck: true, size: itemSize, key: card.key),
    );
  }

  bool _addCard(card) {
    var index = _selectedCards.value.indexOf(card);
    if (index > -1) {
      _selectedCards.setCard(index, null);
      return true;
    }
    for (var i = 0; i < _selectedCards.value.length; i++) {
      if (i != 2 && _selectedCards.value[i] == null || i == 4) {
        _selectedCards.setCard(i, card);
        return true;
      }
    }
    return false;
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
                      _avatar(TextAlign.left, _playerLevelKey),
                      SizedBox(width: 8.d),
                      _opponentInfo(CrossAxisAlignment.start, account),
                      Asset.load<Image>("deck_battle_icon", height: 136.d),
                      _opponentInfo(CrossAxisAlignment.end, account),
                      SizedBox(width: 8.d),
                      _avatar(TextAlign.right, _enemyLevelKey),
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
                          _cardHolder(i)
                      ],
                    );
                  }),
            ]));
  }

  Widget _avatar(TextAlign align, GlobalKey key) {
    return SizedBox(
        width: 160.d,
        height: 160.d,
        child: LevelIndicator(key: key, align: align));
  }

  Widget _opponentInfo(CrossAxisAlignment align, Account account) {
    var itsMe = align == CrossAxisAlignment.start;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: align,
        children: [
          SkinnedText((itsMe ? "you_l" : "enemy_l").l(),
              style: TStyles.small.copyWith(
                  height: 0.8, color: TColors.primary10, fontSize: 36.d)),
          itsMe
              ? ValueListenableBuilder<List<AccountCard?>>(
                  valueListenable: _selectedCards,
                  builder: (context, value, child) => SkinnedText(
                      account.calculatePower(_selectedCards.value).compact()),
                )
              : SkinnedText("~${getQuestPower(account)[2].compact()}"),
          SizedBox(height: 16.d)
        ],
      ),
    );
  }

  Widget _cardHolder(int index) {
    var card = _selectedCards.value[index];
    var balloonData =
        ImageCenterSliceDate(50, 57, const Rect.fromLTWH(28, 19, 2, 2));
    var slicingData = ImageCenterSliceDate(117, 117);
    return Column(children: [
      card == null
          ? const SizedBox()
          : Widgets.rect(
              padding: EdgeInsets.all(12.d),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      centerSlice: balloonData.centerSlice,
                      image: Asset.load<Image>(
                        "deck_balloon",
                        centerSlice: balloonData,
                      ).image)),
              child: Text(card.power.compact(), style: TStyles.mediumInvert)),
      Widgets.button(
          onPressed: () => _selectedCards.setCard(index, null),
          width: index == 2 ? 202.d : 184.d,
          height: index == 2 ? 202.d : 184.d,
          padding: EdgeInsets.all(12.d),
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill,
                  centerSlice: slicingData.centerSlice,
                  image: Asset.load<Image>(
                    "deck_placeholder",
                    centerSlice: slicingData,
                  ).image)),
          child: _selectedCards.value[index] == null
              ? _emptyCard(index)
              : _filledCard(_selectedCards.value[index]!))
    ]);
  }

  Widget _emptyCard(int index) {
    return Padding(
        padding: EdgeInsets.all(24.d),
        child: Asset.load<Image>(
            "deck_placeholder_${index == 2 ? 'hero' : 'card'}"));
  }

  Widget _filledCard(AccountCard accountCard) {
    return LoaderWidget(
        AssetType.image, accountCard.base.get<String>(CardFields.name),
        subFolder: "cards");
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

  _fight(Account account) async {
    var bloc = BlocProvider.of<Services>(context);
    var params = <String, dynamic>{
      RpcParams.cards.name: "[${_selectedCards.getIds()}]",
      RpcParams.check.name: md5
          .convert(utf8.encode("${account.get<int>(AccountField.q)}"))
          .toString()
    };
    if (_selectedCards.value[2] != null) {
      params[RpcParams.hero_id.name] = _selectedCards.value[2]!.id;
    }

    try {
      var data = await bloc
          .get<HttpConnection>()
          .tryRpc(context, RpcId.quest, params: params);
      // var data = jsonDecode(
      //     '{"outcome":true,"boss_mode":false,"gold":1927243,"gold_added":1229,"levelup_gold_added":0,"level":280,"xp":5372397,"xp_added":38,"rank":1,"tribe_rank":1,"attack_cards":[{"id":407811,"last_used_at":1689436232,"power":23,"base_card_id":198,"player_id":2775},{"id":586801,"last_used_at":1689436232,"power":55,"base_card_id":415,"player_id":2775}],"tribe_gold":11856196,"gift_card":null,"q":207840,"total_quests":203767,"needs_captcha":false,"league_id":24,"tutorial_required_cards":null,"attacker_combo_info":[],"potion_number":0,"nectar":50,"available_combo_id_set":null,"purchase_deposits_to_bank":null,"attacker_hero_benefits_info":{"cards":[{"id":407811,"power":23}],"power_benefit":7,"gold_benefit":194,"cooldown_benefit":0}}');
      account.update(data);

      if (mounted) {
        BlocProvider.of<AccountBloc>(context).add(SetAccount(account: account));
        Navigator.pop(context);
        Navigator.pushNamed(context, Routes.battleOutcome.routeName,
            arguments: data);
      }
    } catch (e) {
      // log("$e");
    }
  }
}

class SelectedCards extends ValueNotifier<List<AccountCard?>> {
  SelectedCards(super.value);
  setCard(int index, AccountCard? card) {
    value[index] = card;
    notifyListeners();
  }

  getIds() {
    return value.map((c) => c?.id).where((id) => id != null).join(',');
  }
}
