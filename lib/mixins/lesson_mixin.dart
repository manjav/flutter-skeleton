import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lingai/services/lesson_controller.dart';

import '../app_export.dart';

mixin LessonMixin<S extends AbstractScreen> on AbstractScreenState<S> {
  final GlobalKey footerKey = GlobalKey();
  final LessonController controller = LessonController();
  final ValueNotifier<double> footerHeight = ValueNotifier(0);
  final ValueNotifier<String?> subtitle = ValueNotifier(null);
  double padding = 12.d;

  @override
  Widget contentFactory(double paddingTop) {
    if (controller.slides.isEmpty) {
      return const SizedBox();
    }

    return Stack(
      children: [
        childBuilder(paddingTop),
        footerChromeBuilder(),
        navigatorBuilder(paddingTop, Get.arguments["content"].title),
        subtitleBuilder(),
      ],
    );
  }

  Widget navigatorBuilder(double paddingTop, String title) {
    return Positioned(
      top: paddingTop,
      left: 0,
      right: 0,
      child: Widgets.rect(
        padding: EdgeInsets.fromLTRB(padding, paddingTop, paddingTop, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [
                0.7,
                1
              ],
              colors: <Color>[
                TColors.primary10,
                TColors.primary10.withOpacity(0)
              ]),
        ),
        child: Row(
          children: [
            Avatar("person", 64.d),
            SizedBox(width: 12.d),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: controller.slideIndex,
                builder: (context, value, child) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      tween: Tween(
                        begin: value / controller.slides.length,
                        end: (value + 1) / controller.slides.length,
                      ),
                      builder: (context, value, _) => LinearProgressIndicator(
                        minHeight: 6.d,
                        value: value,
                        color: TColors.green,
                        backgroundColor: TColors.primary20,
                        borderRadius: BorderRadius.all(Radius.circular(6.d)),
                      ),
                    ),
                    Text(
                      "${value + 1} / ${controller.slides.length}",
                      style: TStyles.small.copyWith(color: TColors.primary30),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.d),
            Widgets.button(
              context,
              width: 32.d,
              height: 32.d,
              radius: 32.d,
              color: TColors.primary20,
              padding: EdgeInsets.all(8.d),
              child: Asset.load<SvgPicture>("close"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
    );
  }

  Widget footerChromeBuilder() {
    return ValueListenableBuilder(
        valueListenable: footerHeight,
        builder: (context, value, child) {
          if (value <= 0) {
            return const SizedBox();
          }
          return Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            // curve: value == 0 ? Curves.easeIn : Curves.easeOutBack,
            // duration: const Duration(milliseconds: 300),
            child: Container(
              key: footerKey,
              decoration: BoxDecoration(
                color: TColors.primary60,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32.d),
                  topRight: Radius.circular(32.d),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 7,
                    spreadRadius: 5,
                    color: TColors.primary20,
                    offset: Offset(0, -2.d), // changes position of shadow
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(16.d, 12.d, 16.d, 8.d),
              child: footerBuilder(),
            ),
          );
        });
  }

  double getFooterHeight(BuildContext context) {
    double height = 500.d;
    final keyContext = footerKey.currentContext;
    if (context.mounted && keyContext != null) {
      final box = keyContext.findRenderObject() as RenderBox;
      height = box.size.height;
    }
    return height;
  }

  Widget footerBuilder() => const SizedBox();

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
          var text = (value.textPresentationMode.hasNative
                  ? value.targetValue
                  : value.nativeValue)
              .simplify();
          var dir = value.textPresentationMode.hasNative
              ? TextDirection.ltr
              : TextDirection.rtl;
          return Widgets.button(
            context,
            radius: 12.d,
            padding: EdgeInsets.all(12.d),
            color: TColors.black80,
            child: Text(
              text,
              style: TStyles.smallInvert,
              textDirection: dir,
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
    if (talk.voicePresentationMode.hasTarget) {
      await serviceLocator<Speaker>()
          .play(talk.targetValue, narrator: talk.type.narrator, force: force);
    }
    if (lastIndex != -1) {
      if (controller.uniqueIndex != lastIndex) return;
    }
    if (talk.voicePresentationMode.hasNative) {
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
