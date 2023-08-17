import 'package:flutter/material.dart';
import '../../services/deviceinfo.dart';
import '../../services/theme.dart';

import '../widgets.dart';

class Powerbalance extends StatefulWidget {
  const Powerbalance({super.key});

  @override
  State<Powerbalance> createState() => _PowerbalanceState();
}

class _PowerbalanceState extends State<Powerbalance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Widgets.rect(color: TColors.accent, width: 32.d, height: 800.d);
  }
}
