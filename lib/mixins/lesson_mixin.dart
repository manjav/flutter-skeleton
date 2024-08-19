import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rive/rive.dart';

import '../app_export.dart';

mixin LessonMixin<S extends AbstractScreen> on AbstractScreenState<S> {
  final GlobalKey footerKey = GlobalKey();
  final LessonController controller = LessonController();
  final ValueNotifier<Talk?> caption = ValueNotifier(null);
  SMIInput<double>? progressInput;
  double padding = 8.d;

  @override
  Widget appBarFactory(double paddingTop) => navigatorBuilder(paddingTop);

  @override
  Widget contentFactory(double paddingTop) {
    if (controller.series.isEmpty) {
      return const SizedBox();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        childBuilder(paddingTop),
      ],
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
    return controller.series.length > 1 && controller.serieIndex.value > -1
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ValueListenableBuilder(
                valueListenable: controller.slideIndex,
                builder: (context, value, child) =>
                    DirText(controller.currentSerie.title),
              ),
              SizedBox(width: 8.d),
              Asset.load<SvgPicture>("chevron"),
            ],
          )
        : const SizedBox();
  }

  Widget leftSideAppBar() => const SizedBox();

  Widget loadingProgressbarBuilder() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 280.d,
              height: 100.d,
              child: Asset.load<RiveAnimation>(
                "progressbar_group",
                onRiveInit: (artboard) {
                  final controller = StateMachineController.fromArtboard(
                      artboard, "State Machine 1");
                  progressInput = controller?.findInput<double>("unit");
                  artboard.addController(controller!);
                },
              ),
            ),
            DirText("waiting_l".l()),
          ],
        ),
      ],
    );
  }

  Widget progressSliderBuilder(double width) {
    final seriesCount = controller.series.length;
    final height = 8.d;
    final margin = EdgeInsets.symmetric(horizontal: height * 0.5);
    final itemWidth = (width - height * seriesCount) / seriesCount;
    return SizedBox(
      width: width,
      height: height,
      child: ValueListenableBuilder(
        valueListenable: controller.slideIndex,
        builder: (context, value, child) {
          final serieIndex = controller.serieIndex.value;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: seriesCount,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              if (index != serieIndex) {
                return Widgets.rect(
                  width: itemWidth,
                  radius: 4.d,
                  margin: margin,
                  color: index <= serieIndex ? TColors.green : TColors.white50,
                );
              }
              return Padding(
                padding: margin,
                child: Widgets.slider(0, value + 1,
                    controller.currentSerie.children.length.toDouble(),
                    padding: 0,
                    width: itemWidth,
                    height: height,
                    backgroundColor: TColors.white50,
                    progressColor: TColors.green),
              );
            },
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
