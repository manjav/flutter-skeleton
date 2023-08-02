import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../view/popups/ipopup.dart';
import '../route_provider.dart';

class PotionPopup extends AbstractPopup {
  const PotionPopup({super.key, required super.args})
      : super(Routes.popupPotion);

  @override
  createState() => _PotionPopupState();
}

class _PotionPopupState extends AbstractPopupState<PotionPopup> {
  @override
  contentFactory() {
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      var gold = state.account.get<int>(AccountField.bank_account_balance);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [],
      );
    });
  }
}
