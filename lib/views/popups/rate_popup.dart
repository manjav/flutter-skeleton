import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

import '../../app_export.dart';

class RatePopup extends AbstractPopup {
  const RatePopup({super.key}) : super(Routes.popupRate);

  @override
  createState() => _RatePopupState();
}

class _RatePopupState extends AbstractPopupState<RatePopup> {
  final ValueNotifier<int> _rate = ValueNotifier(0);

  @override
  EdgeInsets get contentPadding => EdgeInsets.fromLTRB(48.d, 132.d, 48.d, 30.d);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _rate.value = 5;
    });
  }

  @override
  contentFactory() {
    return SizedBox(
      width: 920.d,
      height: DeviceInfo.size.height * 0.30,
      child: ValueListenableBuilder(
          valueListenable: _rate,
          builder: (context, value, child) {
            return Column(children: [
              SizedBox(
                height: 91.d,
              ),
              SkinnedText(
                "rating_message".l(),
                hideStroke: true,
              ),
              SizedBox(
                height: 91.d,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 140.d),
                child: ValueListenableBuilder<int>(
                  valueListenable: _rate,
                  builder: (context, value, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ...List.generate(
                          5,
                          (index) => GestureDetector(
                            onTap: () {
                              _rate.value = index + 1;
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Asset.load<Image>("icon_star_rate_outline",
                                    height: 100.d, width: 100.d),
                                _rate.value > index
                                    ? Asset.load<Image>("icon_star_rate",
                                            height: 90.d, width: 90.d)
                                        .animate()
                                        .fade(
                                            duration: 300.ms,
                                            delay: (index * 100).ms)
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 100.d),
              SizedBox(
                  height: 160.d,
                  child: Row(
                      textDirection: TextDirection.ltr,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SkinnedButton(
                            color: ButtonColor.cream,
                            label: "maybe_later".l(),
                            width: 340.d,
                            padding: EdgeInsets.only(bottom: 12.d),
                            onPressed: () => Navigator.pop(context)),
                        SizedBox(width: 36.d),
                        SkinnedButton(
                            label: "rate_now".l(),
                            width: 340.d,
                            color: ButtonColor.green,
                            padding: EdgeInsets.only(bottom: 16.d),
                            onPressed: _submit),
                      ])),
            ]);
          }),
    );
  }

  _submit() async {
    try {
      if (_rate.value < 4) {
        return;
      }

      final storeId = FlavorConfig.instance.variables["storeId"];
      final storePackageName =
          FlavorConfig.instance.variables["storePackageName"];
      final url = storeId == "4"
          ? "bazaar://details?id=${DeviceInfo.packageName}"
          : "myket://comment?id=${DeviceInfo.packageName}";

      if (Platform.isAndroid) {
        AndroidIntent intent = AndroidIntent(
            action: 'action_view', data: url, package: storePackageName);
        intent.launch();

        Pref.rated.setBool(true);

        serviceLocator<RouteService>().back();
      }
    } catch (e) {
      rethrow;
    }
  }
}
