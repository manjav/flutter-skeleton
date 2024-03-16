import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../app_export.dart';

class DeadlineIndicator extends StatefulWidget {
  final Deadline deadline;
  const DeadlineIndicator(this.deadline, {super.key});

  @override
  State<DeadlineIndicator> createState() => _DeadlineIndicatorState();
}

class _DeadlineIndicatorState extends State<DeadlineIndicator>
    with ServiceFinderWidgetMixin, ClassFinderWidgetMixin {
  Timer? _timer;

  @override
  void initState() {
    _timer =
        Timer.periodic(const Duration(seconds: 1), (timer) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var remaining = widget.deadline.time - accountProvider.account.getTime();
    return SizedBox(
        width: remaining < 1 ? 0 : 500.d,
        height: 150.d,
        child: remaining < 1
            ? null
            : Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Positioned(
                    left: -20.d,
                    child: Widgets.rect(
                      width: 350.d,
                      height: 80.d,
                      decoration: BoxDecoration(
                        gradient: widget.deadline.boost.id < 22
                            ? TColors.linearBlue
                            : TColors.linearGold,
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
                          SkinnedText(
                              remaining.toInt().toRemainingTimeFormatted()),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10.d,
                    top: 0,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        LoaderWidget(
                          AssetType.image,
                          widget.deadline.boost.id < 22
                              ? "shop_boost_xp"
                              : "shop_boost_power",
                          height: 150.d,
                          width: 150.d,
                        ),
                        Positioned(
                          bottom: 18.d,
                          child: SkinnedText(
                            "${((widget.deadline.boost.ratio - 1) * 100).round()}%",
                            style: TStyles.medium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ));
  }
}
