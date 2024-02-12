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
    return SizedBox(
      height: 1360.d,
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          ..._renderSet(0, 21, 0),
          ..._renderSet(101, 109, 1),
          ..._renderSet(109, 223, 2),
        ],
      ),
    );
  }

  List<Widget> _renderSet(int start, int end, int index) {
    var account = accountProvider.account;
    var res = <Widget>[];
    res.add(SliverList(
      delegate: SliverChildListDelegate.fixed(
        [
          SizedBox(height: start > 0 ? 20.d : 0),
          Row(
            children: [
              Expanded(
                  child: Transform.flip(
                      flipX: true,
                      child: Asset.load<Image>(
                        "ui_divider_h_2",
                      ))),
              LoaderWidget(AssetType.image, "avatar_set_$index",
                  subFolder: "avatars", height: 110.d, width: 156.d),
              SizedBox(
                width: 8.d,
              ),
              SkinnedText("profile_set_${index + 1}".l()),
              SizedBox(
                width: 15.d,
              ),
              Expanded(child: Asset.load<Image>("ui_divider_h_2")),
            ],
          ),
          SizedBox(height: 20.d),
        ],
      ),
    ));
    res.add(SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 40.d),
      sliver: SliverGrid.builder(
        itemCount: end - start,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
        itemBuilder: (c, i) => _avatarItemBuilder(account, start + i),
      ),
    ));
    return res;
  }

  Widget? _avatarItemBuilder(Account account, int index) {
    var id = index;
    return Widgets.button(
      context,
      radius: 32.d,
      color: account.avatarId == id ? TColors.primary20 : TColors.primary80,
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
