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
      Widgets.skinnedInput(
          maxLines: 1,
          controller: _textController,
          hintText: "choose_name_hint".l(),
          onChange: (t) => setState(() {})),
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
      accountProvider.update();
    } catch(e){
       log(e.toString());
    }
  }
}
