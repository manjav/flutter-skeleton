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
  final TextAlign align;
  const LevelIndicator({
    this.xp,
    this.level,
    this.align = TextAlign.left,
    super.key,
  });

  @override
  State<LevelIndicator> createState() => _LevelIndicatorState();
}

class _LevelIndicatorState extends State<LevelIndicator> {
  int _xp = 0;
  int _level = 0;
  Size _size = const Size(100, 100);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_measureSize()) {
        setState(() {});
      }
    });
    super.initState();
  }

  bool _measureSize() {
    if (_size.width != 100) return false;
    final keyContext = (widget.key as GlobalKey).currentContext;
    final renderObject = keyContext!.findRenderObject();
    if (renderObject != null) {
      _size = (renderObject as RenderBox).size;
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    _measureSize();
    if (widget.level == null) {
      return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
        _xp = state.account.get<int>(AccountField.xp);
        _level = state.account.get<int>(AccountField.level);
        return _elementsBuilder();
      });
    }
    _xp = widget.xp!;
    _level = widget.level!;
    return _elementsBuilder();
  }

  _elementsBuilder() {
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
            progress: _xp / (_xp * 2),
            shadowWidth: 16.d,
            progressWidth: 8.d,
            borderRadius: 36.d,
            startAngle: StartAngle.topRight,
            shadowColor: TColors.primary20,
            progressColor: TColors.green,
          ),
          Positioned(
              top: -24.d,
              left: widget.align == TextAlign.left ? _size.height - 56.d : null,
              right:
                  widget.align == TextAlign.right ? _size.height - 56.d : null,
              child: SkinnedText(
                _level.toString(),
                style: TStyles.medium,
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
