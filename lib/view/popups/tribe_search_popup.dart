import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/account_bloc.dart';

import '../../blocs/services_bloc.dart';
import '../../data/core/building.dart';
import '../../data/core/rpc.dart';
import '../../data/core/tribe.dart';
import '../../services/connection/http_connection.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/popups/ipopup.dart';
import '../../view/widgets/skinnedtext.dart';
import '../route_provider.dart';
import '../widgets.dart';

class TribeSearchPopup extends AbstractPopup {
  TribeSearchPopup({super.key})
      : super(Routes.popupTribeSearch, args: {}, barrierDismissible: false);

  @override
  createState() => _TribeSearchPopupState();
}

class _TribeSearchPopupState extends AbstractPopupState<TribeSearchPopup> {
  List<Tribe> _tribes = [];
  final TextEditingController _inputController = TextEditingController();

  @override
  List<Widget> appBarElements() => [];
  @override
  Color get backgroundColor => TColors.transparent;
  @override
  EdgeInsets get chromeMargin => EdgeInsets.fromLTRB(24.d, 200.d, 24.d, 50.d);
  @override
  Widget closeButtonFactory() => const SizedBox();

  @override
  contentFactory() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          Expanded(
              child: Widgets.skinnedInput(
                  controller: _inputController, onChanged: (t) => _search())),
          SizedBox(width: 20.d),
          Widgets.skinnedButton(
              label: "search_l".l(),
              color: ButtonColor.green,
              onPressed: _search)
        ]),
        SizedBox(height: 30.d),
        _list()
      ],
    );
  }

  Widget _list() {
    return Expanded(
        child: ListView.builder(
            itemCount: _tribes.length, itemBuilder: _listItemBuilder));
  }

  Widget? _listItemBuilder(BuildContext context, int index) {
    var tribe = _tribes[index];
    return Widgets.button(
      margin: EdgeInsets.all(4.d),
      padding: EdgeInsets.all(22.d),
      decoration:
          Widgets.imageDecore("tribe_item_bg", ImageCenterSliceData(56, 56)),
      child: Column(children: [
        Row(
          children: [
            Widgets.rect(
                radius: 20.d,
                color: TColors.primary10,
                padding: EdgeInsets.fromLTRB(12.d, 6.d, 12.d, 6.d),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Asset.load<Image>("icon_score", width: 50.d),
                      SizedBox(width: 12.d),
                      SkinnedText(tribe.weeklyRank.compact())
                    ])),
            SizedBox(width: 18.d),
            Expanded(
                child:
                    SkinnedText(tribe.name, alignment: Alignment.centerLeft)),
            Widgets.rect(
                radius: 20.d,
                width: 210.d,
                color: TColors.primary10,
                padding: EdgeInsets.fromLTRB(12.d, 6.d, 12.d, 6.d),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Asset.load<Image>("icon_population", width: 50.d),
                      SkinnedText(
                          " ${tribe.population}/${tribe.getOption(Buildings.base.id)}")
                    ]))
          ],
        ),
        SizedBox(height: 12.d),
        Row(
          children: [
            Expanded(
                child: Text(tribe.description,
                    style: TStyles.medium.copyWith(height: 1))),
            IgnorePointer(
                ignoring: true,
                child: Widgets.skinnedButton(
                    height: 110.d,
                    width: 210.d,
                    padding: EdgeInsets.fromLTRB(28.d, 0, 28.d, 24.d),
                    color: ButtonColor.teal,
                    label: "join_l".l()))
          ],
        )
      ]),
      onPressed: () => _join(tribe),
    );
  }

  _search() async {
    try {
      var result = await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.tribeSearch,
              params: {RpcParams.query.name: _inputController.text});
      _tribes = Tribe.initAll(result["tribes"]);
      setState(() {});
    } finally {}
  }

  _join(Tribe tribe) async {
    try {
      var result = await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.tribeJoin,
              params: {RpcParams.tribe_id.name: tribe.id});
      if (mounted) {
        var bloc = BlocProvider.of<AccountBloc>(context);
        bloc.account!.map["tribe"] = Tribe(result["tribe"]);
        bloc.add(SetAccount(account: bloc.account!));
      }
    } finally {}
  }
}
