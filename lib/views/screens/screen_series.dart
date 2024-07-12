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
  final List<ParentContent> _animatedItems = [];
  final _animatedListKey = GlobalKey<AnimatedListState>();
  final _slideHeight = DeviceInfo.size.height * 0.5;
  PageController? _slidesScrollController;

  @override
  void initState() {
    var list = Get.arguments["content"].children;
    controller.series = List.generate(list.length, (i) => list[i]);
    // controller.series.removeRange(0, 2);
    controller.serieIndex.addListener(_onChangeSerie);
    controller.slideIndex.addListener(_onChangeSlide);
    controller.changeSerie(1);
    super.initState();
  }

  Future<void> _onChangeSerie() async {
    _animatedItems.clear();
    _animatedListKey.currentState
        ?.removeAllItems((context, animation) => const SizedBox());
  }

  Future<void> _onChangeSlide() async {
    if (controller.slideIndex.value <= -1) return;
    if (_animatedItems.isEmpty) {
      _animatedListKey.currentState?.insertItem(_animatedItems.length);
      _animatedItems
          .add(ParentContent.create(null, ContentType.category, "", {}));
    }
    var end = _slidesScrollController!.position.pixels + _slideHeight;
    if (_animatedItems.length == controller.currentSerie.children.length) {
      end += 150.d;
    }

    _animatedListKey.currentState?.insertItem(_animatedItems.length - 1);
    _animatedItems.insert(_animatedItems.length - 1, controller.currentSlide);
    await Future.delayed(const Duration(milliseconds: 500));
    _playSounds();
    _scrollTo(end);
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
        child: AnimatedList(
            key: _animatedListKey,
            physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
            controller: _slidesScrollController,
            itemBuilder: (c, i, a) {
              final slide = _animatedItems[i];
              if (slide.type == ContentType.category) {
                return _nextSerieButton();
              }
              var items = <Widget>[];
              for (var c = 0; c < slide.children.length; c++) {
                items.add(_contentItem(slide.children[c] as Talk));
                items.add(SizedBox(height: 12.d));
              }
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: const Offset(0, 0),
                ).animate(a),
                child: Widgets.button(
                  context,
                  radius: 24.d,
                  height: _slideHeight,
                  color: TColors.primary0,
                  width: DeviceInfo.size.width,
                  margin: EdgeInsets.symmetric(vertical: 5.d),
                  padding: EdgeInsets.symmetric(horizontal: 20.d),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: items),
                  onPressed: () => _scrollTo(_slideHeight * i),
                ),
              );
            }),
      ),
    );
  }

  void _scrollTo(double offset) {
    _slidesScrollController!.animateTo(offset,
        duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
  }

  Widget _contentItem(Talk talk) {
    return switch (talk.type) {
      ContentType.repeat || ContentType.translate => _quizBuilder(talk),
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

  Future<void> _playSounds() async {
    for (var content in controller.currentSlide.children) {
      if (content.isQuiz) {
        listen(content as Talk);
      }
    }
  }

  @override
  Future<void> onListeningResult(QuizState state, Talk talk) async {
    const duration = Duration(milliseconds: 1500);
    serviceLocator<ListenerQuiz>().stop();
    if (state == QuizState.success) {
      await Future.delayed(duration);
      if (mounted) {
        controller.onQuizResult(true);
      }
      if (talk.type != ContentType.repeat) {
        await serviceLocator<Speaker>()
            .play(talk.targetValue, narrator: talk.type.narrator);
      }
    } else if (state == QuizState.failure) {
      controller.onQuizResult(false);
      await Future.delayed(duration);
      serviceLocator<ListenerQuiz>().state.value = QuizState.none;
      // serviceLocator<STT>().start(activeId: controller.uniqueIndex);
    }
  }

  Widget _quizBuilder(Talk talk) {
    var voice = talk.type == ContentType.translate
        ? talk.nativeValue
        : talk.targetValue;
    return ListenerBox(
      voiceHint: voice,
      hint: talk.nativeValue,
      answer: talk.targetValue,
      narrator: talk.type.narrator,
    );
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

  Widget _nextSerieButton() {
    var last = _animatedItems[_animatedItems.length - 2];
    if (last.id == controller.currentSerie.children.last.id) {
      return Column(
        children: [
          SizedBox(height: 50.d),
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
          SizedBox(height: 30.d),
          Text("slide_finish".l([]), style: TStyles.huge),
          SizedBox(height: 30.d),
          SkinnedButton(
            color: TColors.blue,
            height: 64.d,
            width: DeviceInfo.size.width * 0.8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("next_serie".l(), style: TStyles.largeInvert),
                SizedBox(width: 16.d),
                Asset.load<SvgPicture>("arrow_right", height: 20.d),
              ],
            ),
            onPressed: () => controller.changeSlide(1),
          ),
          SizedBox(height: 30.d),
        ],
      );
    }
    return Widgets.button(
      context,
      height: 100.d,
      alignment: const Alignment(0, 0.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Asset.load<SvgPicture>("wand"),
          SizedBox(width: 12.d),
          Text("next_slide".l(),
              style: TStyles.medium.copyWith(color: TColors.primary40)),
        ],
      ),
      onPressed: () => controller.changeSlide(1),
    );
  }
}
