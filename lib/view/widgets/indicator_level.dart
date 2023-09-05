import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_percent_indicater/square_percent_indicater.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../services/deviceinfo.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/widgets/loaderwidget.dart';
import '../widgets.dart';
import 'skinnedtext.dart';

class LevelIndicator extends StatefulWidget {
  final int? xp;
  final int? level;
  final int? avatarId;
  final TextAlign align;
  final double size;
  const LevelIndicator({
    this.size = 75,
    this.xp,
    this.level,
    this.avatarId,
    this.align = TextAlign.left,
    super.key,
  });

  @override
  State<LevelIndicator> createState() => _LevelIndicatorState();
}

class _LevelIndicatorState extends State<LevelIndicator> {
  int _xp = 0;
  int _level = 0;
  int _avatarId = 0;
  int _minXp = 0;
  int _maxXp = 0;

  void _updateParams(int xp, int level, int avatarId) {
    _xp = xp;
    _level = level;
    _avatarId = avatarId + 1;
    _minXp = Account.getXpRequiered(level - 1);
    _maxXp = Account.getXpRequiered(level);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.level == null) {
      return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
        _updateParams(
          state.account.get<int>(AccountField.xp),
          state.account.get<int>(AccountField.level),
          state.account.get<int>(AccountField.avatar_id),
        );
        return _elementsBuilder();
      });
    }
    _updateParams(widget.xp!, widget.level!, widget.avatarId!);
    return _elementsBuilder();
  }

  _elementsBuilder() {
    var bgSliceCenter = ImageCenterSliceData(134, 134);
    return Widgets.button(
      width: widget.size,
      height: widget.size + 5.d,
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
            progress: (_xp - _minXp) / (_maxXp - _minXp),
            shadowWidth: 16.d,
            progressWidth: 8.d,
            borderRadius: 36.d,
            startAngle: StartAngle.topRight,
            shadowColor: TColors.primary20,
            progressColor: TColors.green,
          ),
          Positioned(
              top: -24.d,
              left: widget.align == TextAlign.left ? widget.size - 56.d : null,
              right:
                  widget.align == TextAlign.right ? widget.size - 56.d : null,
              child: SkinnedText(
                _level.toString(),
                style: TStyles.medium,
              )),
          Widgets.rect(
              margin: EdgeInsets.all(14.d),
              padding: EdgeInsets.all(4.d),
              color: TColors.primary20,
              radius: 20.d,
              child: LoaderWidget(AssetType.image, 'avatar_$_avatarId',
                  subFolder: 'avatars')),
        ],
      ),
    );
  }
}
