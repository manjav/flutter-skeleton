import 'package:flutter/material.dart';

import '../../app_export.dart';

class Avatar extends StatefulWidget {
  final double size;
  final String name;
  const Avatar(this.name, this.size, {super.key});

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.size),
      child: Widgets.rect(
        width: widget.size,
        radius: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: TColors.primary10,
          border: Border.all(color: TColors.primary50, width: 4.d),
          borderRadius: BorderRadius.all(Radius.elliptical(32.d, 32.d)),
        ),
        padding: EdgeInsets.all(6.d),
        child: Transform(
          alignment: const Alignment(-0.5, 0.0),
          transform: Transform.rotate(angle: -0.1).transform,
          child: LoaderWidget(AssetType.vector, widget.name),
        ),
      ),
    );
  }
}
