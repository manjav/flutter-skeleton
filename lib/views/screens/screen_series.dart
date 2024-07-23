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
  final _slideHeight = DeviceInfo.size.height * 0.6;
  PageController? _slidesScrollController;

  @override
  void initState() {
    var list = Get.arguments["content"].children;
    controller.series = List.generate(list.length, (i) => list[i]);
    controller.serieIndex.addListener(_onChangeSerie);
    controller.slideIndex.addListener(_onChangeSlide);
    controller.changeSerie(1);
    super.initState();
  }

  Future<void> _onChangeSerie() async {
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
          )),
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
    return Widgets.button(
      context,
      radius: 24.d,
      height: _slideHeight,
      color: TColors.primary0,
      width: DeviceInfo.size.width,
      margin: EdgeInsets.symmetric(vertical: 5.d),
      padding: EdgeInsets.symmetric(horizontal: 20.d),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.center, children: items),
      onPressed: () => _scrollTo(index),
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

  void _scrollTo(double offset) {
    _slidesScrollController!.animateTo(offset,
        duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
  }

  Widget _contentItem(Talk talk) {
    return switch (talk.type) {
      ContentType.repeat || ContentType.translate => listenerBuilder(talk),
      ContentType.head => DirText(
          talk.nativeValue,
          style: TStyles.big,
          textAlign: TextAlign.center,
        ),
      _ => DirText(
          talk.nativeValue,
          textAlign: TextAlign.center,
        ),
    };
  }

  @override
  Future<void> onListeningResult(QuizState state, Talk talk) async {
    if (state == QuizState.success) {
      if (mounted) {
        controller.onQuizResult(true);
      }
    } else if (state == QuizState.failure) {
      controller.onQuizResult(false);
      // const duration = Duration(milliseconds: 1500);
      // await Future.delayed(duration);
      // serviceLocator<ListenerQuiz>().state.value = QuizState.none;
      // serviceLocator<STT>().start(activeId: controller.uniqueIndex);
    }
  }

  @override
  void dispose() {
    serviceLocator<Sounds>().stopAll();
    controller.serieIndex.removeListener(_onChangeSerie);
    controller.slideIndex.removeListener(_onChangeSlide);
    super.dispose();
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
}
