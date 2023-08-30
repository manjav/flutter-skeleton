import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/ranking.dart';
import '../../services/deviceinfo.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/ilogger.dart';
import '../../utils/utils.dart';
import '../../view/route_provider.dart';
import '../../view/widgets/skinnedtext.dart';
import '../widgets.dart';

class Indicator extends StatefulWidget {
  final String origin;
  final AccountField itemType;
  final int? value;
  final double? width;
  final Function? onTap;
  final bool hasPlusIcon;
  final dynamic data;

  const Indicator(
    this.origin,
    this.itemType, {
    Key? key,
    this.value,
    this.width,
    this.onTap,
    this.data,
    this.hasPlusIcon = true,
  }) : super(key: key);
  @override
  createState() => _IndicatorState();
}

class _IndicatorState extends State<Indicator>
    with TickerProviderStateMixin, ILogger {
  @override
  Widget build(BuildContext context) {
    // if (Pref.tutorMode.value == 0) return const SizedBox();
    var height = 110.d;
    return SizedBox(
        width: widget.width ?? (widget.hasPlusIcon ? 320.d : 250.d),
        height: height,
        child: Hero(
          tag: widget.itemType.name,
          child: Widgets.touchable(
              child: Material(
                color: TColors.transparent,
                child: widget.value == null
                    ? BlocBuilder<AccountBloc, AccountState>(
                        builder: (context, state) => _getElements(
                            height,
                            state.account.get<int>(widget.itemType),
                            state.account.get<int>(AccountField.league_id)))
                    : _getElements(height, widget.value!, widget.data as int),
              ),
              onTap: () {
                if (widget.onTap != null) {
                  widget.onTap?.call();
                } else {
                  switch (widget.itemType) {
                    case AccountField.gold:
                    case AccountField.nectar:
                      Navigator.popUntil(context, (route) => route.isFirst);
                      BlocProvider.of<ServicesBloc>(context)
                          .add(ServicesEvent(ServicesInitState.changeTab, 0));

                      log("Go to shop");
                      break;
                    case AccountField.potion_number:
                      Navigator.pushNamed(
                          context, Routes.popupPotion.routeName);
                      break;
                    default:
                      break;
                  }
                }
                // widget.services.get<Analytics>().funnle("shopclicks");
                // widget.services
                //     .get<Analytics>()
                //     .design('guiClick:shop:${widget.source}');
              }),
        ));
  }

  _getElements(double height, int value, int league) {
    var left = height * 0.65;
    var right = widget.hasPlusIcon ? height - 30.d : 0.0;
    var sliceData = ImageCenterSliceDate(104, 69);
    return Stack(alignment: Alignment.centerLeft, children: [
      Positioned(
          right: right,
          left: left,
          height: 64.d,
          child: Widgets.rect(
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 8.d, left: height * 0.1),
            decoration: BoxDecoration(
                image: DecorationImage(
                    centerSlice: sliceData.centerSlice,
                    image: Asset.load<Image>('ui_indicator_bg',
                            centerSlice: sliceData)
                        .image)),
            child: _getText(value, left, right),
          )),
      Asset.load<Image>(_getIcon(league)),
      Positioned(
          right: 0,
          height: 84.d,
          child: widget.hasPlusIcon
              ? Asset.load<Image>('ui_plus')
              : const SizedBox()),
    ]);
  }

  _getText(int value, double left, double right) {
    var text = value.compact();
    return SkinnedText(text,
        alignment:
            widget.hasPlusIcon ? Alignment.centerLeft : Alignment.centerLeft,
        style: TStyles.large.autoSize(text.length, 5, 38.d));
  }

  String _getIcon(int league) {
    if (widget.itemType == AccountField.league_rank) {
      return "icon_league_${LeagueData.getIndices(league).$1}";
    }
    return "icon_${widget.itemType.name}";
  }
}
