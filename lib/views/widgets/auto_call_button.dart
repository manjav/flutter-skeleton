import 'package:flutter/material.dart';

import '../../app_export.dart';

class AutoCallButton extends StatefulWidget {
  final String label;
  final Color? color;
  final Function() onPressed;
  const AutoCallButton({
    required this.onPressed,
    required this.label,
    this.color,
    super.key,
  });

  @override
  State<AutoCallButton> createState() => _AutoCallButtonState();
}

class _AutoCallButtonState extends State<AutoCallButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  GlobalKey stickyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2500));
    _controller.addStatusListener(
      (status) {
        if (status == AnimationStatus.completed) {
          Navigator.pop(context);
          widget.onPressed();
        }
      },
    );
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(16.0);
    RenderBox? box;
    return Stack(
      children: [
        SkinnedButton(
          label: widget.label,
          color: widget.color,
          key: stickyKey,
          onPressed: () {
            Navigator.pop(context);
            widget.onPressed();
          },
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double size = 0;
            if (box == null) {
              final keyContext = stickyKey.currentContext;
              box = keyContext?.findRenderObject() as RenderBox;
            }
            if (box != null && box!.hasSize) {
              size = box!.size.width;
            }
            return Positioned(
              width: _controller.value * size,
              left: 0,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Widgets.rect(
                  decoration: BoxDecoration(
                    color: TColors.white30,
                    borderRadius: BorderRadius.only(
                      bottomLeft: radius,
                      topLeft: radius,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
