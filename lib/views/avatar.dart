import 'package:flutter/material.dart';

import '../app_export.dart';

class Avatar extends StatefulWidget {
  final double padding;
  const Avatar(this.padding, {super.key});

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  @override
  Widget build(BuildContext context) {
    return Widgets.rect(
      color: TColors.clay,
      width: widget.padding,
      radius: widget.padding,
      height: widget.padding,
      padding: EdgeInsets.all(6.d),
    );
  }
}
