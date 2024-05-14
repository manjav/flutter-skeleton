import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app_export.dart';

class CardsPageItem extends AbstractPageItem {
  const CardsPageItem({super.key}) : super(Routes.pageItemCards);

  @override
  createState() => _CardsPageItemState();
}

class _CardsPageItemState extends AbstractPageItemState<AbstractPageItem>
    with KeyProvider, TickerProviderStateMixin {
  final RxBool _sortByPower = true.obs;
  late AnimationController _sortController;

  @override
  initState() {
    super.initState();
    services.addListener(() {
      var state = services.state;
      if (state.status == ServiceStatus.changeTab && state.data["index"] == 1) {
        checkTutorial();
      }
    });
    _sortController = AnimationController(
      vsync: this,
      duration: 300.ms,
      upperBound: 0.5,
    );
  }

  @override
  void onTutorialFinish(data) {
    if (data["id"] == 323 || data["id"] == 653) {
      var cards = accountProvider.account.getReadyCards(removeHeroes: true);
      serviceLocator<RouteService>()
          .to(Routes.popupCardDetails, args: {'card': cards[0]});
    } else if (data["id"] == 404) {
      var cards = accountProvider.account.getReadyCards();
      serviceLocator<RouteService>()
          .to(Routes.popupCardDetails, args: {'card': cards[0]});
    }
    super.onTutorialFinish(data);
  }

  @override
  void dispose() {
    super.dispose();
    _sortController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Animate.restartOnHotReload = true;
    super.build(context);
    var gap = 15.d;
    var crossAxisCount = 3;
    var itemSize =
        (DeviceInfo.size.width - gap * (crossAxisCount + 1)) / crossAxisCount;
    return Consumer<AccountProvider>(builder: (_, state, child) {
      var cards = state.account.getReadyCards();
      var levels = state.account.loadingData.rules["availabilityLevels"]!;
      var paddingTop = MediaQuery.of(context).viewPadding.top;
      if (paddingTop <= 0) {
        paddingTop = 24.d;
      }
      return Stack(children: [
        StreamBuilder<bool>(
            stream: _sortByPower.stream,
            builder: (context, snapshot) {
              return GridView.builder(
                  itemCount: cards.length,
                  padding:
                      EdgeInsets.fromLTRB(gap, paddingTop + 280.d, gap, 210.d),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: CardItem.aspectRatio,
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: gap,
                      mainAxisSpacing: gap),
                  itemBuilder: (c, i) =>
                      cardItemBuilder(c, i, cards[i], itemSize));
            }),
        PositionedDirectional(
          top: paddingTop + 150.d,
          end: 20.d,
          width: 292.d,
          height: 88.d,
          child: Widgets.touchable(
            context,
            onTap: () {
              cards = cards.reversed.toList();
              _sortByPower.value = !_sortByPower.value;
              if (_sortByPower.value) {
                _sortController.reverse(from: 0.5);
              } else {
                _sortController.forward(from: 0.0);
              }
            },
            child: Widgets.rect(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.d),
                  border: Border.all(color: TColors.primary50),
                  color: TColors.red20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkinnedText(
                    "sort_by_power".l(),
                    style: TStyles.small.copyWith(color: TColors.primary50),
                    hideStroke: true,
                  ),
                  SizedBox(
                    width: 20.d,
                  ),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0).animate(_sortController),
                    child: Asset.load<Image>("icon_arrow_down",
                        height: 28.d, width: 21.d),
                  ),
                ],
              ),
            ),
          ),
        ),
        PositionedDirectional(
            top: paddingTop,
            start: 20.d,
            width: 152.d,
            child: Widgets.touchable(context,
                child: Column(
                  children: [
                    Asset.load<Image>("icon_collection", height: 68.d),
                    SkinnedText(
                      "shop_card_collection".l(),
                      style: TStyles.small.copyWith(
                        color: TColors.primary20,
                      ),
                    ),
                  ],
                ),
                onTap: () =>
                    serviceLocator<RouteService>().to(Routes.popupCollection))),
        PositionedDirectional(
            top: paddingTop,
            width: 150.d,
            start: 180.d,
            child: Widgets.touchable(context,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Asset.load<Image>("icon_combo", height: 68.d),
                        state.account.level < levels["combo"]
                            ? RotationTransition(
                                turns: const AlwaysStoppedAnimation(-15 / 360),
                                child: Widgets.rect(
                                    color: TColors.primary20,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Asset.load<Image>("icon_exclude",
                                            height: 28.d, width: 21.d),
                                        SizedBox(
                                          width: 7.d,
                                        ),
                                        SkinnedText(
                                          "Level ${levels["combo"]}",
                                          style: TStyles.small
                                              .copyWith(color: TColors.white),
                                          hideStroke: true,
                                        ),
                                      ],
                                    )),
                              )
                            : const SizedBox()
                      ],
                    ),
                    SkinnedText(
                      "shop_card_combo".l(),
                      style: TStyles.small.copyWith(
                        color: TColors.primary20,
                      ),
                    ),
                  ],
                ), onTap: () {
              // Show unavailable message
              if (state.account.level < levels["combo"]) {
                Overlays.insert(
                    context,
                    ToastOverlay(
                      "unavailable_l".l(["popupcombo".l(), levels["combo"]]),
                    ));
              } else {
                serviceLocator<RouteService>().to(Routes.popupCombo);
              }
            }))
      ]);
    });
  }

  Widget? cardItemBuilder(
      BuildContext context, int index, AccountCard card, double itemSize) {
    return Widgets.touchable(
      context,
      onTap: () => serviceLocator<RouteService>()
          .to(Routes.popupCardDetails, args: {'card': card}),
      child: CardItem(card,
          size: itemSize,
          key: getGlobalKey(card.id),
          heroTag: "hero_${card.id}"),
    );
  }
}
