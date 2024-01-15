import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../../skeleton/skeleton.dart';

class TribeSearchPopup extends AbstractPopup {
  TribeSearchPopup({super.key}) : super(Routes.popupTribeSearch, args: {});

  @override
  createState() => _TribeSearchPopupState();
}

class _TribeSearchPopupState extends AbstractPopupState<TribeSearchPopup> {
  List<Tribe> _tribes = [];
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    barrierDismissible = false;
  }

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
                  maxLines: 1,
                  controller: _inputController,
                  onSubmit: (t) => _search())),
          SizedBox(width: 20.d),
          Widgets.skinnedButton(context,
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
      context,
      margin: EdgeInsets.all(4.d),
      padding: EdgeInsets.all(22.d),
      decoration:
          Widgets.imageDecorator("tribe_item_bg", ImageCenterSliceData(56, 56)),
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
                          " ${tribe.population}/${tribe.getOption(Buildings.tribe.id)}")
                    ]))
          ],
        ),
        SizedBox(height: 12.d),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
              child: Text("${tribe.description}\n",
                  textDirection: tribe.description.getDirection(),
                  style: TStyles.medium.copyWith(height: 1))),
          SizedBox(width: 12.d),
          Widgets.rect(
              height: 120.d,
              width: 210.d,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 24.d),
              decoration: Widgets.buttonDecorator(_actionColorBuilder(tribe)),
              child: SkinnedText(
                  textAlign: TextAlign.center,
                  style: TStyles.medium.copyWith(height: 1),
                  _actionTitleBuilder(tribe)))
        ]),
      ]),
      onPressed: () => _join(tribe),
    );
  }

  _search() async {
    try {
      var result = await rpc(RpcId.tribeSearch,
          params: {RpcParams.query.name: _inputController.text});
      _tribes = Tribe.initAll(result["tribes"]);
      setState(() {});
    } finally {}
  }

  _join(Tribe tribe) async {
    try {
      var result = await rpc(RpcId.tribeJoin,
          params: {RpcParams.tribe_id.name: tribe.id});
      if (tribe.status == 2) {
        setState(() => tribe.status = 0);
      } else {
        if (mounted) {
          accountProvider.installTribe(result["tribe"]);
        }
      }
    } finally {}
  }

  String _actionTitleBuilder(tribe) {
    return switch (tribe.status) {
      0 => "requested_l",
      2 => "request_l",
      _ => "join_l",
    }
        .l();
  }

  ButtonColor _actionColorBuilder(Tribe tribe) {
    return switch (tribe.status) {
      1 => ButtonColor.teal,
      2 => ButtonColor.green,
      _ => ButtonColor.gray,
    };
  }
}
