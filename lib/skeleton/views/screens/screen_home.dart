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
  String _getRoute(String mode) {
    return switch (mode.substring(0, 4)) {
      "less" => Routes.lesson,
      "imit" => Routes.imitation,
      _ => Routes.series,
    };
  }

  List<ParentContent> _categories = [];
  final List<ParentContent> _newCategories = [];
  final List<ParentContent> _readsCategories = [];
  LoadingController controller = Get.put(LoadingController());

  final ValueNotifier<int> _selectedTabIndex = ValueNotifier(0);
  @override
  void onRender(Duration timeStamp) {
    super.onRender(timeStamp);
    services.addListener(
      () {
        if (services.state.status == ServiceStatus.initialize) {
          _initializeLessons(initializeMode: true);
        }
      },
    );
  }

  Future<void> _initializeLessons({bool initializeMode = false}) async {
    try {
      var account = serviceLocator<AccountProvider>();
      _categories = (await account.loadCategories());
      if (initializeMode) {
        if (!account.metadata.containsKey("targetLanguage")) {
          await Get.toNamed(Routes.onboarding);
          var onboard = _categories.where((c) {
            return c.children[0].id.contains("onboarding");
          });
          if (onboard.isNotEmpty) {
            await _loadLesson(onboard.first.children.first as ParentContent);
            return;
          }
        }

        await account.loadScores();
        await account.loadLeitner();
      }

      // Distinguishing read and new contents
      _readsCategories.clear();
      _newCategories.clear();
      for (var category in _categories) {
        if (hasReadCategory(account, category)) {
          _readsCategories.add(category);
        } else {
          _newCategories.add(category);
        }
      }

      setState(() {});
    } on SkeletonException catch (e) {
      alert(e.message, message: "error_${e.statusCode}".l());
    }
  }

  @override
  List<Widget> appBarElementsLeft() => [];

  bool hasReadCategory(AccountProvider account, ParentContent category) {
    var score = 0;
    var lessonCount = 0;
    for (var group in category.children) {
      if (account.scores.containsKey(group.id)) {
        score += (account.scores[group.id]!["score"] ?? 0) as int;
        lessonCount++;
      }
    }
    if (lessonCount > 0) {
      category.passLevel = (score / lessonCount).round();
    }
    return lessonCount > 0;
  }

  @override
  Widget build(BuildContext context) {
    if (services.state.status.index < ServiceStatus.initialize.index) {
      return const SizedBox();
    }

    return PopScope(
      canPop: false,
      child: ValueListenableBuilder(
        valueListenable: _selectedTabIndex,
        builder: (context, value, child) {
          return Scaffold(
            // backgroundColor: TColors.primary0,
            body: Padding(
              padding: EdgeInsets.all(10.d),
              child: switch (value) {
                1 => LeitnerPageItem(),
                2 => ProfilePageItem(),
                _ => DiscoveryPageItem(
                    _readsCategories,
                    _newCategories,
                    onSelectItem: _loadLesson,
                  ),
              },
            ),
            bottomNavigationBar: _navigationBar(value),
          );
        },
      ),
    );
  }

  Future<void> _loadLesson(ParentContent group) async {
    await Get.toNamed(_getRoute(group.mode), arguments: {"content": group});
    _initializeLessons();
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
