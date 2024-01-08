import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/core/account.dart';
import '../../data/core/adam.dart';
import '../../data/core/rpc.dart';
import '../../services/device_info.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../overlays/overlay.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/skinned_text.dart';
import 'popup.dart';

class TribeEditPopup extends AbstractPopup {
  TribeEditPopup({super.key}) : super(Routes.popupTribeEdit, args: {});

  @override
  createState() => _TribeEditPopupState();
}

class _TribeEditPopupState extends AbstractPopupState<TribeEditPopup> {
  int status = -1;
  late Account _account;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    _account = accountBloc.account!;
    if (_account.tribe != null && _account.tribe!.id < 0) _account.tribe = null;
    if (_account.tribe != null) {
      _nameController.text = _account.tribe!.name;
      _descriptionController.text = _account.tribe!.description;
      status = _account.tribe!.status - 1;
    }
    _nameController.addListener(() => setState(() {}));
    _descriptionController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  String titleBuilder() =>
      _account.tribe == null ? "tribe_new".l() : "tribe_edit".l();

  @override
  contentFactory() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SkinnedText("name_l".l()),
        Widgets.skinnedInput(
            maxLines: 1,
            maxLength: 30,
            controller: _nameController,
            width: 650.d),
      ]),
      SizedBox(height: 20.d),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SkinnedText("description_l".l()),
        Widgets.skinnedInput(
            maxLines: 4,
            width: 650.d,
            maxLength: 155,
            controller: _descriptionController),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SkinnedText("status_l".l()),
        Widgets.button(context,
            padding: EdgeInsets.all(22.d),
            width: 120.d,
            height: 120.d,
            onPressed: () => setState(() => status = (status - 1) % 3),
            child: Asset.load<Image>(
                "arrow_${Localization.isRTL ? "right" : "left"}")),
        SkinnedText("tribe_stats_$status".l()),
        Widgets.button(context,
            padding: EdgeInsets.all(22.d),
            width: 120.d,
            height: 120.d,
            onPressed: () => setState(() => status = (status + 1) % 3),
            child: Asset.load<Image>(
                "arrow_${Localization.isRTL ? "left" : "right"}")),
      ]),
      SizedBox(height: 24.d),
      Text("tribe_help_${_account.tribe == null ? "new" : "edit"}".l(),
          style: TStyles.medium.copyWith(height: 1)),
      SizedBox(height: 32.d),
      _submitButton()
    ]);
  }

  Widget _submitButton() {
    var isNew = _account.tribe == null;
    var cost = isNew ? 15000 : 0;
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Widgets.skinnedButton(context,
              height: 160.d,
              isEnable:
                  _account.tribePosition.index >= TribePosition.elder.index &&
                      _nameController.text.isNotEmpty &&
                      _descriptionController.text.isNotEmpty &&
                      cost <= _account.gold,
              color: ButtonColor.green,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 8.d),
                    SkinnedText(titleBuilder(),
                        style: TStyles.large.copyWith(height: 3.d)),
                    SizedBox(width: isNew ? 24.d : 0),
                    isNew
                        ? Widgets.rect(
                            padding: EdgeInsets.symmetric(
                                vertical: 6.d, horizontal: 12.d),
                            decoration: Widgets.imageDecorator(
                                "frame_hatch_button", ImageCenterSliceData(42)),
                            child: Row(children: [
                              Asset.load<Image>("icon_gold", height: 76.d),
                              SkinnedText(15000.compact(),
                                  style: TStyles.large),
                            ]))
                        : const SizedBox()
                  ]),
              onPressed: () => _submit(),
              onDisablePressed: () {
                var message = "fill_requirements_l";
                if (_account.tribePosition.index < TribePosition.elder.index) {
                  message = "error_211".l();
                } else if (cost > _account.gold) {
                  message = "error_183".l();
                }
                Overlays.insert(context, OverlayType.toast, args: message);
              })
        ]);
  }

  _submit() async {
    var params = {
      RpcParams.name.name: _nameController.text,
      RpcParams.description.name: _descriptionController.text,
      RpcParams.status.name: status + 1,
    };
    if (_account.tribe != null) {
      params[RpcParams.tribe_id.name] = _account.tribe!.id;
    }
    try {
      await rpc(_account.tribe == null ? RpcId.tribeCreate : RpcId.tribeEdit,
          params: params);
      _account.tribe!.name = _nameController.text;
      _account.tribe!.description = _descriptionController.text;
      _account.tribe!.status = status + 1;
      if (mounted) {
        Navigator.pop(context, true);
      }
    } finally {}
  }
}
