import 'package:flutter/material.dart';

import '../../app_export.dart';

mixin PopupsMixin<S extends StatefulWidget> on State<S> {
  void toast(String message) => Overlays.insert(context, ToastOverlay(message));

  alert(String title, {String? message, bool isConfirm = false}) async {
    if (!context.mounted) return;

    button(Color color, String label, dynamic result) {
      return SkinnedButton(
          width: 360.d,
          label: label,
          color: color,
          margin: EdgeInsets.all(10.d),
          onPressed: () => Navigator.pop(context, result));
    }

    var items = <Widget>[
      Text(title, style: TStyles.large),
      SizedBox(height: 24.d),
    ];
    if (message != null) {
      items.addAll([
        DirText(message, style: TStyles.medium),
        SizedBox(height: 32.d),
      ]);
    }
    if (isConfirm) {
      items.addAll([
        button(TColors.gray, "decline_l".l(), null),
        button(TColors.green, "accept_l".l(), true),
      ]);
    }
    return await modal(items, backgroundColor: TColors.primary0);
  }

  // ignore: avoid_shadowing_type_parameters
  Future<T?> modal<T>(List<Widget> children,
      {Color? barrierColor,
      Color? backgroundColor,
      bool isDismissible = true,
      EdgeInsets? padding}) async {
    var data = await showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      barrierColor: barrierColor,
      isScrollControlled: isDismissible,
      constraints: const BoxConstraints.tightFor(),
      backgroundColor: TColors.transparent,
      builder: (BuildContext context) => Widgets.rect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.d),
          topRight: Radius.circular(40.d),
        ),
        padding: padding ?? EdgeInsets.fromLTRB(40.d, 25.d, 40.d, 40.d),
        color: backgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
    return data;
  }
}
