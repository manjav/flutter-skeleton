import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app_export.dart';

class GoldenTimeDeadline extends StatefulWidget {
  final VoidCallback? onFinish;
  const GoldenTimeDeadline({this.onFinish, super.key});

  @override
  State<GoldenTimeDeadline> createState() => _GoldenTimeDeadlineState();
}

class _GoldenTimeDeadlineState extends State<GoldenTimeDeadline>
    with ServiceFinderWidgetMixin, ClassFinderWidgetMixin {
  Timer? _timer;
  int _remaining = 0;

  @override
  void initState() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => setState(
        () {
          _remaining = accountProvider.account.bonus_remaining_time - timer.tick;
          if (_remaining <= 0) {
            accountProvider.account.bonus_remaining_time = 0;
            dispose();
            accountProvider.update();
          }
        },
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Duration duration = Duration(seconds: _remaining);
    var min = duration.inMinutes.remainder(60).toString().padLeft(2, "0");
    var second = duration.inSeconds.remainder(60).toString().padLeft(2, "0");
    return Widgets.rect(
      width: 260.d,
      height: 80.d,
      decoration: BoxDecoration(
        gradient: TColors.linearGold,
        border: Border.all(
          color: TColors.primary20,
          width: 8.d,
        ),
        borderRadius: BorderRadius.circular(20.d),
      ),
      padding: EdgeInsets.only(right: 15.d),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 50.d, child: SkinnedText(min)),
          const SkinnedText(":"),
          SizedBox(width: 50.d, child: SkinnedText(second)),
        ],
      ),
    ).animate().fade(duration: 300.ms, delay: 0.ms);
  }
}
