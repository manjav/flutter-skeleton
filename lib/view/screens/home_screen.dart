import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';

import '../../blocs/services.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/items/page_item.dart';
import '../items/page_item_cards.dart';
import '../items/page_item_map.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/level_indicator.dart';
import '../widgets/loaderwidget.dart';
import '../widgets/skinnedtext.dart';
import 'iscreen.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key}) : super(Routes.home);

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen> {
  int _selectedTab = 2;
  final double _navbarHeight = 210.d;
  final _tabInputs = List<SMIBool?>.generate(5, (index) => null);
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: _selectedTab);
    super.initState();
  }

  @override
  void onRender(Duration timeStamp) {
    super.onRender(timeStamp);
    var bloc = BlocProvider.of<Services>(context);
    bloc.add(ServicesEvent(ServicesInitState.complete, null));
  }

  @override
  List<Widget> appBarElements() {
    if (_selectedTab == 2) {
      return <Widget>[
        SizedBox(
            width: 196.d,
            height: 200.d,
            child: const LevelIndicator(level: "2", xp: 12)),
        ...super.appBarElements()
          ..add(Widgets.button(
              width: 110.d,
              height: 110.d,
              padding: EdgeInsets.all(16.d),
              child: Asset.load<Image>('ui_settings'))),
      ];
    }
    return super.appBarElements();
  }

  @override
  Widget contentFactory() {
    return Widgets.rect(
        color: const Color(0xffAA9A45),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              itemCount: _tabInputs.length,
              itemBuilder: _pageItemBuilder,
              onPageChanged: (value) => _selectTap(value, pageChange: false),
              controller: _pageController,
            ),
            SizedBox(
                height: _navbarHeight,
                child: ListView.builder(
                    itemExtent: DeviceInfo.size.width / _tabInputs.length,
                    itemBuilder: _tabItemBuilder,
                    scrollDirection: Axis.horizontal,
                    itemCount: _tabInputs.length))
          ],
        ));
  }

  Widget? _pageItemBuilder(BuildContext context, int index) {
    var name = "home_tab_$index".l();
    return switch (name) {
      "cards" => const CardsPageItem(),
      "battle" => const MainMapPageItem(),
      _ => AbstractPageItem(name)
    };
  }

  Widget? _tabItemBuilder(BuildContext context, int index) {
    var name = "home_tab_$index".l();
    return Widgets.touchable(
        onTap: () => _selectTap(index, tabsChange: false),
        child: Stack(alignment: const Alignment(0, 0.75), children: [
          LoaderWidget(
            AssetType.animation,
            "tab_$name",
            fit: BoxFit.fitWidth,
            onRiveInit: (Artboard artboard) {
              final controller =
                  StateMachineController.fromArtboard(artboard, 'Tab');
              _tabInputs[index] =
                  controller!.findInput<bool>('active') as SMIBool;
              _tabInputs[index]!.value = index == _pageController.initialPage;
              artboard.addController(controller);
            },
          ),
          _selectedTab == index
              ? SkinnedText(name.toPascalCase(), style: TStyles.small)
              : const SizedBox()
        ]));
  }

  _selectTap(int index, {bool tabsChange = true, bool pageChange = true}) {
    if (tabsChange) {
      for (var i = 0; i < _tabInputs.length; i++) {
        _tabInputs[i]!.value = i == index;
      }
      setState(() => _selectedTab = index);
    }
    if (pageChange) {
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 700), curve: Curves.ease);
    }
  }
}
