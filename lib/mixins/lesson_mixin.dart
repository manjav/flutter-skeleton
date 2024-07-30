import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../app_export.dart';

mixin LessonMixin<S extends AbstractScreen> on AbstractScreenState<S> {
  final GlobalKey footerKey = GlobalKey();
  final LessonController controller = LessonController();
  final ValueNotifier<Talk?> subtitle = ValueNotifier(null);
  double padding = 8.d;

  @override
  Widget appBarFactory(double paddingTop) => navigatorBuilder(paddingTop);

  @override
  Widget contentFactory(double paddingTop) {
    if (controller.series.isEmpty) {
      return const SizedBox();
    }

    return Widgets.rect(
      color: TColors.primary10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          childBuilder(paddingTop),
        ],
      ),
    );
  }

  Widget navigatorBuilder(double paddingTop) {
    return Positioned(
      top: paddingTop,
      left: 8.d,
      right: 12.d,
      child: Row(
        children: [
          Widgets.button(
            context,
            width: 32.d,
            height: 32.d,
            padding: EdgeInsets.all(8.d),
            child: Asset.load<SvgPicture>("close",
                svgColorFilter:
                    const ColorFilter.mode(TColors.primary50, BlendMode.srcIn)),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(child: leftSideAppBar()),
        ],
      ),
    );
  }

  Widget shortcutBuilder() {
    return controller.series.length > 1
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DirText(controller.currentSerie.title),
              SizedBox(width: 8.d),
              Asset.load<SvgPicture>("chevron"),
            ],
          )
        : const SizedBox();
  }

  Widget leftSideAppBar() => const SizedBox();

  Widget progressSliderBuilder() {
    final seriesCount = controller.series.length;
    final serieIndex = controller.serieIndex.value;
    final height = 5.d;
    final margin = EdgeInsets.symmetric(horizontal: height);
    final width = (DeviceInfo.size.width - height * 10) / seriesCount - height;
    return SizedBox(
      height: height,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: width / height, crossAxisCount: seriesCount),
        itemCount: seriesCount,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          if (index != serieIndex) {
            return Widgets.rect(
              radius: 4.d,
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

  Future<void> playSound(
    Talk talk, {
    int lastIndex = -1,
    bool force = false,
  }) async {
    if (talk.type.textSide != TranslationSide.none && !talk.isQuiz) {
      // await serviceLocator<Speaker>()
      //     .play(soundId, narrator: talk.type.narrator, force: force);
      await serviceLocator<Speaker>()
          .playLocal(talk.getText(talk.type.textSide));
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
