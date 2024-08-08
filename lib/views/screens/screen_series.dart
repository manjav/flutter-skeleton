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
  final _slideHeight = DeviceInfo.size.height * 0.8;
  PageController? _slidesScrollController;

  @override
  void initState() {
    controller.init(Get.arguments["content"]);
    controller.onComplete = _onSerieComplete;
    controller.slideIndex.addListener(_onChangeSlide);
    serviceLocator<Speaker>().loadAllSounds(
      series: controller.series,
      onComplete: () {
      controller.changeSerie(1);
      setState(() {});
      },
      onError: () async {
        await Get.toNamed(Routes.popupMessage,
            arguments: {"title": "Error in loading assets!"});
        if (mounted) {
          Navigator.pop(context);
        }
      },
      loadCaptions: false,
    );
    super.initState();
  }

  @override
  Widget contentFactory(double paddingTop) {
    if (controller.serieIndex.value < 0) {
      return const Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            color: TColors.cyan,
          ),
        ],
      );
    }
    return super.contentFactory(paddingTop);
  }

  Future<void> _onChangeSlide() async {
    if (controller.slideIndex.value <= -1) return;
    await Future.delayed(const Duration(milliseconds: 500));
    for (var content in controller.currentSlide.children) {
      if (content.isQuiz) {
        listen(content as Talk);
      }
    }
  }

  @override
  Widget leftSideAppBar() {
    return ValueListenableBuilder(
      valueListenable: controller.contentIndex,
      builder: (context, value, child) {
        return Widgets.touchable(
          context,
          child: Column(
            children: [
              shortcutBuilder(),
              SizedBox(height: 4.d),
              progressSliderBuilder()
            ],
          ),
          onTap: openSerieSelector,
        );
      },
    );
  }

  @override
  Widget childBuilder(double paddingTop) {
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
          valueListenable: controller.slideIndex,
          builder: (context, value, child) {
            _scrollTo(0);
            return PageView.builder(
                padEnds: false,
                scrollDirection: Axis.vertical,
                controller: _slidesScrollController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.currentSerie.children.length + 1,
                itemBuilder: _slideItemBiulder);
          },
        ),
      ),
    );
  }

  Widget _slideItemBiulder(BuildContext context, int index) {
    if (index >= controller.currentSerie.children.length) {
      return _nextSerieButton();
    }
    final slide = controller.currentSerie.children[index] as ParentContent;
    var items = <Widget>[];
    for (var c = 0; c < slide.children.length; c++) {
      items.add(_contentItem(slide.children[c] as Talk));
      items.add(SizedBox(height: 12.d));
    }
    return Widgets.touchable(
      context,
      child: Widgets.rect(
        radius: 24.d,
        height: _slideHeight,
        color: TColors.primary0,
        width: DeviceInfo.size.width,
        margin: EdgeInsets.symmetric(vertical: 35.d),
        padding: EdgeInsets.symmetric(horizontal: 20.d),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center, children: items),
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
  }

  Widget _nextSerieButton() {
    if (controller.currentSerie == controller.series.last) {
      return Column(
        children: [
          SizedBox(height: 30.d),
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
          SizedBox(height: 12.d),
          Text("slide_finish".l([]), style: TStyles.huge),
          SizedBox(height: 12.d),
          SkinnedButton(
            color: TColors.blue,
            height: 60.d,
            width: DeviceInfo.size.width * 0.7,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("next_serie".l(), style: TStyles.largeInvert),
                SizedBox(width: 16.d),
                Asset.load<SvgPicture>("arrow_right", height: 20.d),
              ],
            ),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(height: 30.d),
        ],
      );
    }
    return Widgets.button(
      context,
      height: 100.d,
      alignment: const Alignment(0, -0.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Asset.load<SvgPicture>("wand"),
          SizedBox(width: 12.d),
          Text("next_slide".l(),
              style: TStyles.medium.copyWith(color: TColors.primary40)),
        ],
      ),
      onPressed: () => controller.changeSerie(1),
    );
  }

  Future<void> _scrollTo(int page) async {
    if (_slidesScrollController!.positions.isEmpty) return;
    if (page < 0 || page > controller.currentSerie.children.length) return;
    await _slidesScrollController!.animateToPage(page,
        duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    final slide = controller.currentSerie.children[page] as ParentContent;
    if (controller.contentIndex.value <= -1) return;
    final quizes = slide.children.where((c) => (c as Talk).isQuiz).toList();
    if (quizes.isNotEmpty) {
      listen(quizes.first as Talk, autoStart: false);
    }
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
    controller.onQuizResult(score, text, talk);
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
    }
  }

  @override
  void dispose() {
    serviceLocator<Sounds>().stopAll();
    controller.slideIndex.removeListener(_onChangeSlide);
    super.dispose();
  }
}
