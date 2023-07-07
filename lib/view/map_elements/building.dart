import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../services/deviceinfo.dart';
import '../../utils/assets.dart';
import '../../view/widgets.dart';
import '../../view/widgets/loaderwidget.dart';

enum BuildingType { battle, cards, message, mine, shop, tribe, quest, war }

class Building extends StatefulWidget {
  final BuildingType type;
  final void Function()? onTap;
  const Building(this.type, {super.key, this.onTap});

  @override
  State<Building> createState() => _BuildingState();
}

class _BuildingState extends State<Building> {
  SMINumber? _levelInput;

  @override
  Widget build(BuildContext context) {
    return Widgets.touchable(
      onTap: () {
        if (_levelInput != null) {
          _levelInput!.value = (_levelInput!.value + 1) % 12;
        }
        widget.onTap?.call();
      },
      child: SizedBox(
        width: 300.d,
        height: 280.d,
        child: LoaderWidget(
          AssetType.animation,
          "building_${widget.type.name}",
          fit: BoxFit.fitWidth,
          onRiveInit: (Artboard artboard) {
            final controller =
                StateMachineController.fromArtboard(artboard, 'Building')!;
            var input = controller.findInput<double>('level');
            if (input != null) {
              _levelInput = input as SMINumber;
            }
            artboard.addController(controller);
          },
        ),
      ),
    );
  }
}
