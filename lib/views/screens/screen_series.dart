import 'dart:async';

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

  @override
  void initState() {
    controller.onComplete = _onSerieComplete;
    initializeController(loadCaptions: false);
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
            if (_slidesScrollController!.positions.isNotEmpty) {
              _slidesScrollController?.jumpToPage(0);
            }
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
      valueListenable: controller.slideIndex,
      builder: (context, value, child) {
        return Widgets.touchable(
          context,
          sfx: "",
          child: Widgets.rect(
            radius: 24.d,
            padding: EdgeInsets.all(20.d),
            margin: EdgeInsets.symmetric(vertical: 35.d),
            color: controller.slidePassed.value ||
                    index <= controller.slideIndex.value
                ? TColors.primary0
                : TColors.primary10,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                _nextLabelBuilder(index),
                _cardContentBuilder(index),
              ],
            ),
          ),
          onTap: () => _scrollTo(index),
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
        );
      },
    );
  }

  Widget _nextLabelBuilder(int index) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.slidePassed,
      builder: (context, value, child) {
        final isNextSlideButton = index <= controller.slideIndex.value;
        if (!controller.slidePassed.value || isNextSlideButton) {
          return SizedBox();
        }
        return DirText("next_slide".l(), style: TStyles.large);
      },
    );
  }

  Widget _cardContentBuilder(int index) {
    var items = <Widget>[];
    final isSlide = index < controller.currentSerie.children.length;
    if (!isSlide) {
      items = _nextSerieButton();
    } else {
      final slide = controller.currentSerie.children[index] as ParentContent;
      for (var c = 0; c < slide.children.length; c++) {
        items.add(_contentItem(slide.children[c] as Talk));
        items.add(SizedBox(height: 12.d));
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items,
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
    if (!controller.slidePassed.value || page == controller.slideIndex.value) {
      return;
    }
    await _slidesScrollController!.animateToPage(page,
        duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    if (page < controller.currentSerie.children.length) {
      _executePage(page);
    } else {
      controller.slidePassed.value = false;
    }
  }

  void _executePage(int page) {
    final slide = controller.currentSerie.children[page] as ParentContent;
    if (controller.contentIndex.value <= -1) return;
    final quizes = slide.children.where((c) => (c as Talk).isQuiz);
    if (quizes.isNotEmpty) {
      listen(quizes.first as Talk);
    }
    controller.changeSlide(page - controller.slideIndex.value);
  }

  Widget _contentItem(Talk talk) {
    return switch (talk.type) {
      ContentType.repeat || ContentType.translate => microphoneBuilder(talk),
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
  void onListeningResult(
      QuizState state, String text, int score, Talk talk, bool repeated) {
    try {
      controller.onQuizResult(state, text, score, talk);
    } on SkeletonException catch (e) {
      alert(e.message, "error_${e.statusCode}".l());
    }
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
                      width: 0.1.d,
                    ),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: itemHeight),
                child: DirText(controller.series[index].title),
                onPressed: () {
                  controller.changeSerie(index - controller.serieIndex.value);
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
