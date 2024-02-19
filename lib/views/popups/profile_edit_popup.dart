import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class ProfileEditPopup extends AbstractPopup {
  const ProfileEditPopup({super.key}) : super(Routes.popupProfile);

  @override
  createState() => _ProfileEditPopupState();
}

class _ProfileEditPopupState extends AbstractPopupState<ProfileEditPopup> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget titleTextFactory() => const SizedBox();
  @override
  BoxDecoration get chromeSkinBuilder => Widgets.imageDecorator(
      "popup_chrome_pink", ImageCenterSliceData(410, 460));

  @override
  EdgeInsets get contentPadding =>
      EdgeInsets.fromLTRB(122.d, 180.d, 122.d, 80.d);

  @override
  void initState() {
    _textController.text = accountProvider.account.name;
    super.initState();
  }

  RxBool showError = false.obs;
  RxList suggests = <String>[].obs;
  RxString selectedName = "".obs;

  @override
  Widget contentFactory() {
    var account = accountProvider.account;
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StreamBuilder<bool>(
              stream: showError.stream,
              builder: (context, snapshot) {
                return Widgets.skinnedInput(
                    maxLines: 1,
                    controller: _textController,
                    borderColor: showError.value == true ? TColors.red : null,
                    onChange: (t) => setState(() {}));
              }),
          StreamBuilder(
              stream: showError.stream,
              builder: (ctx, snapshot) {
                if (!snapshot.hasData || !snapshot.data!) {
                  return const SizedBox();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15.d),
                    Text("profile_name_error".l(),
                        style: TStyles.medium
                            .copyWith(height: 3.d, color: TColors.red)),
                    SizedBox(height: 15.d),
                    Text("profile_name_suggest".l(),
                        style: TStyles.medium
                            .copyWith(height: 3.d, color: TColors.primary20)),
                    StreamBuilder(
                        stream: selectedName.stream,
                        builder: (ctx, snapshot) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 15.d),
                              ...suggests.take(3).map((name) => Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Widgets.button(
                                        context,
                                        padding: EdgeInsets.zero,
                                        margin: EdgeInsets.only(bottom: 15.d),
                                        onPressed: () {
                                          selectedName.value = name;
                                          _textController.text = name;
                                        },
                                        child: Row(
                                          children: [
                                            Asset.load<Image>(
                                                "checkbox_${selectedName.value == name ? "on" : "off"}",
                                                width: 64.d),
                                            SizedBox(width: 12.d),
                                            Text(
                                              name,
                                              style: TStyles.medium.copyWith(
                                                  color: TColors.primary20),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                              SizedBox(height: 15.d),
                            ],
                          );
                        }),
                  ],
                );
              }),
          SizedBox(height: 12.d),
          SkinnedButton(
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
                      decoration: Widgets.imageDecorator(
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
    showError.value = false;
    if (account.level < 100) {
      toast("profile_name_warn".l([
        account.loadingData.rules["changeNameMinLevel"],
        account.loadingData.rules["changeNameCost"]
      ]));
      return;
    }
    var result = await serviceLocator<HttpConnection>().tryRpc(
        context, RpcId.setProfileInfo,
        params: {"name": _textController.text});
    if (result["name_changed"]) {
      if (mounted) {
        account.name = _textController.text;
        accountProvider.update(context, result);
      }
      return;
    }
    suggests.clear();
    for (var name in result["available_names"]) {
      suggests.add(name);
    }
    showError.value = true;
    // setState(() => account.name = id);
  }

  Widget? _moodItemBuilder(Account account, int index) {
    var id = index + 1;
    return Widgets.button(
      context,
      radius: 32.d,
      color: account.moodId == id ? TColors.green : TColors.primary80,
      margin: EdgeInsets.all(10.d),
      padding: EdgeInsets.all(20.d),
      child: LoaderWidget(AssetType.image, "mood_$id", subFolder: "moods"),
      onPressed: () async {
        await serviceLocator<HttpConnection>()
            .tryRpc(context, RpcId.setProfileInfo, params: {"mood_id": id});
        setState(() => account.moodId = id);
        accountProvider.update();
      },
    );
  }
}
