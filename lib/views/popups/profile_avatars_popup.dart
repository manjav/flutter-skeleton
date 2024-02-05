import 'package:flutter/material.dart';

import '../../app_export.dart';

class ProfileAvatarsPopup extends AbstractPopup {
  const ProfileAvatarsPopup({super.key}) : super(Routes.popupProfile);

  @override
  createState() => _ProfileAvatarsPopupState();
}

class _ProfileAvatarsPopupState
    extends AbstractPopupState<ProfileAvatarsPopup> {
  @override
  Widget titleTextFactory() => const SizedBox();

  @override
  BoxDecoration get chromeSkinBuilder => Widgets.imageDecorator(
      "popup_chrome_pink", ImageCenterSliceData(410, 460));

  @override
  EdgeInsets get contentPadding => EdgeInsets.fromLTRB(50.d, 180.d, 50.d, 80.d);

  @override
  Widget contentFactory() {
    var account = accountProvider.account;
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
      context,
      radius: 32.d,
      color: account.avatarId == id ? TColors.green : TColors.primary80,
      margin: EdgeInsets.all(8.d),
      padding: EdgeInsets.all(16.d),
      child: LoaderWidget(AssetType.image, "avatar_$id", subFolder: "avatars"),
      onPressed: () async {
        await serviceLocator<HttpConnection>()
            .tryRpc(context, RpcId.setProfileInfo, params: {"avatar_id": id});
        setState(() => account.avatarId = id);
        accountProvider.update();
      },
    );
  }
}
