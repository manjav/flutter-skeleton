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

  List<String> titles = [
    "Defense building",
    "Donate",
    "General tips",
    "League ranking",
    "League",
  ];

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
                      SkinnedText("Offence Building".l()),
                      SizedBox(
                        width: 15.d,
                      ),
                      Expanded(child: Asset.load<Image>("ui_divider_h_2")),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal:74.d,vertical: 60.d),
                      child: Text(
                        "You'll receive achievements for performing different action, some achievements give some sort of bom or reward Each achievement has a description of what you need to do to pot it.",
                        style:
                            TStyles.medium.copyWith(color: TColors.primary20),
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
                  ...titles.map((item) => Widgets.button(
                        context,
                        onPressed: () {},
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: TColors.primary90),
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.d, vertical: 10.d),
                        child: SkinnedText(item),
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
