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
  final double _groupHeight = 70.d;
  final double _headerHight = 186.d;
  final double _roadWidth = 64.d;
  final TextStyle _unitStyle = TStyles.small.copyWith(
      color: TColors.primary40, fontWeight: FontWeight.w100, height: 0.9);
  final TextStyle _unitStylePassed = TStyles.small
      .copyWith(color: TColors.green, fontWeight: FontWeight.w100, height: 0.9);
  final TextStyle _numberStyle = TStyles.big.copyWith(
      color: TColors.primary40, fontWeight: FontWeight.w600, height: 0.9);
  final TextStyle _numberStylePassed = TStyles.big
      .copyWith(color: TColors.green, fontWeight: FontWeight.w600, height: 0.9);

  Color _getColors(String mode) {
    return switch (mode.substring(0, 4)) {
      "less" => TColors.blue,
      "prac" => TColors.orange,
      "gram" => TColors.cyan,
      "voca" => TColors.purpule,
      "chat" => TColors.primary60,
      _ => TColors.gray,
    };
  }

  String _getRoute(String mode) {
    return switch (mode.substring(0, 4)) {
      "less" => Routes.lesson,
      "chat" => Routes.chat,
      _ => Routes.series,
    };
  }

  Map<String, Map<String, dynamic>> _scores = {};
  List<ParentContent> _categories = [];
  LoadingController controller = Get.put(LoadingController());
  @override
  void onRender(Duration timeStamp) {
    super.onRender(timeStamp);
    services.addListener(_initializeLessons);
  }

  void _initializeLessons() async {
    if (services.state.status != ServiceStatus.initialize) return;
    try {
      var account = serviceLocator<AccountProvider>();
      if (!account.metadata.containsKey("targetLanguage")) {
        await serviceLocator<AccountProvider>().update(
            nativeLanguage: Localization.languageCode,
            targetLanguage: Localization.targetLanguage,
            displayName: "guest_${DeviceInfo.model}");
        // await Future.delayed(const Duration(seconds: 1));
        // await Get.toNamed(Routes.onboarding);
      }
      _categories = (await account.loadCategories());
      _scores = await account.loadScores();
      _categoryIndex = _firstIncompleteGroup();
      setState(() {});
    } on SkeletonException catch (e) {
      alert(e.message, "error_${e.statusCode}".l());
    }
  }

  @override
  List<Widget> appBarElementsLeft() {
    final account = serviceLocator<AccountProvider>();
    if (account.metadata.isEmpty) return [];
    return [
      SkinnedButton(
        label: "i",
        color: account.isTester ? TColors.orange : TColors.primary40,
        margin: EdgeInsets.all(8.d),
        padding: EdgeInsets.symmetric(horizontal: 12.d),
        onPressed: () => Get.toNamed(Routes.popupMessage, arguments: {
          "title": "about_us_title".l(),
          "message": "about_us_message".l()
        }),
        onLongPress: () async {
          if (!account.isTester) {
            final username =
                "test_${DeviceInfo.model}_${(account.account.user.location ?? "/").split("/")[1]}";
            await account.update(username: username);
            Pref.username.setString(username);
            if (mounted) {
              MyApp.restartApp(context);
            }
          }
        },
      )
    ];
  }

  // Find first incomplete group
  int _firstIncompleteGroup() {
    for (var category in _categories) {
      if (!isCategoryComplete(category, true)) {
        return category.index;
      }
    }
    return 0;
  }

  bool isCategoryComplete(ParentContent category, [bool changePass = false]) {
    for (var group in category.children) {
      if (!_scores.containsKey((group as ParentContent).id)) {
        if (changePass) {
          group.passLevel = 1;
        }
        return false;
      }
      group.passLevel = 2;
    }
    return true;
  }

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
              itemCount: _categories.length + 1,
              itemBuilder: _categoryItemBuilder,
            ),
          ],
        ));
  }

  Widget _categoryItemBuilder(BuildContext context, int index) {
    if (index >= _categories.length) {
      return Widgets.button(
        context,
        margin: EdgeInsets.fromLTRB(_roadWidth, 20.d, 0, 0),
        height: 70.d,
        color: TColors.primary20,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("next_section".l(), style: TStyles.largeInvert),
          SizedBox(width: 10.d),
          Asset.load<SvgPicture>("group_lock")
        ]),
      );
    }
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
        child: Text("section_num".l(["1".convert()]),
            style: TStyles.large.copyWith(color: TColors.primary40)));
  }

  Widget _categoryTitleBuilder(ParentContent category) {
    final thickness = category.index == _categoryIndex ? 1.8.d : 0.0;
    final isPassed = isCategoryComplete(category);
    final percent = 1 - _categoryHeight / DeviceInfo.size.width;
    return SizedBox(
      height: _categoryHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: category.index == 0 ? _categoryHeight * 0.5 : 0,
                bottom:
                    category == _categories.last ? _categoryHeight * 0.5 : 0,
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
                    Text("UNIT",
                        style: isPassed ? _unitStylePassed : _unitStyle),
                    Text(NumberFormat("00").format(category.index + 1),
                        style: isPassed ? _numberStylePassed : _numberStyle)
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
                          begin: FractionalOffset(percent * 0.65, 0.0),
                          end: FractionalOffset(percent, 0.0),
                          stops: const [0.0, 0.75, 1.0],
                          tileMode: TileMode.clamp),
                      border: category.index == _categoryIndex
                          ? Border.all(
                              color: TColors.primary20, width: thickness)
                          : null,
                      borderRadius: BorderRadius.all(Radius.circular(16.d)),
                    ),
                  ),
                  Positioned(
                    right: Localization.isRTL ? 56.d : 12.d,
                    left: !Localization.isRTL ? 56.d : 12.d,
                    child: DirText(category.title),
                  ),
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
                      _groupRoadRenderer(category, i),
                      _groupItemBuilder(category, i)
                    ],
                  ),
              ],
            ),
    );
  }

  Widget _groupRoadRenderer(ParentContent category, int index) {
    final paddingBottom = index >= category.children.length - 1 ? 16.d : 0;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: _roadWidth,
          height: (index < 0 ? _headerHight : _groupHeight) + paddingBottom,
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
    final passed = _scores.containsKey(group.id);
    return Asset.load<SvgPicture>(passed ? "point_passed" : "point_empty",
        width: passed ? 34.d : 20.d);
  }

  Widget _groupItemBuilder(ParentContent category, int index) {
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
    final text = group.title.simplify();
    final locked = group.passLevel <= 0;
    return Expanded(
      child: Widgets.rect(
        margin: EdgeInsets.only(
            bottom: index >= category.children.length - 1 ? 16.d : 0),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: TColors.primary0,
          borderRadius: _getRaduis(index, category.children.length),
        ),
        height: _groupHeight,
        child: Widgets.button(
          context,
          radius: 12.d,
          color: locked ? TColors.primary20 : _getColors(group.mode),
          margin: EdgeInsets.all(6.d),
          padding: EdgeInsets.symmetric(horizontal: 14.d),
          child: Row(
            textDirection: text.getDirection(),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoaderWidget(AssetType.vector, group.mode, width: 30.d),
              SizedBox(width: 16.d),
              Expanded(
                child: DirText(text, style: TStyles.largeInvert),
              ),
              locked ? Asset.load<SvgPicture>("group_lock") : const SizedBox()
            ],
          ),
          onPressed: () async => _loadLesson(group, locked),
          onLongPress: () => _loadLesson(group, false),
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

  Future<void> _loadLesson(ParentContent group, bool locked) async {
    if (locked) {
      return;
    }
    try {
      if (group.children.isEmpty) {
        await serviceLocator<AccountProvider>().loadGroup(group);
      }
      await Get.toNamed(_getRoute(group.mode), arguments: {"content": group});
    } on SkeletonException catch (e) {
      alert(e.message, "error_${e.statusCode}".l());
    }
    _categoryIndex = _firstIncompleteGroup();
    setState(() {});
    // if (s == null || s <= scoreNotifier.value) return;
    // await serviceLocator<AccountProvider>().saveScore(id, s);
    // scoreNotifier.value = s;
  }
}
