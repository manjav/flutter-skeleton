import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lingai/services/lesson_controller.dart';

import '../app_export.dart';

mixin LessonMixin<S extends AbstractScreen> on AbstractScreenState<S> {
  final GlobalKey footerKey = GlobalKey();
  final LessonController controller = LessonController();
  double padding = 12.d;

  @override
  List<Widget> appBarElementsLeft() => [];

  @override
  Widget contentFactory(double paddingTop) {
    if (controller.steps.isEmpty) {
      return const SizedBox();
    }

    return Stack(
      children: [
        childBuilder(paddingTop),
        navigatorBuilder(paddingTop, Get.arguments["content"].title),
        footerChromeBuilder(),
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
                valueListenable: controller.stepIndex,
                builder: (context, value, child) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      tween: Tween(
                        begin: value / controller.steps.length,
                        end: (value + 1) / controller.steps.length,
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
                      "${value + 1} / ${controller.steps.length}",
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
        valueListenable: controller.stepIndex,
        builder: (context, value, child) {
          var talk = controller.steps[controller.stepIndex.value] as Talk;
          if (!talk.isQuiz) return const SizedBox();
          return Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            // curve: value == 0 ? Curves.easeIn : Curves.easeOutBack,
            // duration: const Duration(milliseconds: 300),
            child: Container(
              key: footerKey,
              decoration: BoxDecoration(
                color: TColors.primary0,
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
}
