import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../data/core/building.dart';
import '../../services/device_info.dart';
import '../../utils/assets.dart';
import '../../view/widgets.dart';
import '../widgets/loader_widget.dart';

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
                  artboard.addController(controller);
                },
              ),
              widget.child ?? const SizedBox()
            ],
          )),
    );
  }
}
