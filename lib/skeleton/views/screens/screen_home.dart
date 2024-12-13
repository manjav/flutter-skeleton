import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../app_export.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key}) : super(Routes.home);

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen> {
  LoadingController controller = Get.put(LoadingController());

  final ValueNotifier<int> _selectedTabIndex = ValueNotifier(0);

  @override
  List<Widget> appBarElementsLeft() => [];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ValueListenableBuilder(
        valueListenable: _selectedTabIndex,
        builder: (context, value, child) {
          return Scaffold(
            body: Padding(
              padding: EdgeInsets.all(10.d),
              child: switch (value) {
                1 => LeitnerPageItem(),
                2 => ProfilePageItem(),
                _ => DiscoveryPageItem(),
              },
            ),
            bottomNavigationBar: _navigationBar(value),
          );
        },
      ),
    );
  }

  Widget _navigationBar(int selectedIndex) {
    final tabCount = 3;
    final itemWidth = 80.d;
    Alignment getAlign(int index) =>
        Alignment(index / (tabCount - 1) * 2 - 1, -1);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.d),
      height: 86.d,
      child: Stack(
        children: [
          AnimatedAlign(
            curve: Curves.easeOutExpo,
            alignment: getAlign(selectedIndex),
            duration: Duration(milliseconds: 300),
            child: Widgets.rect(
                color: TColors.primary90,
                width: itemWidth,
                height: 50.d,
                radius: 16.d),
          ),
          for (var i = 0; i < tabCount; i++)
            Align(
              alignment: getAlign(i),
              child: Widgets.button(
                context,
                height: 50.d,
                width: itemWidth,
                padding: EdgeInsets.all(6.d),
                // color: TColors.teal,
                child: IgnorePointer(
                  child: Asset.load<SvgPicture>(
                    "tab_$i",
                    svgColorFilter: ColorFilter.mode(
                        i == _selectedTabIndex.value
                            ? TColors.primary10
                            : TColors.primary90,
                        BlendMode.srcIn),
                    height: 36.d,
                  ),
                ),
                onPressed: () => _selectedTabIndex.value = i,
              ),
            ),
        ],
      ),
    );
  }
}
