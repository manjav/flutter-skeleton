import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../data/core/account.dart';
import '../../data/core/building.dart';
import '../../mixins/service_finder_mixin.dart';
import '../../services/device_info.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../widgets.dart';
import 'loader_widget.dart';
import 'skinned_text.dart';

class TabNavigator extends StatefulWidget {
  final int tabsCount;
  final Function(int)? onChange;
  final ValueNotifier<int>? punchIndex;
  final ValueNotifier<int> selectedIndex;

  const TabNavigator({
    required this.tabsCount,
    required this.selectedIndex,
    this.punchIndex,
    this.onChange,
    super.key,
  });

  @override
  State<TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator>
    with ServiceFinderWidgetMixin {
  final double _navbarHeight = 210.d;
  final List<SMITrigger?> _punchInputs = [];
  final List<SMIBool?> _selectionInputs = [];

  @override
  void initState() {
    for (var i = 0; i < widget.tabsCount; i++) {
      _punchInputs.add(null);
      _selectionInputs.add(null);
    }
    widget.selectedIndex.addListener(() {
      for (var i = 0; i < widget.tabsCount; i++) {
        _selectionInputs[i]!.value = i == widget.selectedIndex.value;
      }
    });
    widget.punchIndex?.addListener(() {
      if (widget.punchIndex!.value >= 0 &&
          widget.punchIndex!.value < widget.tabsCount) {
        _punchInputs[widget.punchIndex!.value]!.value = true;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var account = accountProvider.account;
    var tabSize = DeviceInfo.size.width / _selectionInputs.length;
    return SizedBox(
        height: _navbarHeight,
        child: ListView.builder(
            itemExtent: tabSize,
            reverse: Localization.isRTL,
            scrollDirection: Axis.horizontal,
            itemBuilder: (c, i) => _tabItemBuilder(account, i, tabSize),
            itemCount: _selectionInputs.length));
  }

  Widget? _tabItemBuilder(Account account, int index, double size) {
    return Widgets.touchable(context,
        onTap: () => widget.onChange?.call(index),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
                top: index == 3 ? 10.d : 0,
                width: size * (index == 3 ? 0.6 : 1),
                height: size * (index == 3 ? 0.6 : 1),
                child: LoaderWidget(
                  AssetType.animation,
                  "tab_$index",
                  fit: BoxFit.fitWidth,
                  riveAssetLoader: _onTabAssetLoad,
                  onRiveInit: (Artboard artboard) {
                    final controller =
                        StateMachineController.fromArtboard(artboard, "Tab");
                    _selectionInputs[index] =
                        controller!.findInput<bool>("active") as SMIBool;
                    _punchInputs[index] =
                        controller.findInput<bool>("punch") as SMITrigger?;
                    _selectionInputs[index]!.value =
                        index == widget.selectedIndex.value;
                    if (index == 3) {
                      var input =
                          controller.findInput<double>("level") as SMINumber;
                      input.value = account.tribe != null
                          ? account.tribe!.levels[Buildings.tribe.id]!
                              .toDouble()
                          : 0.0;
                    }
                    artboard.addController(controller);
                  },
                )),
            widget.selectedIndex.value == index
                ? Positioned(
                    bottom: 6.d,
                    child: SkinnedText("home_tab_$index".l().toPascalCase(),
                        style: TStyles.small))
                : const SizedBox()
          ],
        ));
  }

  Future<bool> _onTabAssetLoad(FileAsset asset, Uint8List? list) async {
    if (asset is ImageAsset && asset.name == "background") {
      var bytes = await rootBundle.load('assets/images/tab_background.webp');
      asset.image = await ImageAsset.parseBytes(bytes.buffer.asUint8List());
      return true;
    }
    return false;
  }
}
