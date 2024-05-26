import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_export.dart';

class Indicator extends StatefulWidget {
  final String origin;
  final Values type;
  final int? value;
  final double? width;
  final Function? onTap;
  final bool hasPlusIcon;
  final dynamic data;
  final bool? disableHero;

  const Indicator(
    this.origin,
    this.type, {
    super.key,
    this.value,
    this.width,
    this.onTap,
    this.data,
    this.hasPlusIcon = true,
    this.disableHero = false,
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
        child: widget.disableHero == true
            ? _child(height)
            : Hero(tag: widget.type.name, child: _child(height)));
  }

  _child(double height) {
    return Widgets.touchable(
      context,
      child: Material(
        color: TColors.transparent,
        child: widget.value == null
            ? Consumer<AccountProvider>(
                builder: (_, state, child) => _getElements(
                    height,
                    state.account.getValue(widget.type),
                    state.account.leagueId))
            : _getElements(height, widget.value!, widget.data as int),
      ),
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap?.call();
        } else {
          switch (widget.type) {
            case Values.gold:
              serviceLocator<RouteService>().popUntil((route) => route.isFirst);
              services.changeState(ServiceStatus.changeTab,
                  data: {"index": 0, "section": ShopSections.gold});
              break;
            case Values.nectar:
              serviceLocator<RouteService>().popUntil((route) => route.isFirst);
              services.changeState(ServiceStatus.changeTab,
                  data: {"index": 0, "section": ShopSections.nectar});
              break;
            case Values.potion:
              serviceLocator<RouteService>().to(Routes.popupPotion);
              break;
            default:
              break;
          }
        }
        // widget.services.get<Analytics>().funnel("shopclicks");
        // widget.services
        //     .get<Analytics>()
        //     .design('guiClick:shop:${widget.source}');
      },
    );
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
      _getIcon(league),
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

  Widget _getIcon(int league) {
    if (widget.type == Values.leagueRank) {
      var indices = LeagueData.getIndices(league);
      return Stack(children: [
        league > 0
            ? Asset.load<Image>("icon_league_${indices.$1}")
            : const SizedBox(),
        Positioned(
            top: 5.d,
            width: 34.d,
            right: 3.d,
            child: Text(
              "l_${indices.$2}".l(),
              style: TStyles.tiny,
              textAlign: TextAlign.center,
            ))
      ]);
    }
    return Asset.load<Image>("icon_${widget.type.name}");
  }
}
