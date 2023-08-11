import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../services/deviceinfo.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/widgets/skinnedtext.dart';

class DeadlineIndicator extends StatefulWidget {
  final Deadline deadline;
  const DeadlineIndicator(this.deadline, {super.key});

  @override
  State<DeadlineIndicator> createState() => _DeadlineIndicatorState();
}

class _DeadlineIndicatorState extends State<DeadlineIndicator> {
  Timer? _timer;
  late Account _account;

  @override
  void initState() {
    _account = BlocProvider.of<AccountBloc>(context).account!;
    _timer =
        Timer.periodic(const Duration(seconds: 10), (timer) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var remaining = widget.deadline.time - _account.now;
    return SizedBox(
        width: 230.d,
        height: 230.d,
        child: remaining < 1
            ? null
            : Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                      top: 0,
                      child: Asset.load<Image>(
                          widget.deadline.boost.id < 22
                              ? "shop_xp"
                              : "shop_power",
                          height: 200.d)),
                  Align(
                      alignment: const Alignment(0, 0.3),
                      child: Text(
                          "${((widget.deadline.boost.boost - 1) * 100).round()}%")),
                  SkinnedText(remaining.toRemainingTime()),
                ],
              ));
  }
}
