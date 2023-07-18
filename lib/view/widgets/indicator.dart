import 'dart:async';
import 'dart:ui' as ui;

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
    var left = 0.0;
    var height = 117.d;
    var right = widget.clickable ? height - 40.d : 0.0;

    var completer = Completer<ui.Image>();
    var icon = Asset.load<Image>("ui_${widget.itemType.name}");
    icon.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
      left = info.image.width * DeviceInfo.ratio - 16.d;
      setState(() {});
    }));
    return SizedBox(
        width: widget.width ?? 340.d,
        height: height,
        child: Hero(
          tag: widget.itemType.name,
          child: Widgets.touchable(
              child: Material(
                color: TColors.transparent,
                child: Stack(alignment: Alignment.centerLeft, children: [
                  widget.clickable
                      ? Positioned(
                          right: right,
                          left: 12.d,
                          height: 64.d,
                          child: Asset.load<Image>(
                            'ui_frame_wood',
                            centerSlice: ImageCenterSliceDate(
                                160, 64, const Rect.fromLTWH(12, 12, 4, 4)),
                          ))
                      : const SizedBox(),
                  (widget.value == null)
                      ? BlocBuilder<AccountBloc, AccountState>(
                          builder: (context, state) => _textField(
                              state.account.get<int>(widget.itemType),
                              left,
                              right))
                      : _textField(widget.value!, left, right),
                  icon,
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
        style: TStyles.large.copyWith(
            fontSize: (24.d + 60.d / (text.length)).clamp(22.d, 42.d)),
      ),
    );
  }
}
