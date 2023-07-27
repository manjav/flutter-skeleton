import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../services/deviceinfo.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/widgets/skinnedtext.dart';
import '../widgets.dart';

class Indicator extends StatefulWidget {
  final String origin;
  final AccountField itemType;
  final int? value;
  final double? width;
  final Function? onTap;
  final bool clickable;

  const Indicator(
    this.origin,
    this.itemType, {
    Key? key,
    this.value,
    this.width,
    this.onTap,
    this.clickable = true,
  }) : super(key: key);
  @override
  createState() => _IndicatorState();
}

class _IndicatorState extends State<Indicator> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if (Pref.tutorMode.value == 0) return const SizedBox();
    var left = 50.d;
    var height = 117.d;
    var right = widget.clickable ? height - 40.d : 0.0;
    var sliceData = ImageCenterSliceDate(160, 64);
    return SizedBox(
        width: widget.width ?? 340.d,
        height: height,
        child: Hero(
          tag: widget.itemType.name,
          child: Widgets.touchable(
              child: Material(
                color: TColors.transparent,
                child: Stack(alignment: Alignment.centerLeft, children: [
                  Positioned(
                      right: right,
                      left: left,
                      height: 64.d,
                      child: Widgets.rect(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(bottom: 8.d, left: 40.d),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                centerSlice: sliceData.centerSlice,
                                image: Asset.load<Image>('ui_frame_wood',
                                        centerSlice: sliceData)
                                    .image)),
                        child: (widget.value == null)
                            ? BlocBuilder<AccountBloc, AccountState>(
                                builder: (context, state) => _textField(
                                    state.account.get<int>(widget.itemType),
                                    left,
                                    right))
                            : _textField(widget.value!, left, right),
                      )),
                  Asset.load<Image>(_getIcon()),
                  Positioned(
                      right: 0,
                      height: 84.d,
                      child: widget.clickable
                          ? Asset.load<Image>('ui_plus')
                          : const SizedBox()),
                ]),
              ),
              onTap: () {
                if (widget.clickable) {
                  // widget.services.get<Analytics>().funnle("shopclicks");
                  // widget.services
                  //     .get<Analytics>()
                  //     .design('guiClick:shop:${widget.source}');
                  if (widget.onTap != null) {
                    widget.onTap?.call();
                  } else {
                    // Navigator.pushNamed(context, Screens.shop.routeName);
                  }
                }
              }),
        ));
  }

  _textField(int value, double left, double right) {
    var text = value.compact();
    return Positioned(
      left: left + 24.d,
      right: right + 16.d,
      child: SkinnedText(
        text,
        alignment:
            widget.clickable ? Alignment.centerLeft : Alignment.centerLeft,
        style: TStyles.large.autoSize(text.length, 5, 38.d),
      ),
    );
  }

  String _getIcon() {
    if (widget.itemType == AccountField.league_rank) {
      return "icon_league_${0}";
    }
    return "icon_${widget.itemType.name}";
  }
}
