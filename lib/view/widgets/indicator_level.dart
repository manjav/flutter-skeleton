import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../view/key_provider.dart';
import 'package:square_percent_indicater/square_percent_indicater.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/widgets/loaderwidget.dart';
import '../widgets.dart';
import 'skinnedtext.dart';

class LevelIndicator extends StatefulWidget {
  final int? xp;
  final int? level;
  final int? avatarId;
  final bool showLevel;
  final TextAlign align;
  final double size;
  final Function()? onPressed;

  const LevelIndicator({
    this.xp,
    this.level,
    this.avatarId,
    this.size = 75,
    this.onPressed,
    this.showLevel = true,
    this.align = TextAlign.left,
    super.key,
  });

  @override
  State<LevelIndicator> createState() => _LevelIndicatorState();
}

class _LevelIndicatorState extends State<LevelIndicator> with KeyProvider {
  int _xp = 0;
  int _level = 0;
  int _avatarId = 0;
  int _minXp = 0;
  int _maxXp = 0;

  void _updateParams(int xp, int level, int avatarId) {
    _xp = xp;
    _level = level;
    _avatarId = avatarId;
    _minXp = Account.getXpRequiered(level - 1);
    _maxXp = Account.getXpRequiered(level);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.level == null) {
      return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
        _updateParams(
          state.account.xp,
          state.account.level,
          state.account.avatarId,
        );
        return _elementsBuilder();
      });
    }
    _updateParams(widget.xp!, widget.level!, widget.avatarId!);
    return _elementsBuilder();
  }

  _elementsBuilder() {
    var s = widget.size / 200;
    return Widgets.button(
      radius: 54 * s,
      onPressed: widget.onPressed,
      decoration: Widgets.imageDecore("ui_frame_wood_big"),
      width: widget.size,
      height: widget.size,
      padding: EdgeInsets.all(28 * s),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          SquarePercentIndicator(
            progress: (_xp - _minXp) / (_maxXp - _minXp),
            shadowWidth: 20 * s,
            progressWidth: 8 * s,
            borderRadius: 40 * s,
            startAngle: widget.align == TextAlign.left
                ? StartAngle.topLeft
                : StartAngle.topRight,
            shadowColor: TColors.primary20,
            progressColor: TColors.green,
          ),
          Widgets.rect(
              radius: 20 * s,
              margin: EdgeInsets.all(14 * s),
              child: LoaderWidget(AssetType.image, 'avatar_$_avatarId',
                  subFolder: 'avatars', key: getGlobalKey(_avatarId))),
          widget.showLevel
              ? PositionedDirectional(
                  top: -24 * s,
                  width: 110 * s,
                  start: widget.align == TextAlign.left
                      ? widget.size - 120 * s
                      : null,
                  end: widget.align == TextAlign.right
                      ? widget.size - 120 * s
                      : null,
                  child: SkinnedText(_level.toString()))
              : const SizedBox(),
        ],
      ),
    );
  }
}
