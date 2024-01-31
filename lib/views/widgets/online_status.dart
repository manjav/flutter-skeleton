import 'package:flutter/material.dart';

import '../../app_export.dart';

class OnlineStatus extends StatefulWidget {
  final String text;
  final VoidCallback? onClose;

  const OnlineStatus({
    required this.text,
    this.onClose,
    super.key,
  });

  @override
  State<OnlineStatus> createState() => OnlineStatusState();
}

class OnlineStatusState extends State<OnlineStatus>
    with SingleTickerProviderStateMixin {
  double size = -10;

  late final AnimationController controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );

  String get text => widget.text;

  @override
  void initState() {
    controller.forward();
    initData();
    super.initState();
  }

  void initData() async {
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        size = -200;
      });
      if (widget.onClose != null) widget.onClose;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      right: Localization.isRTL ? null : size,
      left: Localization.isRTL ? size : null,
      top: 280.d,
      child: Container(
        width: 472.d,
        padding: EdgeInsets.symmetric(vertical: 10.d, horizontal: 20.d),
        decoration: BoxDecoration(
            border: Border.all(
              color: TColors.black,
              width: 6.d,
            ),
            borderRadius: BorderRadius.horizontal(
              left: Localization.isRTL ? Radius.zero : Radius.circular(60.d),
              right: Localization.isRTL ? Radius.circular(60.d) : Radius.zero,
            ),
            color: TColors.black80),
        child: Row(
          children: [
            Asset.load<Image>("player_online",
                height: 31.d, width: 46.d, fit: BoxFit.contain),
            SizedBox(
              width: 15.d,
            ),
            SkinnedText(
              text,
              strokeWidth: 0,
              strokeColor: TColors.transparent,
              shadowScale: 0,
            )
          ],
        ),
      ),
    );
  }
}
