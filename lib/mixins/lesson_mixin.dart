import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../app_export.dart';

mixin LessonMixin<S extends AbstractScreen> on AbstractScreenState<S> {
  final GlobalKey footerKey = GlobalKey();
  final LessonController controller = LessonController();
  final ValueNotifier<Talk?> subtitle = ValueNotifier(null);
  double padding = 8.d;

  @override
  Widget appBarFactory(double paddingTop) =>
      navigatorBuilder(paddingTop, Get.arguments["content"].title);

  @override
  Widget contentFactory(double paddingTop) {
    if (controller.series.isEmpty) {
      return const SizedBox();
    }

    return Widgets.rect(
      color: TColors.primary10,
      child: Stack(
        children: [
          childBuilder(paddingTop),
          subtitleBuilder(),
        ],
      ),
    );
  }

  Widget navigatorBuilder(double paddingTop, String title) {
    return Positioned(
      top: paddingTop,
      left: 12.d,
      right: 12.d,
      child: Row(
        children: [
          Widgets.button(
            context,
            width: 36.d,
            height: 36.d,
            padding: EdgeInsets.all(8.d),
            child: Asset.load<SvgPicture>("close",
                svgColorFilter:
                    const ColorFilter.mode(TColors.primary50, BlendMode.srcIn)),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: controller.contentIndex,
              builder: (context, value, child) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title),
                        SizedBox(width: 8.d),
                        Asset.load<SvgPicture>("chevron"),
                      ],
                    ),
                    SizedBox(height: 4.d),
                    indicatorBuilder()
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget indicatorBuilder() {
    final seriesCount = controller.series.length;
    final serieIndex = controller.serieIndex.value;
    final height = 5.d;
    final margin = EdgeInsets.symmetric(horizontal: height);
    final width =
        (DeviceInfo.size.width - height * 10) / seriesCount - height * 4;
    return SizedBox(
      height: height,
      child: ListView.builder(
        itemCount: seriesCount,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: height * 5),
        itemBuilder: (context, index) {
          if (index != serieIndex) {
            return Widgets.rect(
              radius: 4.d,
              width: width,
              height: height,
              margin: margin,
              color: index <= serieIndex ? TColors.green : TColors.white50,
            );
          }
          return Padding(
            padding: margin,
            child: Widgets.slider(0, controller.slideIndex.value.toDouble() + 1,
                controller.currentSerie.children.length.toDouble(),
                padding: 0,
                width: width,
                height: height,
                backgroundColor: TColors.white50,
                progressColor: TColors.green),
          );
        },
      ),
    );
  }

  Widget childBuilder(double paddingTop) => const SizedBox();

  Widget subtitleBuilder() {
    return Positioned(
      left: 32.d,
      right: 32.d,
      bottom: 12.d,
      child: ValueListenableBuilder(
        valueListenable: subtitle,
        builder: (context, value, child) {
          if (value == null) return const SizedBox();
          return Widgets.button(
            context,
            radius: 12.d,
            padding: EdgeInsets.all(12.d),
            color: TColors.black80,
            child: Text(
              value.nativeValue, // text,
              style: TStyles.smallInvert,
              textDirection: TextDirection.rtl, // dir,
            ),
            onLongPress: () => playSound(value, force: true),
          );
        },
      ),
    );
  }

  Future<void> playSound(
    Talk talk, {
    int lastIndex = -1,
    bool force = false,
  }) async {
    if (talk.type == ContentType.image) return;
    final hasTarget = talk.type == ContentType.bot ||
        talk.type == ContentType.user ||
        talk.type == ContentType.repeat;
    if (hasTarget) {
      await serviceLocator<Speaker>()
          .play(talk.targetValue, narrator: talk.type.narrator, force: force);
    } else {
      await serviceLocator<Speaker>()
          .play(talk.nativeValue, narrator: talk.type.narrator, force: force);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
