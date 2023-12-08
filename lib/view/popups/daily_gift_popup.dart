import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton/utils/utils.dart';
import 'package:flutter_skeleton/view/widgets/skinnedtext.dart';

import '../../data/core/account.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/popups/ipopup.dart';
import '../route_provider.dart';
import '../widgets.dart';

class DailyGiftPopup extends AbstractPopup {
  DailyGiftPopup({super.key}) : super(Routes.popupDailyGift, args: {});

  @override
  createState() => _RewardPopupState();
}

class _RewardPopupState extends AbstractPopupState<DailyGiftPopup> {
  static int _giftIndex = 0;
  static const int _length = 31;

  @override
  void initState() {
    _giftIndex = 3;
    super.initState();
  }

  @override
  String titleBuilder() => "daily_gifts".l();

  @override
  contentFactory() {
    var style = TStyles.medium.copyWith(height: 1);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 30.d),
        Text("daily_gift_message".l(), style: style),
        SizedBox(height: 50.d),
        SizedBox(
            height: 380.d,
            child: ListView.builder(
              itemCount: _length,
              reverse: Localization.isRTL,
              scrollDirection: Axis.horizontal,
              itemBuilder: _daysItemBuilder,
            )),
        SizedBox(height: 40.d),
        Widgets.skinnedButton(
            label: "claim_l".l(), color: ButtonColor.green, width: 440.d),
      ],
    );
  }

  Widget? _daysItemBuilder(BuildContext context, int index) {
    var mid = switch (index) {
      < 1 => "first",
      >= _length - 1 => "last",
      _ => "mid",
    };

    var title = "day_l".l([(index + 1).convert()]);
    if (index == _giftIndex) {
      title = "today_l".l();
    } else if (index >= _length - 1) {
      title = "+${30.convert()}";
    }

    var state = "current";
    if (index < _giftIndex) {
      state = "passed";
    } else if (index > _giftIndex) {
      state = "next";
    }

    return Widgets.button(
        padding: EdgeInsets.only(right: mid == "last" ? 0 : 16.d),
        width: 222.d,
        decoration: Widgets.imageDecore("daily_${mid}_$state",
            ImageCenterSliceData(98, 206, const Rect.fromLTWH(44, 19, 2, 2))),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Asset.load<Image>("daily_gold", width: 150.d),
            Align(
                alignment: const Alignment(0.6, -0.3),
                child: Asset.load<Image>("daily_card", width: 80.d)),
            Positioned(
                top: 24.d,
                child: SkinnedText(title, textDirection: TextDirection.ltr)),
            Positioned(
                bottom: 16.d,
                child: SkinnedText("+${1213.compact()}",
                    textDirection: TextDirection.ltr)),
          ],
        ));
  }
}
