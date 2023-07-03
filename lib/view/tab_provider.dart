import 'package:flutter/material.dart';

import '../../services/deviceinfo.dart';
import '../../view/widgets/skinnedtext.dart';
import '../utils/assets.dart';
import 'widgets.dart';

@optionalTypeArgs
mixin TabProviderStateMixin<T extends StatefulWidget> on State<T> {
  int _selectedTabIndex = -1;

  @protected
  int get selectedTabIndex => _selectedTabIndex;
  @protected
  set selectedTabIndex(int index) {
    if (_selectedTabIndex == index) {
      return;
    }
    _selectedTabIndex = index;
    setState(() {});
    onTapChange();
  }

  Widget innerChromeFactory() {
    return Positioned(
      top: 68.d,
      left: 24.d,
      right: 24.d,
      height: 225.d,
      child: Asset.load<Image>('popup_header',
          centerSlice: ImageCenterSliceDate(
            220,
            120,
            const Rect.fromLTWH(106, 110, 4, 4),
          )),
    );
  }

  Widget tabsBuilder({required List<TabData> data}) {
    return Column(children: [
      Row(
        children: [
          for (var i = 0; i < data.length; i++) _tabItemBuilder(i, data[i])
        ],
      )
    ]);
  }

  Widget _tabItemBuilder(int index, TabData data) {
    var imageName = index == selectedTabIndex ? 'selected' : 'normal';
    var slicingData =
        ImageCenterSliceDate(68, 42, const Rect.fromLTWH(33, 33, 2, 2));
    return Expanded(
      child: Widgets.button(
          margin: EdgeInsets.symmetric(horizontal: 6.d),
          height: 120.d,
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill,
                  centerSlice: slicingData.centerSlice,
                  image: Asset.load<Image>(
                    'popup_tab_$imageName',
                    centerSlice: slicingData,
                  ).image)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkinnedText(data.title),
              SizedBox(width: data.icon == null ? 0 : 32.d),
              data.icon == null
                  ? const SizedBox()
                  : Asset.load<Image>(data.icon!, width: 72.d),
            ],
          ),
          onPressed: () {
            selectedTabIndex = index;
          }),
    );
  }

  void onTapChange() {}
}

class TabData {
  final String title;
  final String? icon;
  TabData(this.title, [this.icon]);
}
