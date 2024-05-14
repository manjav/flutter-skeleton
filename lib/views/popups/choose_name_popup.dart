import 'package:flutter/material.dart';

import '../../app_export.dart';

class ChooseNamePopup extends AbstractPopup {
  const ChooseNamePopup({super.key}) : super(Routes.popupChooseName);

  @override
  createState() => _ChooseNamePopupState();
}

class _ChooseNamePopupState extends AbstractPopupState<ChooseNamePopup> {
  @override
  BoxDecoration get chromeSkinBuilder => Widgets.imageDecorator(
      "popup_chrome_pink", ImageCenterSliceData(410, 460));

  late TextEditingController _textController;

  @override
  void initState() {
    _textController = TextEditingController();
    barrierDismissible = canPop = false;
    super.initState();
  }

  @override
  closeButtonFactory() {
    return const SizedBox();
  }

  @override
  contentFactory() {
    var items = <Widget>[];

    items.addAll([
      StreamBuilder<bool>(
          stream: showError.stream,
          builder: (context, snapshot) {
            return Widgets.skinnedInput(
                maxLines: 1,
                controller: _textController,
                hintText: "choose_name_hint".l(),
                borderColor: showError.value == true ? TColors.red : null,
                onChange: (t) => setState(() {}));
          }),
      StreamBuilder<bool>(
        stream: showError.stream,
        builder: (ctx, snapshot) {
          if (!snapshot.hasData || !snapshot.data!) {
            return const SizedBox();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.d),
              SkinnedText(
                "profile_name_error".l(),
                style: TStyles.medium.copyWith(height: 3.d, color: TColors.red),
                hideStroke: true,
              ),
              SizedBox(height: 15.d),
              SkinnedText(
                "profile_name_suggest".l(),
                style: TStyles.medium
                    .copyWith(height: 3.d, color: TColors.primary20),
                hideStroke: true,
              ),
              StreamBuilder(
                  stream: selectedName.stream,
                  builder: (ctx, snapshot) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15.d),
                        ...suggests.take(3).map((name) => Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Widgets.button(
                                  context,
                                  padding: EdgeInsets.zero,
                                  margin: EdgeInsets.only(bottom: 15.d),
                                  onPressed: () {
                                    selectedName.value = name;
                                    _textController.text = name;
                                  },
                                  child: Row(
                                    children: [
                                      Asset.load<Image>(
                                          "checkbox_${selectedName.value == name ? "on" : "off"}",
                                          width: 64.d),
                                      SizedBox(width: 12.d),
                                      SkinnedText(
                                        name,
                                        style: TStyles.medium
                                            .copyWith(color: TColors.primary20),
                                        hideStroke: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                        SizedBox(height: 15.d),
                      ],
                    );
                  }),
            ],
          );
        },
      ),
      SizedBox(height: 30.d),
      SkinnedButton(
          width: 700.d,
          color: ButtonColor.green,
          label: "confirm_l".l(),
          isEnable: _textController.text.isNotEmpty,
          onPressed: _setName)
    ]);
    return SizedBox(
        child: Column(mainAxisSize: MainAxisSize.min, children: items));
  }

  _setName() async {
    try {
      await serviceLocator<HttpConnection>().tryRpc(
          context, RpcId.setProfileInfo,
          params: {"name": _textController.text});
      accountProvider.account.name = _textController.text;
      accountProvider.account.is_name_temp = false;
      accountProvider.update();

      serviceLocator<RouteService>().popUntil((route) => route.isFirst);
      services.changeState(ServiceStatus.changeTab, data: {"index": 2});
    } catch (e) {
      log(e.toString());
    }
  }
}
