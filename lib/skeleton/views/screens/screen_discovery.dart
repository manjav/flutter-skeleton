import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../app_export.dart';

class DiscoveryScreen extends AbstractScreen {
  DiscoveryScreen({super.key}) : super(Routes.home);

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen> {
  // int _categoryIndex = 0;
  // final double _titleHeight = 40.d;
  // final double _categoryHeight = 74.d;
  // final double _groupHeight = 70.d;
  // final double _headerHight = 186.d;
  // final double _roadWidth = 64.d;
  // final TextStyle _unitStyle = TStyles.small.copyWith(
  //     color: TColors.primary40, fontWeight: FontWeight.w100, height: 0.9);
  // final TextStyle _unitStylePassed = TStyles.small
  //     .copyWith(color: TColors.green, fontWeight: FontWeight.w100, height: 0.9);
  // final TextStyle _numberStyle = TStyles.big.copyWith(
  //     color: TColors.primary40, fontWeight: FontWeight.w600, height: 0.9);
  // final TextStyle _numberStylePassed = TStyles.big
  //     .copyWith(color: TColors.green, fontWeight: FontWeight.w600, height: 0.9);

  // Color _getColors(String mode) {
  //   return switch (mode.substring(0, 4)) {
  //     "less" => TColors.blue,
  //     "prac" => TColors.orange,
  //     "gram" => TColors.cyan,
  //     "voca" => TColors.purpule,
  //     "chat" => TColors.primary60,
  //     "imit" => TColors.teal,
  //     _ => TColors.gray,
  //   };
  // }

  String _getRoute(String mode) {
    return switch (mode.substring(0, 4)) {
      "less" => Routes.lesson,
      "imit" => Routes.imitation,
      _ => Routes.series,
    };
  }

  Map<String, Map<String, dynamic>> _scores = {};
  final List<ParentContent> _readsCategories = [];
  final List<ParentContent> _newCategories = [];
  LoadingController controller = Get.put(LoadingController());
  @override
  void onRender(Duration timeStamp) {
    super.onRender(timeStamp);
    services.addListener(
      () {
        if (services.state.status == ServiceStatus.initialize) {
          _initializeLessons();
        }
      },
    );
  }

  Future<void> _initializeLessons() async {
    try {
      var account = serviceLocator<AccountProvider>();
      if (!account.metadata.containsKey("targetLanguage")) {
        await Get.toNamed(Routes.onboarding);
      }
      final categories = (await account.loadCategories());
      _scores = await account.loadScores();

      // Distinguishing read and new contents
      _readsCategories.clear();
      _newCategories.clear();
      for (var category in categories) {
        if (hasReadCategory(category)) {
          _readsCategories.add(category);
        } else {
          _newCategories.add(category);
        }
      }

      // _categoryIndex = _firstIncompleteGroup();
      setState(() {});
    } on SkeletonException catch (e) {
      alert(e.message, "error_${e.statusCode}".l());
    }
  }

  @override
  List<Widget> appBarElementsLeft() => [];

  // Find first incomplete group
  // int _firstIncompleteGroup() {
  //   for (var category in _categories) {
  //     if (!isCategoryComplete(category, true)) {
  //       return category.index;
  //     }
  //   }
  //   return 0;
  // }

  bool hasReadCategory(ParentContent category) {
    var score = 0;
    var lessonCount = 0;
    for (var group in category.children) {
      if (_scores.containsKey(group.id)) {
        score += _scores[group.id]!["score"] as int;
        lessonCount++;
      }
    }
    if (lessonCount > 0) {
      category.passLevel = (score / lessonCount).round();
    }
    return lessonCount > 0;
  }

  @override
  Widget contentFactory(double paddingTop) {
    if (services.state.status.index < ServiceStatus.initialize.index) {
      return const SizedBox();
    }
    var account = serviceLocator<AccountProvider>();
    return PopScope(
      canPop: false,
      child: Widgets.rect(
        padding: EdgeInsets.fromLTRB(10.d, 10.d, 10.d, 30.d),
        color: TColors.primary0,
        child: Stack(
          alignment: Alignment(0, -0.85),
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Asset.load<SvgPicture>("logo"),
                SizedBox(width: 10.d),
                Text("Life Talk"),
              ],
            ),
            _discoveryBuilder(),
            Widgets.button(
              context,
              child: account.isTester
                  ? Text("Test Mode")
                  : SizedBox(width: 100.d, height: 32.d),
              padding: EdgeInsets.all(8.d),
              color: account.isTester ? TColors.orange : TColors.transparent,
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
          ],
        ),
      ),
    );
  }

  Widget _discoveryBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 100.d),
        _readsCategories.isEmpty ? SizedBox() : Text("  Recent videos"),
        SizedBox(
          height: _readsCategories.isEmpty ? 0 : 170.d,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _readsCategories.length,
            itemBuilder: (context, index) {
              return _courseItemBuilder(
                padding: 5.d,
                height: 170.d,
                margin: EdgeInsets.all(5.d),
                category: _readsCategories[index],
                flag: "${_readsCategories[index].passLevel}%",
                titleStyle: TStyles.tinyInvert,
              );
            },
            scrollDirection: Axis.horizontal,
          ),
        ),
        SizedBox(height: 10.d),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _newCategories.length + 1,
            itemBuilder: (_, i) => _categoryItemBuilder(
                i < _newCategories.length ? _newCategories[i] : null, i),
          ),
        )
      ],
    );
  }

  Widget _categoryItemBuilder(ParentContent? category, int index) {
    final margin = EdgeInsets.all(5.d);
    if (index >= _newCategories.length) {
      return Widgets.button(
        context,
        height: 70.d,
        margin: margin,
        color: TColors.primary20,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("next_section".l(), style: TStyles.largeInvert),
          SizedBox(width: 10.d),
          Asset.load<SvgPicture>("group_lock")
        ]),
      );
    }

    return _courseItemBuilder(
      category: category!,
      height: 240.d,
      margin: margin,
      flag: category.subtitle,
    );
  }

  Future<void> _loadLesson(ParentContent group, bool locked) async {
    if (locked) {
      return;
    }

    await Get.toNamed(_getRoute(group.mode), arguments: {"content": group});
    // _categoryIndex = _firstIncompleteGroup();
    _initializeLessons();
    // if (s == null || s <= scoreNotifier.value) return;
    // await serviceLocator<AccountProvider>().saveScore(id, s);
    // scoreNotifier.value = s;
  }

  Widget _courseItemBuilder({
    required double height,
    required EdgeInsets margin,
    required ParentContent category,
    String? flag,
    double? padding,
    double? radius,
    TextStyle? titleStyle,
  }) {
    padding ??= 8.d;
    radius ??= 24.d;
    final innerRadius = Radius.circular(radius * 0.85);
    return Widgets.button(
      context,
      radius: radius,
      margin: margin,
      height: height,
      width: height * 1.5,
      padding: EdgeInsets.all(padding),
      color: TColors.primary10,
      child: Stack(
        children: [
          SizedBox(
            height: height - padding * 2,
            child: ClipRRect(
              borderRadius: BorderRadius.all(innerRadius),
              child: Image.network(category.iconUrl, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Widgets.rect(
              padding: EdgeInsets.fromLTRB(
                  padding * 2, padding * 4, padding * 2, padding * 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: FractionalOffset.bottomCenter,
                    end: FractionalOffset.topCenter,
                    colors: [TColors.black60, TColors.transparent],
                    stops: [0.6, 1]),
                borderRadius: BorderRadius.only(
                  bottomRight: innerRadius,
                  bottomLeft: innerRadius,
                ),
              ),
              child: Text(
                category.title,
                maxLines: 2,
                style: titleStyle ?? TStyles.smallInvert,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          flag == null
              ? SizedBox()
              : Positioned(
                  top: padding,
                  right: padding,
                  child: Widgets.rect(
                    radius: 12.d,
                    color: TColors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 4.d),
                    child: Text(flag, style: TStyles.tinyInvert),
                  ),
                ),
        ],
      ),
      onPressed: () {
        if (category.children.length > 1) {
        } else {
          _loadLesson(category.children.first as ParentContent, false);
        }
      },
    );
  }
}
