import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/popups/ipopup.dart';
import '../../view/tab_provider.dart';
import '../../view/widgets/loaderwidget.dart';
import '../route_provider.dart';

class LeaguePopup extends AbstractPopup {
  const LeaguePopup({super.key, required super.args})
      : super(Routes.popupLeague);

  @override
  createState() => _LeaguePopupState();
}

class _LeaguePopupState extends AbstractPopupState<LeaguePopup>
    with TabProviderMixin {
  late Account _account;

  @override
  void initState() {
    contentPadding = EdgeInsets.fromLTRB(12.d, 176.d, 12.d, 64.d);
    _account = BlocProvider.of<AccountBloc>(context).account!;
    super.initState();
  }

  @override
  Widget contentFactory() {
    return SizedBox(
        width: DeviceInfo.size.width * 0.95,
        height: DeviceInfo.size.height * 0.75,
        child: Column(
          children: [
            tabsBuilder(data: [
              for (var i = 0; i < 3; i++) TabData("league_tab_$i".l()),
            ]),
            Expanded(child: _getSelectedPage())
          ],
        ));
  }

  Widget _getSelectedPage() {
    return switch (selectedTabIndex) {
      0 => _myLeaguePage(),
      1 => _roadMap(),
      _ => _historyPage(),
    };
  }

  Widget _myLeaguePage() {
    return const SizedBox();
  }

  Widget _roadMap() {
    return Padding(
        padding: EdgeInsets.all(24.d),
        child: Stack(
          children: [
            Positioned(
                top: 100.d,
                left: 0,
                right: 0,
                bottom: 0,
                child: const LoaderWidget(AssetType.image, "league_roadmap")),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("league_bonus_current".l(), style: TStyles.small),
              Text("league_bonus_next".l(), style: TStyles.small)
            ]),
            Positioned(
                top: 50.d,
                right: 0,
                left: 0,
                child: Row(children: [
                  Asset.load<Image>("icon_gold", width: 60.d),
                  Text("  ${_account.get<int>(AccountField.rank)}"),
                  const Expanded(child: SizedBox()),
                  Asset.load<Image>("icon_gold", width: 60.d),
                  Text("  ${_account.get<int>(AccountField.rank)}"),
                ])),
          ],
        ));
  }

  Widget _historyPage() {
    return const SizedBox();
  }
}
