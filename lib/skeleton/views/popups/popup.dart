import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app_export.dart';

class AbstractPopup extends StatefulWidget {
  final String route;

  const AbstractPopup(
    this.route, {
    super.key,
  });

  Map<String, dynamic> get args => Get.arguments;
  String get name => route.replaceAll("/", "");

  @override
  createState() => AbstractPopupState();
}

class AbstractPopupState<T extends AbstractPopup> extends State<T>
    with ILogger, ServiceFinderWidgetMixin {
  Alignment alignment = Alignment.center;
  bool barrierDismissible = true, canPop = true;

  @override
  void initState() {
    serviceLocator<MediaService>().playSound("popup");
    canPop = widget.args["canPop"] ?? true;
    barrierDismissible = widget.args["barrierDismissible"] ?? true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var paddingTop = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: PopScope(
        canPop: canPop,
        child: Stack(
          children: [
            Widgets.touchable(context,
                onTap:
                    barrierDismissible ? () => Navigator.pop(context) : null),
            Align(
              alignment: alignment,
              child: Widgets.rect(
                constraints: BoxConstraints.loose(
                    Size(DeviceInfo.size.width * 0.8, DeviceInfo.size.height)),
                radius: 24.d,
                color: TColors.primary0,
                padding: EdgeInsets.all(20.d),
                child: contentFactory(),
              ),
            ),
            // Positioned(
            //   top: paddingTop > 0 ? paddingTop : 24.d,
            //   left: 32.d,
            //   right: 32.d,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.end,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: appBarElements(),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Color get backgroundColor => TColors.black80;
  List<Widget> appBarElements() => [];

  BoxDecoration get chromeSkinBuilder => BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(12.d)),
      color: TColors.primary0);

  Widget contentFactory() => const SizedBox();

  void toast(String message) => Overlays.insert(context, ToastOverlay(message));
}
