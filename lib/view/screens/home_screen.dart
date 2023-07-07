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
  int _selectedTab = 2;
  final double _navbarHeight = 200.d;
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
          itemCount: _tabInputs.length,
          itemBuilder: _pageItemBuilder,
          onPageChanged: (value) => _selectTap(value, pageChange: false),
          controller: _pageController,
        )),
        SizedBox(
            height: _navbarHeight,
            child: ListView.builder(
                itemExtent: DeviceInfo.size.width / _tabInputs.length,
                itemBuilder: _tabItemBuilder,
                scrollDirection: Axis.horizontal,
                itemCount: _tabInputs.length))
      ],
    );
  }

  Widget? _pageItemBuilder(BuildContext context, int index) {
    log("Page $index");
    return Center(child: Text(_tabs[index]));
  }

  Widget? _tabItemBuilder(BuildContext context, int index) {
    var name = "home_tab_$index".l();
    return Widgets.touchable(
      onTap: () => _selectTap(index, tabsChange: false),
        child: Stack(alignment: const Alignment(0, 0.75), children: [
          LoaderWidget(
        AssetType.animation,
            "tab_$name",
        fit: BoxFit.fill,
        onRiveInit: (Artboard artboard) {
          final controller =
              StateMachineController.fromArtboard(artboard, 'Tab');
              _tabInputs[index] =
              controller!.findInput<bool>('close') as SMIBool;
              _tabInputs[index]!.value = index != _pageController.initialPage;
          artboard.addController(controller);
        },
      ),
    );
  }

  _selectTap(int index, {bool tabsChange = true, bool pageChange = true}) {
    if (tabsChange) {
      for (var i = 0; i < _tabInputs.length; i++) {
        _tabInputs[i]!.value = i != index;
      }
      setState(() => _selectedTab = index);
    }
    if (pageChange) {
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 700), curve: Curves.ease);
    }
  }
}
