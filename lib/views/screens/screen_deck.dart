import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
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
  Opponent? _opponent;
  final RxBool _sortByPower = true.obs;
  late AnimationController _sortController;

  @override
  initState() {
    super.initState();
    _sortController = AnimationController(
      vsync: this,
      duration: 300.ms,
      upperBound: 0.5,
    );
  }

  @override
  void onTutorialFinish(data) {
    if (data["index"] == 7) {
      _attack(accountProvider.account);
    }
    super.onTutorialFinish(data);
  }

  @override
  void dispose() {
    super.dispose();
    _sortController.dispose();
  }

  @override
  List<Widget> appBarElementsRight() {
    if (isTutorial) return [];
    return <Widget>[
      Indicator(widget.route, Values.potion, width: 256.d),
      Indicator(widget.route, Values.gold),
      Indicator(widget.route, Values.nectar, width: 280.d),
    ];
  }

  @override
  List<Widget> appBarElementsLeft() {
    return <Widget>[];
  }

  @override
  Widget contentFactory() {
    var paddingTop = MediaQuery.of(context).viewPadding.top;
    if (paddingTop <= 0) {
      paddingTop = 24.d;
    }
    paddingTop += 250.d;
    var gap = 15.d;
    var headerSize = 330.d;
    var crossAxisCount = 3;
    var itemSize =
        (DeviceInfo.size.width - gap * (crossAxisCount + 1)) / crossAxisCount;
    var account = accountProvider.account;
    var cards = account.getReadyCards();
    cards.sort((a, b) {
      int x = 1, y = 1;

      var aCoolDown = a.getRemainingCooldown();
      var bCoolDown = b.getRemainingCooldown();

      if (a.base.isHero && aCoolDown == 0) x += 2;
      if (b.base.isHero && bCoolDown == 0) y += 2;

      if (aCoolDown > 0) x -= 3;
      if (bCoolDown > 0) y -= 3;

      if (a.power > b.power) {
        x++;
      } else {
        y++;
      }
      return y - x;
    });

    _opponent = widget.args["opponent"] ??
        Opponent.initialize({
          "name": "enemy_l".l(),
          "def_power": getQuestPower(account)[2],
          "level": account.level,
          "xp": account.xp * (0.9 + Random().nextDouble() * 0.2)
        }, 0);
    for (var card in cards) {
      card.isDeployed = false;
    }
    return PopScope(
      canPop: !isTutorial,
      child: Consumer<AccountProvider>(
        builder: (_, state, child) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                height: Get.height,
                width: Get.width,
                child: const LoaderWidget(
                  AssetType.image,
                  "background0",
                  subFolder: "backgrounds",
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                top: paddingTop + headerSize + 13,
                bottom: 0,
                left: 0,
                right: 0,
                child: Widgets.rect(color: TColors.black25, height: 500),
              ),
              Positioned(
                top: paddingTop + headerSize + 30,
                right: 0,
                bottom: 0,
                left: 0,
                child: ValueListenableBuilder<List<AccountCard?>>(
                    valueListenable: _selectedCards,
                    builder: (context, value, child) {
                      return StreamBuilder<bool>(
                          stream: _sortByPower.stream,
                          builder: (context, snapshot) {
                            return GridView.builder(
                                padding:
                                    EdgeInsets.fromLTRB(gap, gap, gap, 270.d),
                                itemCount: cards.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        childAspectRatio: CardItem.aspectRatio,
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: gap,
                                        mainAxisSpacing: gap),
                                itemBuilder: (c, i) => _cardItemBuilder(
                                    c, i, state.account, cards[i], itemSize));
                          });
                    }),
              ),
              Positioned(
                top: 200.d,
                height: 150.d,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    _opponentInfo(CrossAxisAlignment.start, account, account),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.d),
                      child: Asset.load<Image>("icon_vs",
                          height: 72.d, width: 72.d),
                    ),
                    _opponentInfo(CrossAxisAlignment.end, account, _opponent!),
                  ],
                ),
              ),
              Positioned(
                top: paddingTop + headerSize,
                left: 37.d,
                right: 37.d,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Asset.load<Image>(
                      "deck_divider",
                      height: 72.d,
                    ),
                    Text(
                      "choose_deck_title".l(),
                      style: TStyles.medium.copyWith(color: TColors.primary50),
                    )
                  ],
                ),
              ),
              Positioned(
                top: 370.d,
                left: 37.d,
                right: 37.d,
                child: ValueListenableBuilder<List<AccountCard?>>(
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
                  },
                ),
              ),
              Positioned(
                top: 340.d,
                left: 0.d,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 37.d),
                  child: SkinnedText(account.name),
                ),
              ),
              Positioned(
                top: 340.d,
                right: 0.d,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 37.d),
                  child: SkinnedText(_opponent!.name),
                ),
              ),

              // Positioned(
              //     top: paddingTop,
              //     right: 16.d,
              //     height: headerSize,
              //     child: _header(state.account)),
              // PositionedDirectional(
              //   top: paddingTop + headerSize + 40.d,
              //   end: 20.d,
              //   width: 292.d,
              //   height: 88.d,
              //   child: Widgets.touchable(
              //     context,
              //     onTap: () {
              //       cards = cards.reversed.toList();
              //       _sortByPower.value = !_sortByPower.value;
              //       if (_sortByPower.value) {
              //         _sortController.reverse(from: 0.5);
              //       } else {
              //         _sortController.forward(from: 0.0);
              //       }
              //     },
              //     child: Widgets.rect(
              //       decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(50.d),
              //           border: Border.all(color: TColors.primary50),
              //           color: TColors.red20),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Text(
              //             "Sort by power",
              //             style: TStyles.small.copyWith(color: TColors.primary50),
              //           ),
              //           SizedBox(
              //             width: 20.d,
              //           ),
              //           RotationTransition(
              //             turns: Tween(begin: 0.0, end: 1.0)
              //                 .animate(_sortController),
              //             child: Asset.load<Image>("icon_arrow_down",
              //                 height: 28.d, width: 21.d),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              Positioned(
                height: 200.d,
                bottom: 50.d,
                width: Get.width * 0.95,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    isTutorial
                        ? const SizedBox()
                        : SkinnedButton(
                            alignment: Alignment.center,
                            color: ButtonColor.violet,
                            size: ButtonSize.medium,
                            width: 221.d,
                            onPressed: () => Get.back(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Asset.load<Image>("ui_arrow_back",
                                    height: 74.d),
                              ],
                            ),
                          ),
                    SizedBox(
                      width: isTutorial ? 0 : 20.d,
                    ),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: _selectedCards,
                        builder: (context, value, child) {
                          return SkinnedButton(
                            alignment: Alignment.center,
                            size: ButtonSize.medium,
                            onPressed: () => _attack(state.account),
                            isEnable: isTutorial
                                ? (value
                                        .where((element) => element == null)
                                        .length ==
                                    3)
                                : true,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LoaderWidget(
                                  AssetType.image,
                                  "icon_battle",
                                  height: 101.d,
                                ),
                                SizedBox(width: 16.d),
                                SkinnedText("attack_l".l(),
                                    style: TStyles.large),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
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
        //todo: add check if we are in tutorial
        if (_selectedCards.value.where((element) => element != null).length ==
                2 &&
            isTutorial) {
          if (accountProvider.account.tutorial_index <= 6) {
            accountProvider.update(context, {
              "tutorial_index": 6,
            });
          }
          checkTutorial();
          //todo: we need to fix it by listen to finish (need to check)
          // checkTutorial(context, Routes.deck,
          //     onFinish: (data) {
          //   _attack(account);
          // });
        }
      },
      child: CardItem(
        card,
        showCoolOff: true,
        size: itemSize,
        key: getGlobalKey(card.id),
        isTutorial: isTutorial,
      ),
    );
  }

  Widget _header(Account account) {
    return Widgets.rect(
      padding: EdgeInsets.symmetric(horizontal: 10.d, vertical: 7.d),
      decoration: Widgets.imageDecorator(
        "frame_header_cheese",
        ImageCenterSliceData(114, 174, const Rect.fromLTWH(58, 48, 2, 2)),
      ),
      width: Get.width,
      child: Stack(
        children: [
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
                // SizedBox(
                //     height: 168.d,
                //     child: Row(
                //       children: [
                //         _avatar(TextAlign.left, account),
                //         SizedBox(width: 8.d),
                //         _opponentInfo(
                //             CrossAxisAlignment.start, account, account),
                //         Asset.load<Image>("deck_battle_icon", height: 136.d),
                //         _opponentInfo(
                //             CrossAxisAlignment.end, account, _opponent!),
                //         SizedBox(width: 8.d),
                //         _avatar(TextAlign.right, _opponent!),
                //       ],
                //     )),
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
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.passthrough,
        children: [
          Transform.flip(
            flipX: !itsMe,
            child: Asset.load<Image>(
              "deck_power_placeholder",
              centerSlice: ImageCenterSliceData(200, 114),
              height: 41,
            ),
          ),
          Positioned(
            right: itsMe ? 30.d : null,
            left: !itsMe ? 30.d : null,
            child: itsMe
                ? ValueListenableBuilder<List<AccountCard?>>(
                    valueListenable: _selectedCards,
                    builder: (context, value, child) => Text(
                      account.calculatePower(_selectedCards.value).compact(),
                      style: TStyles.big.copyWith(color: TColors.green),
                    ),
                  )
                : Text(
                    opponentPower,
                    style: TStyles.big.copyWith(color: TColors.red),
                  ),
          )
        ],
      ),
    );
    // return Expanded(
    //   child: Column(
    //       mainAxisAlignment: MainAxisAlignment.end,
    //       crossAxisAlignment: align,
    //       children: [
    //         SkinnedText(opponent.name,
    //             style: TStyles.small.copyWith(
    //                 height: 0.8, color: TColors.primary10, fontSize: 36.d)),
    //         itsMe
    //             ? ValueListenableBuilder<List<AccountCard?>>(
    //                 valueListenable: _selectedCards,
    //                 builder: (context, value, child) => SkinnedText(
    //                     account.calculatePower(_selectedCards.value).compact()),
    //               )
    //             : SkinnedText(opponentPower, textDirection: TextDirection.ltr),
    //         SizedBox(height: 16.d)
    //       ]),
    // );
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
    if (_selectedCards.value.where((element) => element == null).length == 5) {
      await serviceLocator<RouteService>().to(
        Routes.popupMessage,
        args: {"title": "error".l(), "message": "select_cards".l()},
      );
      return;
    }
    Overlays.insert(
      context,
      AttackFeastOverlay(
        args: {
          "opponent": _opponent,
          "cards": _selectedCards,
          "isBattle": widget.args.containsKey("opponent"),
          "isTutorial": isTutorial
        },
        onClose: (data) {
          _selectedCards.clear(setNull: true);
          serviceLocator<TutorialManager>()
              .checkToturial(context, widget.route);
        },
      ),
    );
    // _selectedCards.clear(setNull: true);
    if (isTutorial) return;
    serviceLocator<Notifications>().schedule(account.getSchedules());
    await Future.delayed(const Duration(milliseconds: 1500));
    serviceLocator<RouteService>().back();
  }
}
