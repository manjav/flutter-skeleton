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
            await _loadLesson(
                onboard.first.children.first as ParentContent, false);
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
      alert(e.message, "error_${e.statusCode}".l());
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
      child: Material(
        color: TColors.primary0,
        child: Padding(
          padding: EdgeInsets.all(10.d),
          child: DiscoveryPageItem(_readsCategories, _newCategories),
        ),
      ),
    );
  }

  Future<void> _loadLesson(ParentContent group, bool locked) async {
    if (locked) {
      return;
    }

    await Get.toNamed(_getRoute(group.mode), arguments: {"content": group});
    _initializeLessons();
  }
}
