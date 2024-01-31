import 'package:flutter/material.dart';

import '../../app_export.dart';


class DailyGiftPopup extends AbstractPopup {
  const DailyGiftPopup({super.key}) : super(Routes.popupDailyGift);

  @override
  createState() => _RewardPopupState();
}

class _RewardPopupState extends AbstractPopupState<DailyGiftPopup> {
  static const int _length = 31;
  int _currentDay = 0, _baseReward = 0;
  double _itemWidth = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _itemWidth = 222.d;
    var account = accountProvider.account;
    _baseReward = account.dailyReward["base_gold"] ?? 1000;
    _currentDay = account.dailyReward["day_index"] ?? 30;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((d) {
      _scrollController.animateTo(_currentDay * _itemWidth - 300.d,
          duration: const Duration(seconds: 1), curve: Curves.easeOut);
    });
  }

  @override
  String titleBuilder() => "daily_gifts".l();
  @override
  Widget closeButtonFactory() => const SizedBox();

  int _calculateReward(int day) => ((day / 4).floor() + day) * _baseReward;

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
              controller: _scrollController,
              itemCount: _length,
              reverse: Localization.isRTL,
              scrollDirection: Axis.horizontal,
              itemBuilder: _daysItemBuilder,
            )),
        SizedBox(height: 40.d),
        SkinnedButton(
            width: 440.d,
            label: "claim_l".l(),
            color: ButtonColor.green,
            onPressed: (){
              Navigator.pop(context);
              Overlays.insert(context, const DailyRewardFeastOverlay());
            }),
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
    if (index == _currentDay) {
      title = "today_l".l();
    } else if (index >= _length - 1) {
      title = "+${30.convert()}";
    }

    var state = "current";
    if (index < _currentDay) {
      state = "passed";
    } else if (index > _currentDay) {
      state = "next";
    }

    return Widgets.rect(
        padding: EdgeInsets.only(right: mid == "last" ? 0 : 16.d),
        width: _itemWidth,
        decoration: Widgets.imageDecorator("daily_${mid}_$state",
            ImageCenterSliceData(98, 206, const Rect.fromLTWH(45, 19, 2, 2))),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Asset.load<Image>("daily_gold", width: 150.d),
            index == 2
                ? Align(
                    alignment: const Alignment(0.6, -0.3),
                    child: Asset.load<Image>("daily_card", width: 80.d))
                : const SizedBox(),
            Positioned(
                top: 24.d,
                child: SkinnedText(title, textDirection: TextDirection.ltr)),
            Positioned(
                bottom: 16.d,
                child: SkinnedText("+${_calculateReward(index + 1).compact()}",
                    textDirection: TextDirection.ltr)),
          ],
        ));
  }
}
