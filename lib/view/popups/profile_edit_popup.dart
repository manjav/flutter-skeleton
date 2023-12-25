import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/rpc.dart';
import '../../services/connection/http_connection.dart';
import '../../services/device_info.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import 'popup.dart';
import '../../view/widgets.dart';
import '../route_provider.dart';
import '../widgets/loader_widget.dart';
import '../widgets/skinned_text.dart';

class ProfileEditPopup extends AbstractPopup {
  ProfileEditPopup({super.key}) : super(Routes.popupProfile, args: {});

  @override
  createState() => _ProfileEditPopupState();
}

class _ProfileEditPopupState extends AbstractPopupState<ProfileEditPopup> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget titleTextFactory() => const SizedBox();
  @override
  BoxDecoration get chromeSkinBuilder =>
      Widgets.imageDecore("popup_chrome_pink", ImageCenterSliceData(410, 460));

  @override
  EdgeInsets get contentPadding =>
      EdgeInsets.fromLTRB(122.d, 180.d, 122.d, 80.d);

  @override
  Widget contentFactory() {
    var account = accountBloc.account!;
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Widgets.skinnedInput(
              maxLines: 1,
              controller: _textController,
              hintText: account.name,
              onChange: (t) => setState(() {})),
          SizedBox(height: 12.d),
          Widgets.skinnedButton(
              isEnable: _textController.text.length >= 6 &&
                  _textController.text != account.name,
              height: 160.d,
              padding: EdgeInsets.fromLTRB(36.d, 16.d, 20.d, 29.d),
              child: Row(
                  textDirection: TextDirection.ltr,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkinnedText("profile_name_title".l(),
                        style: TStyles.large.copyWith(height: 3.d)),
                    SizedBox(width: 24.d),
                    Widgets.rect(
                      padding: EdgeInsets.only(right: 12.d),
                      decoration: Widgets.imageDecore(
                          "frame_hatch_button", ImageCenterSliceData(42)),
                      child: Row(textDirection: TextDirection.ltr, children: [
                        Asset.load<Image>("icon_nectar", height: 76.d),
                        SkinnedText("1000", style: TStyles.large),
                      ]),
                    )
                  ]),
              onPressed: () => _renameAccount(account)),
          Widgets.divider(width: 150.d, height: 18.d, margin: 30.d),
          SkinnedText("profile_mood_title".l()),
          SizedBox(height: 20.d),
          SizedBox(
              height: 600.d,
              child: GridView.builder(
                  itemCount: 20,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5),
                  itemBuilder: (c, i) => _moodItemBuilder(account, i))),
        ]);
  }

  _renameAccount(Account account) async {
    if (account.level < 100) {
      toast("profile_name_warn".l([
        account.loadingData.rules["changeNameMinLevel"],
        account.loadingData.rules["changeNameCost"]
      ]));
      return;
    }
    var result = await getService<HttpConnection>().tryRpc(
        context, RpcId.setProfileInfo,
        params: {"name": _textController.text});
    if (result["name_changed"]) {
      if (mounted) {
        account.name = _textController.text;
        account.update(context, result);
      }
      accountBloc.add(SetAccount(account: account));
    }
    // setState(() => account.name = id);
  }

  Widget? _moodItemBuilder(Account account, int index) {
    var id = index + 1;
    return Widgets.button(
      radius: 32.d,
      color: account.moodId == id ? TColors.green : TColors.primary80,
      margin: EdgeInsets.all(10.d),
      padding: EdgeInsets.all(20.d),
      child: LoaderWidget(AssetType.image, "mood_$id", subFolder: "moods"),
      onPressed: () async {
        await getService<HttpConnection>()
            .tryRpc(context, RpcId.setProfileInfo, params: {"mood_id": id});
        setState(() => account.moodId = id);
        accountBloc.add(SetAccount(account: account));
      },
    );
  }
}
