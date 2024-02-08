import 'package:flutter/material.dart';

import '../app_export.dart';

class Avatar extends StatefulWidget {
  final double size;
  const Avatar(this.size, {super.key});

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.size),
      child: Widgets.rect(
          color: TColors.clay,
          width: widget.size,
          radius: widget.size,
          height: widget.size,
          // padding: EdgeInsets.all(6.d),
          child: Asset.load<Image>("avatar")),
    );
  }
}
