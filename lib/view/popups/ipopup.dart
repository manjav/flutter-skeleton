import 'package:flutter/material.dart';

import '../../blocs/services.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/ilogger.dart';
import '../widgets.dart';

class PopupData {
  final bool? overlayMode;
  final Color? backgroundColor;
  final Color? barrierColor;
  final bool? barrierDismissible;
  final BuildContext context;
  final Function(BuildContext) childFactory;

  EdgeInsets? insetPadding;

  PopupData(
    this.context,
    this.childFactory, {
    this.overlayMode,
    this.insetPadding,
    this.backgroundColor,
    this.barrierColor,
    this.barrierDismissible,
  });
}

class AbstractPopup extends StatefulWidget {
  final Services services;
  final bool showConfetti;
  const AbstractPopup(this.services, {Key? key, this.showConfetti = false})
      : super(key: key);
  @override
  createState() => AbstractPopupState();

  static force(
    BuildContext context,
    Function(BuildContext) childFactory, {
    String sfx = '',
    bool? overlayMode,
    EdgeInsets? insetPadding,
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? barrierColor,
    bool? barrierDismissible,
  }) async {
    var result = await showGeneralDialog(
        barrierDismissible: barrierDismissible ?? true,
        barrierColor: barrierColor ?? TColors.black80,
        context: context,
        barrierLabel: "",
        pageBuilder: (c, _, __) {
          if (overlayMode ?? false) {
            return _Alert(childFactory);
          }
          return Dialog(
              backgroundColor: TColors.transparent,
              insetPadding: insetPadding ??
                  EdgeInsets.symmetric(horizontal: 20.d, vertical: 24.d),
              child: Widgets.rect(
                  width: 360.d,
                  radius: 24.d,
                  color: backgroundColor ?? TColors.primary90,
                  padding: padding ?? EdgeInsets.all(12.d),
                  child: _Alert(childFactory)));
        });
    return result;
  }

  static alert(
    Services services,
    BuildContext context,
    String title, {
    String? message,
    String? buttonLabel,
    Function? onButtonTap,
    bool barrierDismissible = true,
  }) {
    force(
        context,
        (context) => Column(mainAxisSize: MainAxisSize.min, children: [
              Text(title, style: TStyles.medium),
              SizedBox(height: 24.d),
              message != null
                  ? Text(message, style: TStyles.small)
                  : const SizedBox(),
              SizedBox(height: message != null ? 32.d : 0),
              Widgets.button(
                  buttonId: -1,
                  width: 180.d,
                  child: Text(buttonLabel ?? 'ok_l'.l(),
                      style: TStyles.mediumInvert),
                  onPressed: () {
                    Navigator.pop(context);
                    onButtonTap?.call();
                  })
            ]),
        barrierDismissible: barrierDismissible);
  }
}

class AbstractPopupState<T extends AbstractPopup> extends State<T>
    with ILogger {
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.topCenter, children: [
      Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        titleFactory(''),
        contentFactory(),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: actionsFactory()),
      ]),
    ]);
  }

  titleFactory(String title) {
    return Text(title);
  }

  contentFactory() => const SizedBox();

  actionsFactory() => <Widget>[];
}

class _Alert extends StatefulWidget {
  final Function(BuildContext) contentFactory;
  const _Alert(this.contentFactory, {Key? key}) : super(key: key);
  @override
  createState() => _AlertState();
}

class _AlertState extends State<_Alert> {
  @override
  Widget build(BuildContext context) {
    return widget.contentFactory(context);
  }
}
