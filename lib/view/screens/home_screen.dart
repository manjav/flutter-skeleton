import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';

import '../../blocs/services.dart';
import '../../services/deviceinfo.dart';
import '../../utils/assets.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/level_indicator.dart';
import '../widgets/loaderwidget.dart';
import 'iscreen.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key}) : super(Routes.home);

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen> {
  @override
  void onRender(Duration timeStamp) {
    super.onRender(timeStamp);
    var bloc = BlocProvider.of<Services>(context);
    bloc.add(ServicesEvent(ServicesInitState.complete, null));
  }

  final double _navbarHeight = 200.d;
  final Map<String, SMIBool> _tabInputs = {};
  final PageController _pageController = PageController(initialPage: 2);
  final List<String> _tabs = ['shop', 'cards', 'battle', 'message', 'auctions'];

  @override
  List<Widget> appBarElements() {
    return <Widget>[
      SizedBox(
          width: 194.d,
          height: 202.d,
          child: const LevelIndicator(level: "2", xp: 12)),
      ...super.appBarElements(),
    ];
  }

  @override
  Widget contentFactory() {
    return Column(
      children: [
        Expanded(
            child: PageView.builder(
          itemCount: _tabs.length,
          itemBuilder: _pageItemBuilder,
          onPageChanged: (value) => _selectTap(value, pageChange: false),
          controller: _pageController,
        )),
        SizedBox(
            height: _navbarHeight,
            child: ListView.builder(
                itemExtent: DeviceInfo.size.width / _tabs.length,
                itemBuilder: _tabItemBuilder,
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length))
      ],
    );
  }

  Widget? _pageItemBuilder(BuildContext context, int index) {
    log("Page $index");
    return Center(child: Text(_tabs[index]));
  }

  Widget? _tabItemBuilder(BuildContext context, int index) {
    return Widgets.touchable(
      onTap: () => _selectTap(index, tabsChange: false),
      child: LoaderWidget(
        AssetType.animation,
        "tab_${_tabs[index]}",
        fit: BoxFit.fill,
        onRiveInit: (Artboard artboard) {
          final controller =
              StateMachineController.fromArtboard(artboard, 'Tab');
          _tabInputs[_tabs[index]] =
              controller!.findInput<bool>('close') as SMIBool;
          _tabInputs[_tabs[index]]!.value =
              index == _pageController.initialPage;
          artboard.addController(controller);
        },
      ),
    );
  }

  _selectTap(int index, {bool tabsChange = true, bool pageChange = true}) {
    if (tabsChange) {
      for (var key in _tabInputs.keys) {
        _tabInputs[key]!.value = _tabs[index] != key;
      }
    }
    if (pageChange) {
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 700), curve: Curves.ease);
    }
  }
}
