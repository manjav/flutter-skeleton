import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class SeriesScreen extends AbstractScreen {
  SeriesScreen({super.key}) : super(Routes.series);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<SeriesScreen> with LessonMixin {
  final List<ParentContent> _animatedItems = [];
  final _animatedListKey = GlobalKey<AnimatedListState>();
  final _slideHeight = DeviceInfo.size.height * 0.5;
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
    _animatedListKey.currentState?.insertItem(_animatedItems.length - 1);
    _animatedItems.insert(_animatedItems.length - 1, controller.currentSlide);
    await Future.delayed(const Duration(milliseconds: 500));
    _playSounds();
    _scrollTo(end);
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
            physics: const PageScrollPhysics(),
            controller: _slidesScrollController,
            itemBuilder: (c, i, a) {
              final slide = _animatedItems[i];
              if (slide.type == ContentType.category) {
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
                          style: TStyles.medium
                              .copyWith(color: TColors.primary40)),
                    ],
                  ),
                  onPressed: () => controller.changeSlide(1),
                );
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
      ContentType.image => _imageBuilder(talk),
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
      await playSound(content as Talk);
      if (content.isQuiz) _startQuiz(content);
    }
  }

  Future<void> _startQuiz(Talk talk) async {
    var account = serviceLocator<AccountProvider>();
    serviceLocator<STT>().start(
      pattern: talk.targetValue,
      locale: account.metadata["targetLanguage"],
      exceptions: [account.account.user.displayName!.patternize()],
      onResult: _onSTTResult,
    );
  }

  Future<void> _onSTTResult(QuizState state, String text) async {
    const duration = Duration(milliseconds: 1500);
    serviceLocator<STT>().stop();
    if (state == QuizState.success) {
      await Future.delayed(duration);
      // serviceLocator<STT>().state.value = QuizState.none;
      if (mounted) {
        controller.onQuizResult(true);
      }
    } else if (state == QuizState.fail) {
      controller.onQuizResult(false);
      // await Future.delayed(duration);
      // serviceLocator<STT>().start(activeId: controller.uniqueIndex);
    }
  }

  Widget _quizBuilder(Talk talk) {
    final hint = talk.type == ContentType.translate
        ? talk.nativeValue
        : talk.targetValue;
    return ListenerBox(
      hint: hint,
      answer: talk.targetValue,
      narrator: talk.type.narrator,
    );
  }

  Widget _imageBuilder(Talk talk) {
    final border = BorderRadius.all(Radius.circular(12.d));
    return Widgets.rect(
      decoration: BoxDecoration(
        borderRadius: border,
        border: Border.all(
          width: 2.d,
          color: TColors.primary20,
        ),
        shape: BoxShape.rectangle,
      ),
      padding: EdgeInsets.all(1.d),
      alignment: Alignment.center,
      margin: EdgeInsets.all(24.d),
      child: ClipRRect(
        borderRadius: border,
        child: LoaderWidget(
          AssetType.image,
          talk.targetValue,
          height: 180.d,
        ),
      ),
    );
  }

  @override
  void dispose() {
    serviceLocator<Sounds>().stopAll();
    controller.serieIndex.removeListener(_onChangeSerie);
    controller.slideIndex.removeListener(_onChangeSlide);
    super.dispose();
  }
}
