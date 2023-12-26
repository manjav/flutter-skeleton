import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/rpc.dart';
import '../../services/connection/http_connection.dart';
import '../../services/device_info.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import 'popup.dart';
import '../../view/widgets.dart';
import '../route_provider.dart';
import '../widgets/loader_widget.dart';

class ProfileAvatarsPopup extends AbstractPopup {
  ProfileAvatarsPopup({super.key}) : super(Routes.popupProfile, args: {});

  @override
  createState() => _ProfileAvatarsPopupState();
}

class _ProfileAvatarsPopupState
    extends AbstractPopupState<ProfileAvatarsPopup> {
  @override
  Widget titleTextFactory() => const SizedBox();
  @override
  BoxDecoration get chromeSkinBuilder =>
      Widgets.imageDecorator("popup_chrome_pink", ImageCenterSliceData(410, 460));

  @override
  EdgeInsets get contentPadding => EdgeInsets.fromLTRB(50.d, 180.d, 50.d, 80.d);

  @override
  Widget contentFactory() {
    var account = accountBloc.account!;
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // SkinnedText("profile_mood_title".l()),
          // SizedBox(height: 20.d),
          SizedBox(
              height: 700.d,
              child: GridView.builder(
                  itemCount: 20,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5),
                  itemBuilder: (c, i) => _avatarItemBuilder(account, i))),
        ]);
  }

  Widget? _avatarItemBuilder(Account account, int index) {
    var id = index;
    return Widgets.button(
      radius: 32.d,
      color: account.avatarId == id ? TColors.green : TColors.primary80,
      margin: EdgeInsets.all(8.d),
      padding: EdgeInsets.all(16.d),
      child: LoaderWidget(AssetType.image, "avatar_$id", subFolder: "avatars"),
      onPressed: () async {
        await getService<HttpConnection>()
            .tryRpc(context, RpcId.setProfileInfo, params: {"avatar_id": id});
        setState(() => account.avatarId = id);
        accountBloc.add(SetAccount(account: account));
      },
    );
  }
}
