import 'package:flutter/material.dart';
import 'package:square_percent_indicater/square_percent_indicater.dart';

import '../../services/deviceinfo.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/widgets/loaderwidget.dart';
import '../widgets.dart';
import 'skinnedtext.dart';

class LevelIndicator extends StatelessWidget {
  final int xp;
  final String level;
  const LevelIndicator({
    super.key,
    required this.level,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    var bgSliceCenter = ImageCenterSliceDate(134, 134);
    return Widgets.button(
      padding: EdgeInsets.fromLTRB(22.d, 20.d, 22.d, 26.d),
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.fill,
              centerSlice: bgSliceCenter.centerSlice,
              image: Asset.load<Image>(
                'ui_frame_wood_big',
                centerSlice: bgSliceCenter,
              ).image)),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          SquarePercentIndicator(
            progress: 0.5,
            shadowWidth: 16.d,
            progressWidth: 8.d,
            borderRadius: 36.d,
            startAngle: StartAngle.topRight,
            shadowColor: TColors.primary20,
            progressColor: TColors.green,
          ),
          Positioned(
              top: 18.d,
              right: -14.d,
              child: SkinnedText(
                level.toString(),
                style: TStyles.large,
              )),
          Widgets.rect(
              margin: EdgeInsets.all(14.d),
              padding: EdgeInsets.all(4.d),
              color: TColors.primary20,
              radius: 20.d,
              child: const LoaderWidget(AssetType.image, 'avatar_11',
                  subFolder: 'avatars')),
        ],
      ),
    );
  }
}
