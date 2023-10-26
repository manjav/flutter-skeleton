import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/building.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/popups/ipopup.dart';
import '../../view/widgets/indicator_level.dart';
import '../../view/widgets/loaderwidget.dart';
import '../../view/widgets/skinnedtext.dart';
import '../route_provider.dart';
import '../widgets.dart';

class ProfilePopup extends AbstractPopup {
  ProfilePopup({super.key}) : super(Routes.popupProfile, args: {});

  @override
  createState() => _ProfilePopupState();
}

class _ProfilePopupState extends AbstractPopupState<ProfilePopup> {
  @override
  EdgeInsets get contentPadding => EdgeInsets.fromLTRB(24.d, 200.d, 24.d, 92.d);

  @override
  void initState() {
    super.initState();
  }

  @override
  contentFactory() {
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      return SizedBox(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _headerBuilder(state.account),
          _medalsBuilder(state.account),
        ],
          ));
    });
  }

  Widget _headerBuilder(Account account) {
    return Widgets.rect(
        padding: EdgeInsets.symmetric(horizontal: 10.d, vertical: 7.d),
        decoration: Widgets.imageDecore("frame_header_cheese",
            ImageCenterSliceData(114, 226, const Rect.fromLTWH(58, 61, 2, 2))),
        width: 940.d,
        height: 510.d,
        child: Stack(clipBehavior: Clip.none, children: [
          Widgets.rect(
              height: 192.d,
              decoration: Widgets.imageDecore(
                  "frame_hatch",
                  ImageCenterSliceData(
                      80, 100, const Rect.fromLTWH(38, 64, 2, 2)))),
          Positioned(
              top: -48.d,
              left: 24.d,
              child: const LevelIndicator(showLevel: false)),
          Positioned(
              top: 10.d,
              left: 240.d,
              child: SkinnedText(account.name, style: TStyles.large)),
          Positioned(
              top: 80.d,
              left: 240.d,
              child: Row(children: [
                SkinnedText("mood_l".l()),
                SizedBox(width: 16.d),
                LoaderWidget(AssetType.image, "mood_${account.moodId}",
                    subFolder: "moods", width: 50.d)
              ])),
          Positioned(
              top: 220.d,
              left: 60.d,
              child: _indicator("total_rank".l(), account.rank.toString(),
                  icon: "icon_rank")),
          Positioned(
              top: 360.d,
              left: 60.d,
              child: _indicator(
                  "last_played ".l(),
                  (DateTime.now().secondsSinceEpoch - account.last_load_at)
                      .toElapsedTime(),
                  valueStyle: TStyles.medium)),
          Positioned(
              top: 220.d,
              left: 500.d,
              child: Widgets.divider(direction: Axis.vertical, height: 220.d)),
          Positioned(
              top: 210.d,
              right: 12.d,
              width: 380.d,
              child: _tribeSection(account))
        ]));
  }

  Widget _indicator(String label, String value,
      {String? icon, TextStyle? valueStyle}) {
    return Widgets.rect(
      constraints: BoxConstraints(minWidth: 250.d),
      height: 92.d,
      padding: EdgeInsets.zero,
      decoration: Widgets.imageDecore("frame_hatch", ImageCenterSliceData(60)),
      child: Stack(
          alignment: const Alignment(0, -0.2),
          clipBehavior: Clip.none,
          children: [
            Positioned(
                top: -34.d,
                left: 10.d,
                child: Text(label, style: TStyles.tiny)),
            Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(width: icon == null ? 16.d : 8.d),
              icon != null
                  ? Asset.load<Image>(icon, width: 68.d)
                  : const SizedBox(),
              SizedBox(width: icon == null ? 0 : 16.d),
              SkinnedText(value, style: valueStyle ?? TStyles.large),
              SizedBox(width: 16.d),
            ])
          ]),
    );
  }

  Widget _tribeSection(Account account) {
    return Column(children: [
      LoaderWidget(AssetType.animation, "tab_3", fit: BoxFit.fitWidth,
          onRiveInit: (Artboard artboard) {
        final controller = StateMachineController.fromArtboard(artboard, "Tab");
        var level = account.tribe != null
            ? account.tribe!.levels[Buildings.base.id]!.toDouble()
            : 0.0;
        controller?.findInput<double>("level")!.value = level;
        controller?.findInput<bool>("hideBackground")!.value = true;
        controller?.findInput<bool>("active")!.value = true;
        artboard.addController(controller!);
      }, width: 130.d, height: 130.d),
      SizedBox(height: 20.d),
      SkinnedText(account.tribe!.name, style: TStyles.large)
    ]);
  }

  Widget _medalsBuilder(Account account) {
    return SizedBox(
        height: 250.d,
        child: Stack(alignment: Alignment.bottomCenter, children: [
          Positioned(
              bottom: 50.d,
              child: Widgets.rect(
                  height: 71.d,
                  width: 880.d,
                  margin: EdgeInsets.fromLTRB(16.d, 44.d, 16.d, 0),
                  decoration: Widgets.imageDecore(
                      "shelf", ImageCenterSliceData(108, 71)))),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 10001; i < 10007; i++)
                  _medalBuilder(i, account.medals[i])
              ])
        ]));
  }

  Widget _medalBuilder(int name, int? count) {
    var size = 140.d;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColorFiltered(
            colorFilter: ColorFilter.mode(
              count == null ? TColors.black80 : TColors.white,
              count == null ? BlendMode.srcIn : BlendMode.dstIn,
            ),
            child: LoaderWidget(AssetType.image, "medal_$name",
                subFolder: "medals", width: size, height: size)),
        SizedBox(height: 30.d),
        count != null ? Text("x$count") : const SizedBox()
      ],
    );
  }

}
