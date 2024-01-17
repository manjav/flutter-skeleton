import 'package:flutter/material.dart';

import '../../skeleton/skeleton.dart';

@optionalTypeArgs
mixin TabBuilderMixin<T extends StatefulWidget> on State<T> {
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
      left: 0,
      right: 0,
      height: 225.d,
      child: Asset.load<Image>('popup_header',
          centerSlice: ImageCenterSliceData(
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
    return Expanded(
      child: Widgets.button(context,
          margin: EdgeInsets.symmetric(horizontal: 6.d),
          padding: EdgeInsets.zero,
          height: 118.d,
          decoration: Widgets.imageDecorator(
              "popup_tab_$imageName", ImageCenterSliceData(68, 42)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              data.icon == null
                  ? const SizedBox()
                  : Asset.load<Image>(data.icon!, width: 56.d),
              SizedBox(width: data.icon == null ? 0 : 32.d),
              SkinnedText(data.title),
            ],
          ), onPressed: () {
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
