import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../app_export.dart';

class HelpPopup extends AbstractPopup {
  const HelpPopup({super.key}) : super(Routes.popupProfile);

  @override
  createState() => _HelpPopupState();
}

class _HelpPopupState extends AbstractPopupState<HelpPopup> {
  @override
  Widget titleTextFactory() => const SizedBox();

  @override
  BoxDecoration get chromeSkinBuilder => Widgets.imageDecorator(
      "popup_chrome_pink", ImageCenterSliceData(410, 460));

  @override
  EdgeInsets get contentPadding => EdgeInsets.fromLTRB(0.d, 180.d, 0.d, 40.d);

  List<Map<String, String>> fullHelpChunks = [
    {
      "name": "rewards".l(),
      "description": "rewards_full_help".l(),
    },
    {
      "name": "achievements".l(),
      "description": "achievements_full_help".l(),
    },
    {
      "name": "User Account".l(),
      "description": "User Account full help".l(),
    },
    {
      "name": "Tribe Members".l(),
      "description": "Tribe Members full help".l(),
    },
    {
      "name": "Tribe Upgrade".l(),
      "description": "Tribe Upgrade full help".l(),
    },
    {
      "name": "Edit Tribe".l(),
      "description": "Edit Tribe full help".l(),
    },
    {
      "name": "Shop".l(),
      "description": "Shop full help".l(),
    },
    {
      "name": "General Tips".l(),
      "description": "General Tips full help".l(),
    },
    {
      "name": "Rankings".l(),
      "description": "Player Rankings full help".l(),
    },
    {
      "name": "Tribe Rankings".l(),
      "description": "Tribe Rankings full help".l(),
    },
    {
      "name": "Notifications".l(),
      "description": "Notifications full help".l(),
    },
    {
      "name": "Tribe Chat".l(),
      "description": "Tribe Chat full help".l(),
    },
    {
      "name": "Battle".l(),
      "description": "Battle full help".l(),
    },
    {
      "name": "Quest".l(),
      "description": "Quest full help".l(),
    },
    {
      "name": "Battle Results".l(),
      "description": "Battle Results full help".l(),
    },
    {
      "name": "Cards".l(),
      "description": "Cards full help".l(),
    },
    {
      "name": "Gold Building".l(),
      "description": "Gold Building full help".l(),
    },
    {
      "name": "Building Cards".l(),
      "description": "Building Cards full help".l(),
    },
    {
      "name": "Enhance".l(),
      "description": "Enhance Cards full help".l(),
    },
    {
      "name": "Collection".l(),
      "description": "Collection Cards full help".l(),
    },
    {
      "name": "Evolve".l(),
      "description": "Evolve Cards full help".l(),
    },
    {
      "name": "Offense Building".l(),
      "description": "Offense Building full help".l(),
    },
    {
      "name": "Defense Building".l(),
      "description": "Defense Building full help".l(),
    },
    {
      "name": "Donate".l(),
      "description": "Donate full help".l(),
    },
    {
      "name": "Bank".l(),
      "description": "Bank full help".l(),
    },
    {
      "name": "League Ranking".l(),
      "description": "League Ranking full help".l(),
    },
    {
      "name": "League".l(),
      "description": "League full help".l(),
    },
    {
      "name": "League History".l(),
      "description": "League History full help".l(),
    },
    {
      "name": "Bonus Time".l(),
      "description": "Bonus Time full help".l(),
    },
    {
      "name": "Live Battle".l(),
      "description": "Live Battle full help".l(),
    },
    {
      "name": "Profile".l(),
      "description": "Profile full help".l(),
    },
    {
      "name": "Boosts Packs".l(),
      "description": "Boosts Packs full help".l(),
    },
    {
      "name": "Combo".l(),
      "description": "Combo Help".l(),
    },
    {
      "name": "Lab Building".l(),
      "description": "Lab Full Help".l(),
    },
    {
      "name": "School".l(),
      "description": "School Full Help".l(),
    },
    {
      "name": "Heroes".l(),
      "description": "Heroes Full Help".l(),
    },
    {
      "name": "Tribe".l(),
      "description": "Tribe Status Help".l(),
    },
  ];

  ValueNotifier<String> selectedTitle = ValueNotifier("");
  ValueNotifier<String> selectedDescription = ValueNotifier("");

  @override
  Widget contentFactory() {
    return SizedBox(
      height: 1300.d,
      child: Column(
        children: [
          SizedBox(
              height: 600.d,
              child: Widgets.rect(
                  child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Transform.flip(
                              flipX: true,
                              child: Asset.load<Image>(
                                "ui_divider_h_2",
                              ))),
                      SizedBox(
                        width: 8.d,
                      ),
                      ValueListenableBuilder(
                        valueListenable: selectedTitle,
                        builder: (context, value, child) => SkinnedText(value),
                      ),
                      SizedBox(
                        width: 15.d,
                      ),
                      Expanded(child: Asset.load<Image>("ui_divider_h_2")),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 74.d, vertical: 60.d),
                      child: ValueListenableBuilder(
                        valueListenable: selectedDescription,
                        builder: (context, value, child) => SkinnedText(
                          value,
                          style:
                              TStyles.medium.copyWith(color: TColors.primary20),
                          hideStroke: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ))),
          Expanded(
              child: Widgets.rect(
            color: TColors.primary,
            width: 980.d,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(100.d)),
            padding: EdgeInsets.all(20.d),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 20.d,
                runSpacing: 20.d,
                children: [
                  ...fullHelpChunks.map((item) => Widgets.button(
                        context,
                        onPressed: () {
                          selectedTitle.value = item["name"]!;
                          selectedDescription.value = item["description"]!;
                        },
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: TColors.primary90),
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.d, vertical: 10.d),
                        child: SkinnedText(item["name"]!),
                      )),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}
