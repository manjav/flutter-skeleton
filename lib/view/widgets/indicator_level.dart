import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:square_percent_indicater/square_percent_indicater.dart';

import '../../data/core/account.dart';
import '../../mixins/key_provider.dart';
import '../../providers/account_provider.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../widgets.dart';
import 'loader_widget.dart';
import 'skinned_text.dart';

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
  int _level = 1;
  int _avatarId = 0;
  int _minXp = 0;
  int _maxXp = 0;

  void _updateParams(int xp, int level, int avatarId) {
    _xp = xp;
    _level = level;
    _avatarId = avatarId;
    _minXp = Account.getXpRequired(level - 1);
    _maxXp = Account.getXpRequired(level);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.level == null) {
      return Consumer<AccountProvider>(builder: (_, state, child) {
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
      context,
      radius: 54 * s,
      onPressed: widget.onPressed,
      decoration: Widgets.imageDecorator("ui_frame_wood_big"),
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
              borderRadius: 30 * s,
              startAngle: widget.align == TextAlign.left
                  ? StartAngle.topRight
                  : StartAngle.topLeft,
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
                    top: -20 * s,
                    width: 100 * s,
                    end: widget.align == TextAlign.left ? -50 * s : null,
                    start: widget.align == TextAlign.right ? -50 * s : null,
                    child: SkinnedText("$_level",
                        style: TStyles.small.copyWith(fontSize: 40 * s)))
                : const SizedBox(),
          ]),
    );
  }
}
