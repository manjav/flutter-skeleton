import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';

import '../app_export.dart';

mixin LessonMixin<S extends AbstractScreen> on AbstractScreenState<S> {
  final ValueNotifier<Talk?> caption = ValueNotifier(null);
  final LessonController controller = LessonController();
  final GlobalKey footerKey = GlobalKey();
  SMIInput<double>? progressInput;
  double padding = 8.d;

  void initializeController({bool loadCaptions = true}) async {
    trackerParams = {"id": Get.arguments["content"]!.id};

    controller.onComplete = _onSerieComplete;
    controller.onAssetLoadingProgress = (value) => progressInput?.value = value;
    controller.onError = (message) async {
      await Get.toNamed(Routes.popupMessage, arguments: {"title": message});
      if (mounted) {
        Navigator.pop(context);
      }
    };
    controller.init(Get.arguments["content"], loadCaptions: loadCaptions);
  }

  @override
  Widget contentFactory(double paddingTop) {
    return ValueListenableBuilder(
      valueListenable: controller.serieIndex,
      builder: (context, value, child) {
        if (value < 0) {
          return _assetsProgressbarBuilder();
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            contentBuilder(paddingTop),
            headerBuilder(paddingTop),
            footerBuilder(),
          ],
        );
      },
    );
  }

  Widget headerBuilder(double paddingTop) => const SizedBox();
  Widget contentBuilder(double paddingTop) => const SizedBox();
  Widget footerBuilder() => const SizedBox();

  Widget _assetsProgressbarBuilder() {
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
    final height = 9.d;
    final seriesCount = controller.series.length;
    var slidesCount = 0;
    for (ParentContent serie in controller.series) {
      slidesCount += serie.children.length;
    }

    final margin = EdgeInsets.symmetric(horizontal: height * 0.5);
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
              final itemWidth = (width - height * seriesCount) *
                  controller.series[index].children.length /
                  slidesCount;
              if (index != serieIndex) {
                return Widgets.rect(
                  radius: 4.d,
                  margin: margin,
                  width: itemWidth,
                  color:
                      index <= serieIndex ? TColors.green : TColors.primary20,
                );
              }
              return Padding(
                padding: margin,
                child: Widgets.slider(
                  0,
                  value + 1,
                  controller.currentSerie.children.length.toDouble(),
                  padding: 0,
                  height: height,
                  width: itemWidth,
                  progressColor: TColors.green,
                  backgroundColor: TColors.primary20,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _onSerieComplete(
    int sentenceCount,
    int quizCount,
    int score,
    bool showFeast,
  ) async {
    try {
      serviceLocator<AccountProvider>().saveScore(
        controller.root!.id,
        {
          "score": score,
          "quizCount": quizCount,
          "sentenceCount": sentenceCount,
        },
      );

      if (showFeast) {
        await Get.toNamed(Routes.popupResult, arguments: {
          "score": score,
          "id": controller.root!.id,
          "sentenceCount": sentenceCount,
          "videoId": controller.root!.iconUrl,
        });
      }
    } on SkeletonException catch (e) {
      if (context.mounted) {
        Get.toNamed(Routes.popupMessage, arguments: {
          "title": e.message,
          "message": "error_${e.statusCode}".l()
        });
      }
    }
    if (mounted) {
      Navigator.pop(context);
      // showFeedback();
    }
  }

  Future<void> showFeedback() async {
    final id = "survey_${controller.root!.id}";
    if (Prefs.contains(id)) return;
    if (!NetConnector.configs["surveys"].containsKey(id)) return;
    await Get.toNamed(Routes.web,
        arguments: {"url": NetConnector.configs["surveys"][id]});
    Prefs.setBool(id, true);
  }

  Future<void> playSound(
    Talk talk, {
    int lastIndex = -1,
    bool force = false,
  }) async {
    if (talk.textSide != TranslationSide.none && !talk.isStation) {
      final text = talk.getText(talk.textSide);
      await serviceLocator<MediaService>().playVoice(text);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
