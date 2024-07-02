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
    _animatedListKey.currentState?.insertItem(_animatedItems.length - 1);
    _animatedItems.insert(_animatedItems.length - 1, controller.currentSlide);
    await Future.delayed(const Duration(milliseconds: 100));
    _playSounds();
    _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut);
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
                  height: 160.d,
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
                child: Widgets.rect(
                  radius: 24.d,
                  height: 320.d,
                  color: TColors.primary0,
                  width: DeviceInfo.size.width,
                  margin: EdgeInsets.symmetric(vertical: 5.d),
                  padding: EdgeInsets.symmetric(horizontal: 32.d),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: items),
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
    }
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
