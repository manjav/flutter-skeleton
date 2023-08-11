import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../data/core/building.dart';
import '../../services/deviceinfo.dart';
import '../../utils/assets.dart';
import '../../view/widgets.dart';
import '../../view/widgets/loaderwidget.dart';

class BuildingWidget extends StatefulWidget {
  final Building building;
  final Widget? child;
  final void Function()? onTap;
  const BuildingWidget(this.building, {super.key, this.child, this.onTap});

  @override
  State<BuildingWidget> createState() => _BuildingWidgetState();
}

class _BuildingWidgetState extends State<BuildingWidget> {
  SMINumber? _levelInput;

  @override
  Widget build(BuildContext context) {
    return Widgets.touchable(
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
                      artboard, 'Building')!;
                  var input = controller.findInput<double>('level');
                  // controller.stateMachine.listeners.
                  if (input != null) {
                    _levelInput = input as SMINumber;
                    _levelInput!.value = widget.building.level.toDouble();
                  }
                  artboard.addController(controller);
                },
              ),
              widget.child ?? const SizedBox()
            ],
          )),
    );
  }
}
