import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/core/adam.dart';
import '../../data/infra.dart';
import '../../mixins/logger.dart';
import '../../mixins/service_finder_mixin.dart';
import '../../../providers/account_provider.dart';
import '../../providers/services_provider.dart';
import '../../services/device_info.dart';
import '../../services/routes.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../widgets.dart';
import 'skinned_text.dart';

class Indicator extends StatefulWidget {
  final String origin;
  final Values type;
  final int? value;
  final double? width;
  final Function? onTap;
  final bool hasPlusIcon;
  final dynamic data;

  const Indicator(
    this.origin,
    this.type, {
    super.key,
    this.value,
    this.width,
    this.onTap,
    this.data,
    this.hasPlusIcon = true,
  });
  @override
  createState() => _IndicatorState();
}

class _IndicatorState extends State<Indicator>
    with TickerProviderStateMixin, ILogger, ServiceFinderWidgetMixin {
  @override
  Widget build(BuildContext context) {
    // if (Pref.tutorMode.value == 0) return const SizedBox();
    var height = 110.d;
    return SizedBox(
        width: widget.width ?? (widget.hasPlusIcon ? 320.d : 250.d),
        height: height,
        child: Hero(
          tag: widget.type.name,
          child: Widgets.touchable(context,
              child: Material(
                color: TColors.transparent,
                child: widget.value == null
                    ? Consumer<AccountProvider>(
                        builder: (_, state, child) => _getElements(
                            height,
                            state.account.getValue(widget.type),
                            state.account.leagueId))
                    : _getElements(height, widget.value!, widget.data as int),
              ), onTap: () {
            if (widget.onTap != null) {
              widget.onTap?.call();
            } else {
              switch (widget.type) {
                case Values.gold:
                case Values.nectar:
                  Navigator.popUntil(context, (route) => route.isFirst);
                  services.changeState(ServiceStatus.changeTab, data: 0);
                  log("Go to shop");
                  break;
                case Values.potion:
                  Routes.popupPotion.navigate(context);
                  break;
                default:
                  break;
              }
            }
            // widget.services.get<Analytics>().funnel("shopclicks");
            // widget.services
            //     .get<Analytics>()
            //     .design('guiClick:shop:${widget.source}');
          }),
        ));
  }

  _getElements(double height, int value, int league) {
    var left = height * 0.65;
    var right = widget.hasPlusIcon ? height - 30.d : 0.0;
    if (widget.type == Values.leagueRank && value == 0 && league == 0) {
      return const SizedBox();
    }
    return Stack(alignment: Alignment.centerLeft, children: [
      Positioned(
          right: right,
          left: left,
          height: 64.d,
          child: Widgets.rect(
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 8.d, left: height * 0.1),
            decoration: Widgets.imageDecorator(
                "ui_indicator_bg", ImageCenterSliceData(104, 69)),
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
    if (widget.type == Values.leagueRank) {
      return "icon_league_${LeagueData.getIndices(league).$1}";
    }
    return "icon_${widget.type.name}";
  }
}
