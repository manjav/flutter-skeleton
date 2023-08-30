import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ipopup.dart';

class CardUpgradePopup extends AbstractPopup {
  const CardUpgradePopup({super.key, required super.args})
      : super(Routes.popupCardUpgrade);

  @override
  createState() => _CardUpgradePopupState();
}

class _CardUpgradePopupState extends AbstractPopupState<CardUpgradePopup> {
  @override
  List<Widget> appBarElements() {
    return [
      Indicator(widget.type.name, AccountField.gold),
      Indicator(widget.type.name, AccountField.nectar, width: 300.d),
      Indicator(widget.type.name, AccountField.potion_number, width: 280.d),
    ];
  }

  @override
  Widget contentFactory() {
  }
}
