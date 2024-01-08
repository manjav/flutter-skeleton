import 'package:rive/rive.dart';

import '../../data/core/building.dart';
import '../../mixins/background_mixin.dart';
import '../../mixins/reward_mixin.dart';
import '../../services/localization.dart';
import 'overlay.dart';

class UpgradeFeastOverlay extends AbstractOverlay {
  final Map<String, dynamic> args;
  const UpgradeFeastOverlay({required this.args, super.onClose, super.key})
      : super(type: OverlayType.feastUpgrade);

  @override
  createState() => _UpgradeFeastOverlayState();
}

class _UpgradeFeastOverlayState
    extends AbstractOverlayState<UpgradeFeastOverlay>
    with RewardScreenMixin, BackgroundMixin {
  late Building _building;

  @override
  void initState() {
    super.initState();

    children = [backgroundBuilder(), animationBuilder("evolvehero")];
    var buildingId = widget.args["id"] ?? 1002;
    _building = accountBloc.account!.buildings[buildingId.toBuildings()]!;
    var tribe = widget.args["tribe"] ?? accountBloc.account!.tribe;
    process(() async {
      var result = await accountBloc.upgrade(context, buildingId, tribe: tribe);
      if (tribe != null) {
        _building.level++;
        tribe.levels[buildingId] = tribe.levels[buildingId]! + 1;
      } else {
        _building.level = result["level"];
      }
      return result;
    });
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    updateRiveText("headerText", "upgrade_l".l());
    updateRiveText("upToCaptionText", "upgrade_l".l());
    return controller;
  }

  // @override
  // Future<bool> onRiveAssetLoad(
  //     FileAsset asset, Uint8List? embeddedBytes) async {
  //   if (asset is ImageAsset) {
  //     if (asset.name == "reward") {
  //       _loadRewardIcon(asset, "avatar_109");
  //       return true;
  //     } else if (asset.name == "item") {
  //       _loadItemIcon(asset);
  //       return true;
  //     }
  //   }
  //   return super.onRiveAssetLoad(asset, embeddedBytes);
  // }
}
