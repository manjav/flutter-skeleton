import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../app_export.dart';

mixin LessonMixin {
  ParentContent? content;
  final GlobalKey footerKey = GlobalKey();
  int _fouls = 0, _streakCorrects = 0, _maxCorrects = 0;
  final ValueNotifier<int> index = ValueNotifier(0);
  final ValueNotifier<double> headerSize = ValueNotifier(0);

  Widget headerBuilder(BuildContext context, ValueNotifier<int> index,
      EdgeInsetsGeometry padding, ParentContent group) {
    var person = (group.children[0] as Talk).personId;
    return Widgets.rect(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [
              0.7,
              1
            ],
            colors: <Color>[
              TColors.primary10,
              TColors.primary10.withOpacity(0)
            ]),
      ),
      child: Row(
        children: [
          Avatar(person, 64.d),
          SizedBox(width: 12.d),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: index,
              builder: (context, value, child) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(person),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    tween: Tween(
                      begin: (value - 1) / group.children.length,
                      end: value / group.children.length,
                    ),
                    builder: (context, value, _) => LinearProgressIndicator(
                      minHeight: 6.d,
                      value: value,
                      color: TColors.green,
                      backgroundColor: TColors.primary20,
                      borderRadius: BorderRadius.all(Radius.circular(6.d)),
                    ),
                  ),
                  Text(
                    "${index.value} / ${group.children.length}",
                    style: TStyles.small.copyWith(color: TColors.primary30),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.d),
          Widgets.button(
            context,
            width: 32.d,
            height: 32.d,
            radius: 32.d,
            padding: EdgeInsets.all(8.d),
            color: TColors.primary20,
            child: Asset.load<SvgPicture>("close"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  Future<void> nextStep(BuildContext context) async {
    if (index.value >= content!.children.length) {
      var len = (content!.children.length / 2).round();
      var corrects = len - _fouls.max(5);
      print(
          "${corrects * 100 / len}% $corrects $_maxCorrects $len   ${3 - _fouls.max(2)}");
      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        // Navigator.pop(context, 3 - _fouls.max(2));
      }
      return;
    }
    var talk = content!.children[index.value] as Talk;
    await Future.delayed(const Duration(milliseconds: 500));
    if (!context.mounted) return;

    await updateContent();
    index.value += 1;
    await serviceLocator<Speaker>()
        .play(talk.targetValue, narrator: talk.type.narrator);
    if (!context.mounted) return;

    talk = content!.children[index.value] as Talk;
    headerSize.value = getFooterHeight(context);
    startQuiz(talk);
  }

  void startQuiz(Talk chat) {}

  double getFooterHeight(BuildContext context) {
    double height = 500.d;
    final keyContext = footerKey.currentContext;
    if (context.mounted && keyContext != null) {
      final box = keyContext.findRenderObject() as RenderBox;
      height = box.size.height;
    }
    return height;
  }

  updateContent() {}

  Future<void> onQuizResult(BuildContext context, bool isSuccess) async {
    if (isSuccess) {
      serviceLocator<Sounds>().play("correct_${Random().nextInt(3)}");
      _streakCorrects++;
      _maxCorrects = _streakCorrects.min(_maxCorrects);

      // Waiting for celebration
      await Future.delayed(const Duration(milliseconds: 500));
      if (!context.mounted) return;

      headerSize.value = 0;
      await updateContent();
      index.value += 1;

      await Future.delayed(const Duration(milliseconds: 500));
      if (!context.mounted) return;
      nextStep(context);
    } else {
      ++_fouls;
      _streakCorrects = 0;
      serviceLocator<Sounds>().play("wrong");
    }
  }
}
