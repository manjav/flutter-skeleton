import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../app_export.dart';

class BuildingWidget extends StatefulWidget {
  final Widget? child;
  final Building building;
  final void Function()? onTap;
  const BuildingWidget(this.building, {super.key, this.child, this.onTap});

  @override
  State<BuildingWidget> createState() => _BuildingWidgetState();
}

class _BuildingWidgetState extends State<BuildingWidget> with MineMixin {
  SMINumber? _levelInput;
  SMINumber? _goldInput;
  SMITrigger? destroyTrigger;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    serviceLocator<AccountProvider>().addListener(() {
      var account = serviceLocator<AccountProvider>().account;
      if (widget.building.type == Buildings.base && account.tutorial_id == 24) {
        destroyTrigger?.value = true;
        serviceLocator<Sounds>().play("explosion",channel: "building");
        _levelInput?.value = -1;
      }
      if (!widget.building.getIsAvailable(account)) return;
      _levelInput?.value =
          account.buildings[widget.building.type]!.level.toDouble();
      if (widget.building.type == Buildings.treasury) {
        var x = ((5 * account.bank_account_balance) / widget.building.benefit);
        x = x.isInfinite ? 0 : x;
        _goldInput?.value = x.toDouble();
        return;
      }
      if (widget.building.type == Buildings.mine) {
        var x = ((5 * collectableGold(account)) / widget.building.benefit)
            .toDouble();
        x = x.isInfinite ? 0 : x;
        _goldInput?.value = x;
        return;
      }
    });

    var account = serviceLocator<AccountProvider>().account;
    if (widget.building.type == Buildings.mine) {
      _timer = Timer.periodic(const Duration(seconds: 10), (_) {
        var x = goldLevel(account).toDouble();
        _goldInput?.value = x;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Widgets.touchable(
      context,
      onTap: () {
        widget.onTap?.call();
      },
      child: SizedBox(
        width: 300.d,
        height: 280.d,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            LoaderWidget(
              AssetType.animation,
              "building_${widget.building.type.name}",
              fit: BoxFit.fitWidth,
              onRiveInit: (Artboard artboard) {
                final controller = StateMachineController.fromArtboard(
                    artboard, "State Machine 1")!;
                var input = controller.findInput<double>('level');
                if (input != null) {
                  _levelInput = input as SMINumber;
                  _levelInput!.value = widget.building.level.toDouble();
                }
                var account = serviceLocator<AccountProvider>().account;
                if (widget.building.type == Buildings.base &&
                    account.level < 3) {
                  destroyTrigger =
                      controller.findInput<bool>("destroy") as SMITrigger;
                  if (account.tutorial_id > 24) {
                    _levelInput!.value = -1;
                  }
                }
                if (widget.building.type == Buildings.treasury) {
                  var input = controller.findInput<double>('gold');
                  _goldInput = input as SMINumber;

                  var x = widget.building.level == 0
                      ? 0
                      : ((5 * account.bank_account_balance) /
                              widget.building.benefit)
                          .round();
                  _goldInput?.value = x.toDouble();
                }
                if (widget.building.type == Buildings.mine) {
                  var input = controller.findInput<double>('gold');
                  _goldInput = input as SMINumber;

                  var x = widget.building.level == 0
                      ? 0.0
                      : goldLevel(account).toDouble();
                  _goldInput?.value = x;
                }
                artboard.addController(controller);
              },
            ),
            widget.child ?? const SizedBox()
          ],
        ),
      ),
    );
  }
}
