import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/ranking.dart';
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
import '../widgets/loaderwidget.dart';

class TribeMembersPopup extends AbstractPopup {
  TribeMembersPopup({super.key}) : super(Routes.popupTribeMembers, args: {});

  @override
  createState() => _TribeMembersPopupState();
}

class _TribeMembersPopupState extends AbstractPopupState<TribeMembersPopup> {
  late Account _account;
  Member? _member;
  List<Member> _members = [];

  @override
  void initState() {
    _account = BlocProvider.of<AccountBloc>(context).account!;
    _loadMembers();
    var index = _members.indexWhere((member) => member.itsMe);
    if (index > -1) {
      _member = _members[index];
    } else {
      var id = _account.get<int>(AccountField.id);
      _member = Member.init({"id": id}, id);
    }

    super.initState();
  }

  _loadMembers() async {
    try {
      var result = await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .rpc(RpcId.tribeMembers, params: {"coach_tribe": false});
      _members =
          Member.initAll(result["members"], _account.get<int>(AccountField.id));
      setState(() {});
    } finally {}
  }

  @override
  Widget contentFactory() {
    var tribe = _account.get<Tribe>(AccountField.tribe);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 30.d),
        Row(children: [
          CupertinoSwitch(
              value: _member!.status == 1, onChanged: _changeVisibility),
          Asset.load<Image>("tribe_visibility", width: 44.d),
          SizedBox(width: 12.d),
          Text("tribe_visibility".l()),
          const Expanded(child: SizedBox()),
          _indicator(
              "icon_population", "${tribe.population}/${tribe.capacity}", 40.d),
        ]),
        SizedBox(height: 20.d),
        Widgets.skinnedButton(
            color: ButtonColor.teal,
            label: "tribe_invite".l(),
            icon: "tribe_invite",
            onPressed: () => Navigator.of(context)
                .pushNamed(Routes.popupTribeInvite.routeName)),
        SizedBox(height: 20.d),
        _list()
      ],
    );
  }

  Widget _list() {
    return SizedBox(
        height: 1200.d,
        child: _members.isEmpty
            ? Center(child: SkinnedText("not_found".l()))
            : ListView.builder(
                itemCount: _members.length, itemBuilder: _listItemBuilder));
  }

  Widget? _listItemBuilder(BuildContext context, int index) {
    var member = _members[index];
    return Widgets.button(
        height: 160.d,
        margin: EdgeInsets.all(4.d),
        padding: EdgeInsets.all(22.d),
        decoration:
            Widgets.imageDecore("tribe_item_bg", ImageCenterSliceData(56)),
        child: Row(children: [
          Widgets.rect(
              radius: 24.d,
              padding: EdgeInsets.all(6.d),
              decoration: Widgets.imageDecore(
                  "ui_frame_inside", ImageCenterSliceData(42)),
              child: LoaderWidget(AssetType.image, "avatar_${member.avatarId}",
                  width: 88.d, height: 88.d, subFolder: "avatars")),
          SizedBox(width: 20.d),
          Column(
              // mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkinnedText(member.name),
                Text("tribe_degree_${member.degree}".l(), style: TStyles.small),
              ]),
          const Expanded(child: SizedBox()),
          _indicator("icon_score", member.rank.compact(), 60.d,
              EdgeInsets.only(right: 16.d))
        ]));
  }

  Widget _indicator(String icon, String label, double iconSize,
      [EdgeInsetsGeometry? padding]) {
    return Widgets.rect(
        height: 64.d,
        padding: padding ?? EdgeInsets.only(left: 16.d, right: 16.d),
        decoration:
            Widgets.imageDecore("ui_frame_inside", ImageCenterSliceData(42)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Asset.load<Image>(icon, height: iconSize),
          SizedBox(width: 12.d),
          SkinnedText(label)
        ]));
  }

  void _changeVisibility(bool value) {
    var newStatus = value ? 1 : 3;
    try {
      BlocProvider.of<ServicesBloc>(context).get<HttpConnection>().rpc(
          RpcId.tribeVisibility,
          params: {RpcParams.status.name: newStatus});
      setState(() => _member!.status = newStatus);
    } finally {}
  }
}
