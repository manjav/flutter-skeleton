import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
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
  late Account _account;
  List<Tribe> _tribes = [];

  @override
  void initState() {
    _account = BlocProvider.of<AccountBloc>(context).account!;
    super.initState();
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
          Expanded(child: Widgets.skinnedInput()),
          SizedBox(width: 20.d),
          Widgets.skinnedButton(label: "search_l".l(), color: ButtonColor.green)
        ]),
        SizedBox(height: 30.d),
        _list()
      ],
    );
  }

  Widget _list() {
    return Expanded(
        child: _tribes.isEmpty
            ? Center(child: SkinnedText("not_found".l()))
            : ListView.builder(
                itemCount: _tribes.length, itemBuilder: _listItemBuilder));
  }

  Widget? _listItemBuilder(BuildContext context, int index) {
    return Widgets.button(
        child: Column(
      children: [
        Row(
          children: [],
        ),
        Row(
          children: [],
        )
      ],
    ));
  }
}

class Tribe {}
