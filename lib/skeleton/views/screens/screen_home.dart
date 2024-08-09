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
  final double _lessonHeight = 70.d;
  final double _headerHight = 186.d;
  final double _roadWidth = 64.d;
  final TextStyle _unitStyle = TStyles.small.copyWith(
      color: TColors.primary40, fontWeight: FontWeight.w100, height: 0.9);
  final TextStyle _numberStyle = TStyles.big.copyWith(
      color: TColors.primary40, fontWeight: FontWeight.w600, height: 0.9);
  final _colors = {
    "lessons": TColors.blue,
    "practice": TColors.orange,
    "grammar": TColors.cyan,
    "vocabulary": TColors.purpule,
  };

  Map<String, Map<String, dynamic>>? _scores;
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
        child: Stack(
          children: [
            ListView.builder(
              padding: EdgeInsets.fromLTRB(0, 80.d, 14.d, 30.d),
              itemCount: _categories.length,
              itemBuilder: _categoryItemBuilder,
            ),
            Transform.rotate(
                alignment: Alignment.topLeft,
                angle: -0.5,
                child: Align(
                    alignment: const Alignment(-1.9, -0.92),
                    child: Widgets.rect(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              // color: Colors.red,
                              blurRadius: 8.d,
                            )
                          ],
                          color: TColors.red,
                        ),
                        padding: EdgeInsets.fromLTRB(58.d, 12.d, 66.d, 12.d),
                        child: Text("نسخه آزمایشی",
                            style: TStyles.mediumInvert)))),
          ],
        ));
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
    final thickness = category.index == _categoryIndex ? 1.8.d : 0.0;
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: thickness,
                    bottom: thickness,
                    width: 128.d,
                    right: Localization.isRTL ? thickness : null,
                    left: !Localization.isRTL ? thickness : null,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(16.d)),
                      child: LoaderWidget(
                        AssetType.image,
                        category.id,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Widgets.rect(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: TColors.primary0,
                      gradient: LinearGradient(
                          colors: [
                            TColors.primary0,
                            TColors.primary0,
                            TColors.primary0.withOpacity(0.6),
                          ],
                          begin: const FractionalOffset(0.0, 0.0),
                          end: const FractionalOffset(0.8, 0.0),
                          stops: const [0.0, 0.75, 1.0],
                          tileMode: TileMode.clamp),
                      border: category.index == _categoryIndex
                          ? Border.all(
                              color: TColors.primary20, width: thickness)
                          : null,
                      borderRadius: BorderRadius.all(Radius.circular(16.d)),
                    ),
                  ),
                  DirText(category.title),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: length <= 0
          ? const SizedBox()
          : Column(
              children: [
                for (var i = -1; i < length; i++)
                  Row(
                    children: [
                      _lessonRoadRenderer(category, i),
                      _lessonItemBuilder(category, i)
                    ],
                  ),
              ],
            ),
    );
  }

  Widget _lessonRoadRenderer(ParentContent category, int index) {
    final paddingBottom = index >= category.children.length - 1 ? 16.d : 0;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: _roadWidth,
          height: (index < 0 ? _headerHight : _lessonHeight) + paddingBottom,
        ),
        Positioned(
          top: 0,
          bottom: 0,
          width: 4.d,
          child: Widgets.rect(color: TColors.primary20),
        ),
        _groupIndicator(category, index),
      ],
    );
  }

  Widget _groupIndicator(ParentContent category, int index) {
    if (index < 0) return const SizedBox();
    final group = category.children[index] as ParentContent;
    final passed = _scores!.containsKey(group.id);
    return Asset.load<SvgPicture>(passed ? "point_passed" : "point_empty",
        width: passed ? 25.d : 20.d);
  }

  Widget _lessonItemBuilder(ParentContent category, int index) {
    if (index < 0) {
      return Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(16.d)),
          child: LoaderWidget(
            AssetType.image,
            category.id,
            height: _headerHight,
            fit: BoxFit.fill,
          ),
        ),
      );
    }
    final group = category.children[index] as ParentContent;
    return Expanded(
      child: Widgets.rect(
        margin: EdgeInsets.only(
            bottom: index >= category.children.length - 1 ? 16.d : 0),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: TColors.primary20,
          borderRadius: _getRaduis(index, category.children.length),
        ),
        height: _lessonHeight,
        child: Widgets.button(
          context,
          radius: 12.d,
          color: _colors[group.mode],
          margin: EdgeInsets.all(6.d),
          padding: EdgeInsets.symmetric(horizontal: 14.d),
          child: Row(
            textDirection: Localization.dir,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoaderWidget(AssetType.vector, group.mode, width: 20.d),
              SizedBox(width: 16.d),
              Expanded(
                child: DirText(
                  group.title.simplify(),
                  style: TStyles.largeInvert,
                ),
              ),
            ],
          ),
          onPressed: () async {
            if (group.children.isEmpty) {
              await serviceLocator<AccountProvider>().loadGroup(group);
            }

            var routName =
                group.mode == "lessons" ? Routes.lesson : Routes.series;
            await Get.toNamed(routName, arguments: {"content": group});
            setState(() {});
            // if (s == null || s <= scoreNotifier.value) return;
            // await serviceLocator<AccountProvider>().saveScore(id, s);
            // scoreNotifier.value = s;
          },
        ),
      ),
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
