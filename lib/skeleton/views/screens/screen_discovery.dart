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
    var account = serviceLocator<AccountProvider>();
    return PopScope(
      canPop: false,
      child: Widgets.rect(
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
            ListView.builder(
              padding: EdgeInsets.fromLTRB(10.d, 100.d, 10.d, 30.d),
              itemCount: _categories.length + 1,
              itemBuilder: _categoryItemBuilder,
            ),
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

  Widget _categoryItemBuilder(BuildContext context, int index) {
    final margin = EdgeInsets.all(5.d);
    if (index >= _categories.length) {
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
    final category = _categories[index];
    return Widgets.button(
      context,
      radius: 24.d,
      margin: margin,
      padding: EdgeInsets.all(16.d),
      color: TColors.primary10,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  category.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Widgets.rect(
                radius: 12.d,
                color: TColors.teal,
                padding: EdgeInsets.symmetric(horizontal: 4.d),
                child: Text(category.subtitle, style: TStyles.mediumInvert),
              ),
            ],
          ),
          SizedBox(height: 10.d),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(14.d)),
            child: Image.network(category.iconUrl),
          )
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

  Future<void> _loadLesson(ParentContent group, bool locked) async {
    if (locked) {
      return;
    }

    await Get.toNamed(_getRoute(group.mode), arguments: {"content": group});
    // _categoryIndex = _firstIncompleteGroup();
    setState(() {});
    // if (s == null || s <= scoreNotifier.value) return;
    // await serviceLocator<AccountProvider>().saveScore(id, s);
    // scoreNotifier.value = s;
  }
}
