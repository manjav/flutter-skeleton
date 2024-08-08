import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';

import '../../../app_export.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key}) : super(Routes.home);

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen> {
  Map<String, Map<String, dynamic>>? _scores;
  SMIInput<double>? _categoryIndex;
  TabController? _tabController;
  List<ParentContent> _categories = [];
  LoadingController controller = Get.put(LoadingController());
  final PageController _pageController = PageController(viewportFraction: 0.8);
  final _colors = {
    "lessons": TColors.blue,
    "practice": TColors.orange,
    "grammar": TColors.cyan,
    "vocabulary": TColors.purpule,
  };

// Consumer<AccountProvider>(builder: (_, state, child) {
  @override
  void onRender(Duration timeStamp) {
    super.onRender(timeStamp);
    services.addListener(() async {
      if (services.state.status == ServiceStatus.initialize) {
        var account = serviceLocator<AccountProvider>();
        if (!account.metadata.containsKey("targetLanguage")) {
          Localization.languageCode = "fa";
          await serviceLocator<AccountProvider>().update(
              nativeLanguage: Localization.languageCode,
              targetLanguage: "en",
              displayName: "guest_${DeviceInfo.model}");
          // await Future.delayed(const Duration(seconds: 1));
          // await Get.toNamed(Routes.onboarding);
        }
        _categories = (await account.loadCategories());
        _scores = await account.loadScores();
        _tabController = TabController(length: _categories.length, vsync: this);
        setState(() {});
        // await Future.delayed(const Duration(seconds: 1));
        // Get.toNamed(Routes.popupMentor, args: {
        //   "message":
        //       "سلام من قلیدونم. به ده ما خوش اومدی!\nما تو دهاتمون به ترکی صحبت می‌کنیم اما نگران نباش. من به تو کمک می‌کنم تا بتونی زبون ما رو یاد بگیری. خوب بریم اول بقالی محل کمی خرید کنیم."
        // });
      }
    });
  }

  @override
  List<Widget> appBarElementsLeft() => [];

  @override
  Widget contentFactory(double paddingTop) {
    if (services.state.status.index < ServiceStatus.initialize.index) {
      return const SizedBox();
    }
    return PopScope(
      canPop: false,
      child: Stack(
        alignment: Alignment.center,
        children: [
          LoaderWidget(
            AssetType.animation,
            "home",
            fit: BoxFit.fill,
            onRiveInit: (artboard) {
              final controller = StateMachineController.fromArtboard(
                  artboard, "State Machine 1");
              _categoryIndex = controller?.findInput<double>("category");
              artboard.addController(controller!);
            },
          ),
          Align(
            alignment: const Alignment(0, 0.4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: DeviceInfo.size.width,
                  height: 300.d,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _categories.length,
                    itemBuilder: _categoryItemBuilder,
                    onPageChanged: (value) {
                      _categoryIndex?.value = value.toDouble();
                      _tabController?.animateTo(value,
                          duration: const Duration(microseconds: 800));
                    },
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 50.d),
                  child: TabPageSelector(
                    indicatorSize: 8.d,
                    controller: _tabController,
                    color: TColors.white30,
                    selectedColor: TColors.white,
                    borderStyle: BorderStyle.none,
                  ),
                ),
              ],
            ),
          ),
          Align(
              alignment: const Alignment(0, 0.85),
              child: Widgets.rect(
                  radius: 12.d,
                  color: TColors.purpule,
                  padding: EdgeInsets.all(12.d),
                  child: const Text("      نسخه آزمایشی      "))),
        ],
      ),
    );
  }

  Widget _categoryItemBuilder(BuildContext context, int index) {
    var category = _categories[index];

    return Widgets.rect(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(10.d, 20.d, 10.d, 10.d),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: TColors.primary0,
        borderRadius: BorderRadius.all(Radius.circular(20.d)),
        boxShadow: [BoxShadow(blurRadius: 8.d, color: TColors.primary50)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DirText(category.title, style: TStyles.big),
          const Expanded(child: SizedBox()),
          Column(
            children: [
              for (var i = 0; i < category.children.length; i++)
                _lessonItemBuilder(category.children[i] as ParentContent, i)
            ],
          ),
        ],
      ),
    );
  }

  Widget _lessonItemBuilder(ParentContent group, int index) {
    var id = "${group.id}_$index";
    var scoreNotifier = ValueNotifier(_scores![id] ?? 0);
    return Widgets.button(
      context,
      height: 52.d,
      radius: 12.d,
      margin: EdgeInsets.all(2.d),
      padding: EdgeInsets.all(10.d),
      color: _colors[group.mode],
      // width: DeviceInfo.size.width * 0.8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 16.d),
          DirText(group.title.simplify(), style: TStyles.largeInvert),
          SizedBox(width: 16.d),
          LoaderWidget(AssetType.vector, group.mode, height: 24.d),
          // ValueListenableBuilder(
          //   valueListenable: scoreNotifier,
          //   builder: (context, value, child) =>
          //       Text(["☆☆☆", "★☆☆", "★★☆", "★★★"][scoreNotifier.value]),
          // ),
        ],
      ),
      onPressed: () async {
        if (group.children.isEmpty) {
          await serviceLocator<AccountProvider>().loadGroup(group);
        }

        var routName = group.mode == "lessons" ? Routes.lesson : Routes.series;
        var s = await Get.toNamed(routName, arguments: {"content": group});
        if (s == null || s <= scoreNotifier.value) return;
        await serviceLocator<AccountProvider>().saveScore(id, s);
        scoreNotifier.value = s;
      },
    );
  }
}
