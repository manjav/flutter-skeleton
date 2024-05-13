import 'package:flutter/material.dart';

import '../../app_export.dart';

class FreeGoldPopup extends AbstractPopup {
  const FreeGoldPopup({super.key}) : super(Routes.popupFreeGold);

  @override
  createState() => _RewardPopupState();
}

class _RewardPopupState extends AbstractPopupState<FreeGoldPopup> {
  @override
  contentFactory() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 30.d),
        LoaderWidget(
          AssetType.image,
          "shop_free_gold",
          subFolder: "shop",
          height: 464.d,
          width: 657.d,
        ),
        SizedBox(height: 40.d),
        Text(
          "popup_free_gold_description".l(),
          style: TStyles.medium.copyWith(
            color: TColors.primary20,
          ),
          textDirection: Localization.textDirection,
        ),
        SizedBox(height: 40.d),
        SkinnedButton(
            width: 440.d,
            label: "watch_ad".l(),
            color: ButtonColor.yellow,
            icon: "icon_show",
            onPressed: () {
              //show ads here
              serviceLocator<Ads>().show(AdType.rewarded);
              serviceLocator<RouteService>().back();
            }),
      ],
    );
  }
}
