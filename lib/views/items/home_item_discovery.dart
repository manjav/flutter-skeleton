import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_export.dart';

class DiscoveryPageItem extends AbstractHomePageItem {
  final List<ParentContent> readsCategories;
  final List<ParentContent> newCategories;

  const DiscoveryPageItem(
    this.readsCategories,
    this.newCategories, {
    super.key,
  });

  @override
  State<DiscoveryPageItem> createState() => _DiscoveryPageItemState();
}

class _DiscoveryPageItemState
    extends AbstractHomePageItemState<DiscoveryPageItem> {
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
    return CustomScrollView(
      slivers: [
        sliverAppBar(),
        SliverToBoxAdapter(
          child:
              categoryTitle("video_recent", widget.readsCategories.isNotEmpty),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: widget.readsCategories.isEmpty ? 0 : 170.d,
            child: ListView.builder(
              itemCount: widget.readsCategories.length,
              itemBuilder: (context, index) {
                return _courseItemBuilder(
                  padding: 5.d,
                  height: 170.d,
                  margin: EdgeInsets.all(5.d),
                  category: widget.readsCategories[index],
                  flag: "${widget.readsCategories[index].passLevel}%",
                  titleStyle: TStyles.tinyInvert,
                );
              },
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: categoryTitle("video_new", true),
        ),
        SliverList.builder(
          itemCount: widget.newCategories.length + 1,
          itemBuilder: (_, i) => _categoryItemBuilder(
            i < widget.newCategories.length ? widget.newCategories[i] : null,
            i,
            widget.newCategories.length,
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
      onPressed: () {
        if (category.children.length > 1) {
        } else {
          // _loadLesson(category.children.first as ParentContent, false);
        }
      },
    );
  }
}
