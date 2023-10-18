import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton/data/core/account.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/message.dart';
import '../../services/deviceinfo.dart';
import '../../services/theme.dart';
import '../../utils/utils.dart';
import '../../view/popups/ipopup.dart';
import '../route_provider.dart';
import '../widgets.dart';

class ProfilePopup extends AbstractPopup {
  ProfilePopup({super.key}) : super(Routes.popupProfile, args: {});

  @override
  createState() => _ProfilePopupState();
}

class _ProfilePopupState extends AbstractPopupState<ProfilePopup> {
  @override
  void initState() {
    super.initState();
  }

  // _loadMessages() async {
  //   // await getService<Profile>().initialize(args: [context, accountBloc.account!]);
  //   setState(() {});
  // }

  @override
  contentFactory() {
    var titleStyle = TStyles.small.copyWith(color: TColors.primary30);
    var now = DateTime.now().secondsSinceEpoch;

    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      return SizedBox(
          height: DeviceInfo.size.height * 0.7,
          child: Column(
            children: [_headerBuilder(state.account)],
          ));
    });
  }

  Widget _headerBuilder(Account account) {
    return Widgets.rect(
        decoration: Widgets.buttonDecore(ButtonColor.cream, ButtonSize.small),
        height: 122);
  }
}
