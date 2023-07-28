import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services.dart';
import '../../data/core/account.dart';
import '../../data/core/ranking.dart';
import '../../data/core/rpc.dart';
import '../../services/connection/http_connection.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/popups/ipopup.dart';
import '../../view/tab_provider.dart';
import '../../view/widgets/skinnedtext.dart';
import '../route_provider.dart';
import '../widgets.dart';

class RankingPopup extends AbstractPopup {
  const RankingPopup({super.key, required super.args})
      : super(Routes.popupRanking);

  @override
  createState() => _RankingPopupState();
}

class _RankingPopupState extends AbstractPopupState<RankingPopup>
    with TabProviderMixin {
  late Account _account;

  @override
  void initState() {
    selectedTabIndex = 0;
    contentPadding = EdgeInsets.fromLTRB(12.d, 176.d, 12.d, 64.d);
    _account = BlocProvider.of<AccountBloc>(context).account!;
    if (Ranks.lists.isEmpty) {
      Ranks.lists.addAll({
        RpcId.rankingGlobal: null,
        RpcId.rankingExpertTribes: null,
        RpcId.rankingTopTribes: null
      });
    }
    super.initState();
  }

  @override
  contentFactory() {
    return SizedBox(
        width: DeviceInfo.size.width * 0.95,
        height: DeviceInfo.size.height * 0.75,
        child: Column(
          children: [
            tabsBuilder(data: [
              for (var i = 0; i < 3; i++) TabData("rank_tab_$i".l()),
            ]),
            SizedBox(height: 32.d),
            _getSelectedPage(),
            SizedBox(height: 32.d),
          ],
        ));
  }

  Widget _getSelectedPage() {
    var api = Ranks.lists.keys.toList()[selectedTabIndex];
    // var icons = ["xp", "xp", "seed"];
    _loadRanking(api);
    return _listView(api);
  }

  _loadRanking(RpcId api) async {
    if (Ranks.lists[api] != null) return;
    try {
      var data = await BlocProvider.of<Services>(context)
          .get<HttpConnection>()
          .tryRpc(context, api);
      if (api == RpcId.rankingGlobal) {
        Ranks.lists[api] =
            Ranks.createList<Player>(data, _account.get<int>(AccountField.id));
      } else {
        Ranks.lists[api] =
            Ranks.createList<TribeRank>(data, _account.map["tribe"]["id"]);
      }
      setState(() {});
    } finally {}
  }

  _listView(RpcId api) {
    return Expanded(
        child: Ranks.lists[api] == null
            ? const SizedBox()
            : Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                    color: TColors.primary,
                    borderRadius: BorderRadius.all(Radius.circular(12.d))),
                child: ListView.builder(
                    padding: EdgeInsets.all(8.d),
                    itemBuilder: (c, i) => _itemBuilder(c, i, api),
                    itemCount: Ranks.lists[api]!.length)));
  }

  _itemBuilder(BuildContext context, int index, RpcId rpc) {
    Rank record = Ranks.lists[rpc]![index];
    if (record.name.isEmpty) {
      return SizedBox(height: 120.d, child: SkinnedText("rank_near".l()));
    }
    var color = index % 2 == 0 ? TColors.primary : TColors.primary90;
    if (record.itsMe) {
      color = TColors.orange;
      record.name = rpc == RpcId.rankingGlobal ? "You" : record.name;
    }
    var rank = rpc == RpcId.rankingTopTribes
        ? (record as TribeRank).weeklyRank
        : record.rank;
    var score = rpc == RpcId.rankingTopTribes
        ? (record as TribeRank).weeklyScore
        : record.score;

    return Widgets.button(
        height: 100.d,
        radius: 24.d,
        color: color,
        padding: EdgeInsets.only(left: 8.d, right: 16.d),
        child: Row(children: [
          Widgets.rect(
              radius: 24.d,
              width: 144.d,
              height: 76.d,
              alignment: Alignment.center,
              color: rank < 4 ? TColors.transparent : TColors.primary20,
              child: rank < 4
                  ? Asset.load<Image>("medal_$rank")
                  : Text('$rank', style: TStyles.smallInvert)),
          SizedBox(width: 16.d),
          Expanded(child: Text(record.name, style: TStyles.tiny)),
          SizedBox(width: 4.d),
          SizedBox(
              width: 220.d,
              child: rpc == RpcId.rankingGlobal
                  ? Text((record as Player).tribeName,
                      style: TStyles.small, textAlign: TextAlign.center)
                  : null),
          SizedBox(width: 79.d),
          Text(score.compact(), style: TStyles.small),
        ]),
        onPressed: () async {
          if (!record.itsMe) {
            // var accounts = await _network.getAccounts([record.ownerId]);
            // if (mounted) {
            //   Navigator.pushNamed(context, Pages.profile.routeName,
            //       arguments: accounts[0]);
            // }
          }
        });
  }
}
