import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class DiscoveryPageItem extends AbstractHomePageItem {
  const DiscoveryPageItem({super.key});

  @override
  State<DiscoveryPageItem> createState() => _DiscoveryPageItemState();
}

class _DiscoveryPageItemState
    extends AbstractHomePageItemState<DiscoveryPageItem> {
  List<ParentContent> _categories = [];
  final List<ParentContent> _newCategories = [];
  final List<ParentContent> _recentCategories = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    if (services.state.status.index >= ServiceStatus.initialize.index) {
      _initializeLessons(initializeMode: true);
    } else {
      services.addListener(
        () {
          if (services.state.status == ServiceStatus.initialize) {
            _initializeLessons(initializeMode: true);
          }
        },
      );
    }
    super.initState();
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
      _recentCategories.clear();
      _newCategories.clear();
      final scoreKeys = account.scores.keys.toList();
      for (var category in _categories) {
        if (hasReadCategory(account.scores, scoreKeys, category)) {
          _recentCategories.add(category);
        } else {
          _newCategories.add(category);
        }
      }
      setState(() {});
    } on SkeletonException catch (e) {
      alert(e.message, message: "error_${e.statusCode}".l());
    }
  }

  bool hasReadCategory(
    Map<String, Map<String, dynamic>> scores,
    List<String> scoreKeys,
    ParentContent category,
  ) {
    var score = 0;
    var lessonCount = 0;
    for (var group in category.children) {
      if (scores.containsKey(group.id)) {
        score += (scores[group.id]!["score"] ?? 0) as int;
        lessonCount++;
      }
    }
    if (lessonCount > 0) {
      category.score = (score / lessonCount).round();
    }
    return lessonCount > 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_categories.isEmpty) return SizedBox();
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        sliverAppBar(),
        header("header_video_recent", _recentCategories.isNotEmpty),
        SliverToBoxAdapter(
          child: SizedBox(
            height: _recentCategories.isEmpty ? 0 : 170.d,
            child: ListView.builder(
              itemCount: _recentCategories.length,
              itemBuilder: (context, index) {
                return _courseItemBuilder(
                  padding: 5.d,
                  height: 170.d,
                  margin: EdgeInsets.all(5.d),
                  titleStyle: TStyles.tinyInvert,
                  category: _recentCategories[index],
                  flag: "${_recentCategories[index].score}%",
                );
              },
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
        header("header_video_new", true),
        SliverList.builder(
          itemCount: _newCategories.length + 1,
          itemBuilder: (_, i) => _categoryItemBuilder(
            i < _newCategories.length ? _newCategories[i] : null,
            i,
            _newCategories.length,
          ),
        )
      ],
    );
  }

  Widget _categoryItemBuilder(
    ParentContent? category,
    int index,
    int itemCount,
  ) {
    final margin = EdgeInsets.all(5.d);
    if (index >= itemCount) {
      return Widgets.button(
        context,
        height: 70.d,
        margin: margin,
        color: TColors.primary20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("next_section".l(), style: TStyles.largeInvert),
            SizedBox(width: 10.d),
            Asset.load<SvgPicture>("group_lock")
          ],
        ),
      );
    }

    return _courseItemBuilder(
      category: category!,
      height: 240.d,
      margin: margin,
      flag: category.subtitle,
    );
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
              child: CachedNetworkImage(
                progressIndicatorBuilder: (context, url, progress) => Center(
                  child: CircularProgressIndicator(
                    value: progress.progress,
                  ),
                ),
                imageUrl: category.iconUrl,
                fit: BoxFit.cover,
              ),
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
                    color: TColors.black,
                    padding: EdgeInsets.fromLTRB(8.d, 4.d, 8.d, 4.d),
                    child: Text(flag, style: TStyles.tinyInvert),
                  ),
                ),
        ],
      ),
      onPressed: () async {
        if (category.children.length > 1) {
        } else {
          await _loadLesson(category.children.first as ParentContent);
        }
      },
    );
  }

  Future<void> _loadLesson(ParentContent group) async {
    var recentsCount = _recentCategories.length;
    await Get.toNamed(_getRoute(group.mode), arguments: {"content": group});
    await _initializeLessons();
  }

  String _getRoute(String mode) {
    return switch (mode.substring(0, 4)) {
      "less" => Routes.lesson,
      "imit" => Routes.imitation,
      _ => Routes.series,
    };
  }
}
