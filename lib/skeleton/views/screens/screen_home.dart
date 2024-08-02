import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app_export.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key}) : super(Routes.home);

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen> {
  int _categoryIndex = 0;
  final double _titleHeight = 40.d;
  final double _categoryHeight = 74.d;
  final double _lessonHeight = 64.d;
  final double _roadWidth = 64.d;
  final TextStyle _unitStyle = TStyles.small.copyWith(
      color: TColors.primary40, fontWeight: FontWeight.w100, height: 0.9);
  final TextStyle _numberStyle = TStyles.big.copyWith(
      color: TColors.primary40, fontWeight: FontWeight.w600, height: 0.9);

  Map<String, int>? _scores;
  List<ParentContent> _categories = [];
  LoadingController controller = Get.put(LoadingController());
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
        setState(() {});
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
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(0, 80.d, 14.d, 20.d),
        itemCount: _categories.length,
        itemBuilder: _categoryItemBuilder,
      ),
    );
  }

  Widget _categoryItemBuilder(BuildContext context, int index) {
    final category = _categories[index];
    return Column(
      children: [
        _sectionTitleBuilder(category),
        _categoryTitleBuilder(category),
        _categoryOpenBuilder(category),
      ],
    );
  }

  Widget _sectionTitleBuilder(ParentContent category) {
    if (category.index != 0) return const SizedBox();
    return SizedBox(
        height: _titleHeight,
        child: Text("⭠⭑ Section 1 ⭢  ",
            style: TStyles.large.copyWith(color: TColors.primary40)));
  }

  Widget _categoryTitleBuilder(ParentContent category) {
    return SizedBox(
      height: _categoryHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                width: 4.d,
                child: Widgets.rect(color: TColors.primary20),
              ),
              Widgets.rect(
                width: _roadWidth,
                padding: EdgeInsets.only(top: 2.d, bottom: 0),
                color: TColors.primary10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("UNIT", style: _unitStyle),
                    Text(NumberFormat("00").format(category.index + 1),
                        style: _numberStyle)
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Widgets.button(
              context,
              margin: EdgeInsets.all(2.d),
              padding: EdgeInsets.all(20.d),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: TColors.primary0,
                border: category.index == _categoryIndex
                    ? Border.all(color: TColors.primary20, width: 1.5.d)
                    : null,
                borderRadius: BorderRadius.all(Radius.circular(16.d)),
              ),
              child: Row(
                textDirection: Localization.dir,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Asset.load<Image>("tick", width: 32.d),
                  DirText(category.title),
                  SizedBox(width: 32.d),
                ],
              ),
              onPressed: () => setState(() => _categoryIndex = category.index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryOpenBuilder(ParentContent category) {
    var length =
        category.index == _categoryIndex ? category.children.length : 0;
    // if (category.index != _categoryIndex) return const SizedBox();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: length * _lessonHeight,
      // padding: EdgeInsets.fromLTRB(0, 4.d, 8.d, 4.d),
      child: Column(
        children: [
          for (var i = 0; i < length; i++) _lessonItemBuilder(category, i)
        ],
      ),
    );
  }

  Widget _lessonItemBuilder(ParentContent category, int index) {
    final group = category.children[index] as ParentContent;
    final id = "${group.id}_$index";
    final scoreNotifier = ValueNotifier(_scores![id] ?? 0);
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: _roadWidth,
              height: _lessonHeight,
            ),
            Positioned(
              top: 0,
              bottom: 0,
              width: 4.d,
              child: Widgets.rect(color: TColors.primary20),
            ),
            Asset.load<SvgPicture>("checkpoint", width: 18.d),
          ],
        ),
        Expanded(
          child: Widgets.rect(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: TColors.primary20,
              borderRadius: _getRaduis(index, category.children.length),
            ),
            height: _lessonHeight,
            child: Widgets.button(
              context,
              radius: 12.d,
              margin: EdgeInsets.symmetric(horizontal: 12.d, vertical: 4.d),
              padding: EdgeInsets.all(14.d),
              color: TColors.primary0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: DirText(
                      group.title.simplify(),
                      textAlign: TextAlign.center,
                      style: TStyles.large,
                    ),
                  ),
                  Asset.load<SvgPicture>(group.mode, width: 20.d),
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

                var routName =
                    group.mode == "lessons" ? Routes.lesson : Routes.series;
                var s =
                    await Get.toNamed(routName, arguments: {"content": group});
                if (s == null || s <= scoreNotifier.value) return;
                await serviceLocator<AccountProvider>().saveScore(id, s);
                scoreNotifier.value = s;
              },
            ),
          ),
        ),
      ],
    );
  }

  BorderRadius? _getRaduis(int index, int length) {
    final raduis = Radius.circular(16.d);
    if (length == 1) {
      return BorderRadius.all(raduis);
    } else if (index == 0) {
      return BorderRadius.only(topLeft: raduis, topRight: raduis);
    } else if (index >= length - 1) {
      return BorderRadius.only(bottomLeft: raduis, bottomRight: raduis);
    } else {
      return null;
    }
  }
}
