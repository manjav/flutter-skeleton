import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class SeriesScreen extends AbstractScreen {
  SeriesScreen({super.key}) : super(Routes.series);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<SeriesScreen>
    with LessonMixin, ListeningMixin {
  PageController? _slidesScrollController;
  final _slideHeight = DeviceInfo.size.height * 0.8;
  final ValueNotifier<int> _enableUntil = ValueNotifier(0);

  @override
  void initState() {
    trackerParams = {"id": Get.arguments["content"]!.id};
    // List list = Get.arguments["content"].children.last.children;
    // list.removeRange(2, list.length);
    controller.init(Get.arguments["content"]);
    controller.onComplete = _onSerieComplete;
    loadAssets(loadCaptions: false);
    super.initState();
  }

  @override
  Widget headerBuilder(double paddingTop) {
    return Positioned(
      top: paddingTop,
      child: Widgets.touchable(
        context,
        child: Column(
          children: [
            shortcutBuilder(),
            SizedBox(height: 4.d),
            progressSliderBuilder(DeviceInfo.size.width * 0.7),
          ],
        ),
        onTap: openSerieSelector,
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

  @override
  Widget contentBuilder(double paddingTop) {
    _slidesScrollController ??= PageController(
        viewportFraction:
            _slideHeight / (DeviceInfo.size.height - paddingTop - padding));
    final topRadius = Radius.circular(20.d);
    final bottomRadius = Radius.circular(46.d);
    return Positioned(
      top: paddingTop + 48.d,
      left: padding,
      right: padding,
      bottom: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: topRadius,
            topRight: topRadius,
            bottomLeft: bottomRadius,
            bottomRight: bottomRadius),
        child: ValueListenableBuilder(
          valueListenable: controller.serieIndex,
          builder: (context, value, child) {
            _enableUntil.value = 0;
            _scrollTo(0);
            return PageView.builder(
                padEnds: false,
                scrollDirection: Axis.vertical,
                controller: _slidesScrollController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.currentSerie.children.length + 1,
                itemBuilder: _slideItemBuilder);
          },
        ),
      ),
    );
  }

  Widget _slideItemBuilder(BuildContext context, int index) {
    return ValueListenableBuilder<int>(
      valueListenable: _enableUntil,
      builder: (context, value, child) {
        var items = <Widget>[];
        final isSlide = index < controller.currentSerie.children.length;
        if (!isSlide) {
          items = _nextSerieButton();
        } else {
          final slide =
              controller.currentSerie.children[index] as ParentContent;
          for (var c = 0; c < slide.children.length; c++) {
            items.add(_contentItem(slide.children[c] as Talk));
            items.add(SizedBox(height: 12.d));
          }
        }
        final opacity = index <= value ? 1.0 : 0.0;
        return AnimatedOpacity(
          opacity: opacity,
          duration: Duration(milliseconds: opacity > 0 ? 100 : 0),
          child: Widgets.touchable(
            context,
            child: Widgets.rect(
              radius: 24.d,
              color: index <= value ? TColors.primary0 : TColors.primary10,
              margin: EdgeInsets.symmetric(vertical: 35.d),
              padding: EdgeInsets.symmetric(horizontal: 20.d),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, children: items),
            ),
            onTap: () {
              if (index != controller.slideIndex.value) {
                _scrollTo(index);
              }
            },
            onVerticalDragEnd: (DragEndDetails details) {
              final velocity = (details.primaryVelocity ?? 0);
              final absoluteVelocity = velocity.abs();
              if (absoluteVelocity > 500) {
                final page = ((_slidesScrollController!.page ?? 0) +
                        (velocity / absoluteVelocity) * -1)
                    .round();
                _scrollTo(page);
              }
            },
          ),
        );
      },
    );
  }

  List<Widget> _nextSerieButton() {
    final isLastSerie = controller.currentSerie == controller.series.last;
    return [
      Widgets.rect(
        radius: 12.d,
        color: TColors.orange,
        padding: EdgeInsets.symmetric(vertical: 10.d, horizontal: 30.d),
        transform: Transform.rotate(angle: -0.08).transform,
        child: Text(
          "serie_from_to".l([
            (controller.serieIndex.value + 1).convert(),
            controller.series.length.convert()
          ]),
          style: TStyles.largeInvert,
        ),
      ),
      SizedBox(height: isLastSerie ? 12.d : 0),
      isLastSerie
          ? Text("slide_finish".l([]), style: TStyles.huge)
          : const SizedBox(),
      SizedBox(height: 12.d),
      SkinnedButton(
        height: 60.d,
        color: TColors.blue,
        width: DeviceInfo.size.width * 0.7,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("next_serie".l(), style: TStyles.largeInvert),
            SizedBox(width: 16.d),
            Asset.load<SvgPicture>("arrow_right", height: 20.d),
          ],
        ),
        onPressed: () => controller.changeSerie(1),
      ),
    ];
  }

  Future<void> _scrollTo(int page) async {
    if (_slidesScrollController!.positions.isEmpty) {
      _executePage(page);
      return;
    }
    if (page < 0 || page > controller.currentSerie.children.length) return;
    if (page > _enableUntil.value) {
      log("log");
      return;
    }
    await _slidesScrollController!.animateToPage(page,
        duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    if (page >= controller.currentSerie.children.length) return;
    _executePage(page);
  }

  void _executePage(int page) {
    final slide = controller.currentSerie.children[page] as ParentContent;
    if (controller.contentIndex.value <= -1) return;
    final quizes = slide.children.where((c) => (c as Talk).isQuiz);
    if (quizes.isEmpty) {
      _enableUntil.value = page + 1;
    } else {
      listen(quizes.first as Talk);
    }
    controller.changeSlide(page - controller.slideIndex.value);
  }

  Widget _contentItem(Talk talk) {
    return switch (talk.type) {
      ContentType.repeat || ContentType.translate => listenerBuilder(talk),
      ContentType.head => DirText(
          talk.nativeValue.simplify(),
          style: TStyles.big,
          textAlign: TextAlign.center,
        ),
      _ => DirText(
          talk.nativeValue.simplify(),
          textAlign: TextAlign.center,
        ),
    };
  }

  @override
  void onListeningResult(QuizState state, String text, int score, Talk talk) {
    controller.onQuizResult(state, text, score, talk);
    _enableUntil.value = _slidesScrollController!.page!.toInt() + 1;
  }

  void openSerieSelector() {
    final itemHeight = 50.d;
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Widgets.rect(
          color: TColors.primary0,
          radius: 30.d,
          height: itemHeight * (controller.series.length + 1),
          child: ListView.builder(
            padding: EdgeInsets.only(
                top: itemHeight * 0.5, bottom: itemHeight * 0.5),
            itemCount: controller.series.length,
            itemBuilder: (context, index) {
              return Widgets.button(
                context,
                height: itemHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: TColors.primary40,
                      width: 0.5.d,
                    ),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: itemHeight),
                child: DirText(controller.series[index].title),
                onPressed: () {
                  controller.serieIndex.value = index;
                  controller.slideIndex.value = -1;
                  controller.changeSlide(1);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _onSerieComplete(
      int sentenceCount, int quizCount, int score) async {
    await Get.toNamed(Routes.popupResult, arguments: {
      "id": controller.root!.id,
      "score": score,
      "quizCount": quizCount,
      "sentenceCount": sentenceCount
    });
    if (mounted) {
      Navigator.pop(context);
      showFeedback();
    }
  }

  @override
  void dispose() {
    serviceLocator<Sounds>().stopAll();
    super.dispose();
  }
}
