import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_export.dart';

class DeckScreen extends AbstractScreen {
  DeckScreen({super.key}) : super(Routes.deck);

  @override
  createState() => _DeckScreenState();
}

class _DeckScreenState extends AbstractScreenState<DeckScreen>
    with KeyProvider {
  final SelectedCards _selectedCards =
      SelectedCards(List.generate(5, (i) => null));
  late Opponent _opponent;

  @override
  List<Widget> appBarElementsRight() {
    return <Widget>[
      Indicator(widget.route, Values.gold),
      Indicator(widget.route, Values.nectar, width: 280.d),
      Indicator(widget.route, Values.potion, width: 256.d),
    ];
  }

  @override
  Widget contentFactory() {
    var gap = 10.d;
    var paddingTop = 172.d;
    var headerSize = 509.d;
    var crossAxisCount = 4;
    var itemSize =
        (DeviceInfo.size.width - gap * (crossAxisCount + 1)) / crossAxisCount;
    return Consumer<AccountProvider>(builder: (_, state, child) {
      var cards = state.account.getReadyCards();
      _opponent = widget.args["opponent"] ??
          Opponent.initialize({
            "name": "enemy_l".l(),
            "def_power": getQuestPower(state.account)[2],
            "level": state.account.level,
            "xp": state.account.xp * (0.9 + Random().nextDouble() * 0.2)
          }, 0);
      for (var card in cards) {
        card.isDeployed = false;
      }
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
            child: SkinnedButton(
                padding: EdgeInsets.fromLTRB(56.d, 48.d, 56.d, 64.d),
                alignment: Alignment.center,
                size: ButtonSize.medium,
                onPressed: () => _attack(state.account),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const LoaderWidget(AssetType.image, "icon_battle"),
                    SizedBox(width: 16.d),
                    SkinnedText("attack_l".l(), style: TStyles.large),
                  ],
                )))
      ]);
    });
  }

  Widget? _cardItemBuilder(BuildContext context, int index, Account account,
      AccountCard card, double itemSize) {
    return Widgets.button(
      context,
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
          showCoolOff: true, size: itemSize, key: getGlobalKey(card.id)),
    );
  }

  Widget _header(Account account) {
    return Widgets.rect(
        padding: EdgeInsets.symmetric(horizontal: 10.d, vertical: 7.d),
        decoration: Widgets.imageDecorator("frame_header_cheese",
            ImageCenterSliceData(114, 174, const Rect.fromLTWH(58, 48, 2, 2))),
        child: Stack(children: [
          Widgets.rect(
              height: 192.d,
              decoration: Widgets.imageDecorator(
                  "frame_hatch",
                  ImageCenterSliceData(
                      80, 100, const Rect.fromLTWH(37, 64, 2, 2)))),
          Positioned(
              left: 16.d,
              top: 2,
              right: 16.d,
              bottom: 24.d,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        height: 168.d,
                        child: Row(
                          children: [
                            _avatar(TextAlign.left, account),
                            SizedBox(width: 8.d),
                            _opponentInfo(
                                CrossAxisAlignment.start, account, account),
                            Asset.load<Image>("deck_battle_icon",
                                height: 136.d),
                            _opponentInfo(
                                CrossAxisAlignment.end, account, _opponent),
                            SizedBox(width: 8.d),
                            _avatar(TextAlign.right, _opponent),
                          ],
                        )),
                    ValueListenableBuilder<List<AccountCard?>>(
                        valueListenable: _selectedCards,
                        builder: (context, value, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (var i = 0;
                                  i < _selectedCards.value.length;
                                  i++)
                                CardHolder(
                                    card: _selectedCards.value[i],
                                    heroMode: i == 2,
                                    onTap: () =>
                                        _selectedCards.setAtCard(i, null))
                            ],
                          );
                        }),
                  ]))
        ]));
  }

  Widget _avatar(TextAlign align, Opponent opponent) => LevelIndicator(
        size: 160.d,
        align: align,
        xp: opponent.xp,
        level: opponent.level,
        avatarId: opponent.avatarId,
      );

  Widget _opponentInfo(
      CrossAxisAlignment align, Account account, Opponent opponent) {
    var itsMe = align == CrossAxisAlignment.start;
    var opponentPower = "????";
    if (opponent.isRevealed) {
      opponentPower = opponent.defPower.compact();
    } else if (widget.args["opponent"] == null) {
      opponentPower = "~${opponent.defPower.compact()}";
    }
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
                : SkinnedText(opponentPower, textDirection: TextDirection.ltr),
            SizedBox(height: 16.d)
          ]),
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
    var coefficient = 0.4761;
    var exponent = 1.0786;
    var defenceMin = 40;
    var defenceValue = <int>[0, 0, 0];
    var multiplier = tutorialPowerMultiplier;
    var q = account.q;
    if (account.level < 80) {
      defenceValue[1] = (initialPower +
                  (initialGold * q + (q * (q - 1)) / 80) / costPowerRatio)
              .floor() *
          multiplier;
    } else {
      defenceValue[1] =
          (coefficient * math.pow(q, exponent)).floor().min(defenceMin);
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
  bool isBossQuest(Account account) => ((account.questsCount / 10) % 1 == 0);

  _attack(Account account) async {
    Overlays.insert(
      context,
      AttackFeastOverlay(
        args: {
          "opponent": _opponent,
          "cards": _selectedCards,
          "isBattle": widget.args.containsKey("opponent"),
        },
        onClose: (data) async {
          _selectedCards.clear(setNull: true);
          // Reset reminder notifications ....
          getService<Notifications>().schedule(account.getSchedules());
        },
      ),
    );
  }
}
