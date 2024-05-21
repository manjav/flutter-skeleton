import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class LessonChatScreen extends AbstractScreen {
  LessonChatScreen({super.key}) : super(Routes.chat);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<LessonChatScreen>
    with LessonMixin {
  final List<Talk> _animatedItems = [];
  final ValueNotifier<Talk?> _name = ValueNotifier(null);
  final _animatedListKey = GlobalKey<AnimatedListState>();
  final ScrollController _chatScrollController = ScrollController();

  @override
  void initState() {
    controller.steps = Get.arguments["content"].children;
    // if (!controller.steps[1].isChat) controller.steps.removeRange(1, 3); // Temp
    controller.onQuizStart = _startQuizCallback;
    controller.onQuizEnd = _endQuizCallback;
    controller.changeStep(1);
    super.initState();
  }

  @override
  Widget childBuilder(double paddingTop) {
    return Column(children: [
      SizedBox(height: 90.d),
      _nameDisplayBuilder(),
      SizedBox(height: 10.d),
      Expanded(
        child: AnimatedList(
            key: _animatedListKey,
            controller: _chatScrollController,
            padding: EdgeInsets.fromLTRB(
                padding, paddingTop + padding * 6, padding, 300.d),
            itemBuilder: (c, i, a) =>
                _animatedItemBuilder(_animatedItems[i], a)),
      )
    ]);
  }

  Widget _animatedItemBuilder(Talk talk, Animation<double> animation) {
    talk.scrollPosition = _chatScrollController.position.pixels;
    return ScaleTransition(
      alignment: switch (talk.type) {
        ContentType.user => Alignment.bottomRight,
        ContentType.bot => Alignment.topLeft,
        _ => Alignment.center,
      },
      scale: CurvedAnimation(
        parent: animation.drive(Tween<double>(begin: 0, end: 1)),
        curve: Curves.easeOutBack,
      ),
      child: switch (talk.type) {
        ContentType.image => _imageBuilder(talk),
        // ContentType.name => SizedBox(height: 10.d),
        _ => _chatBuilder(talk),
      },
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

  Widget _chatBuilder(Talk talk) {
    var tip = switch (talk.type) {
      ContentType.user => BalloonTipPosition.rightBottom,
      ContentType.bot => BalloonTipPosition.leftTop,
      _ => BalloonTipPosition.none,
    };

    var isTarget = talk.isChat || talk.isName;
    var main = isTarget ? talk.targetValue : talk.nativeValue;
    var translate = isTarget ? talk.nativeValue : null;
    return RadioBox(
      main,
      ballonPosition: tip,
      narrator: talk.type.narrator,
      translation: translate,
      textStyle:
          talk.isChat ? null : (talk.isName ? TStyles.large : TStyles.small),
      color: talk.isChat
          ? null
          : (talk.isName ? TColors.cream : TColors.primary10),
    );
  }

  void _startQuizCallback(Content step) {
    if (!step.isQuiz) return;
    var account = serviceLocator<AccountProvider>();
    serviceLocator<STT>().start(
      locale: account.metadata["targetLanguage"],
      pattern: step.targetValue,
      exceptions: [account.account.user.displayName!.simple()],
      onResult: _onQuizResult,
    );
  }

  Future<void> _endQuizCallback(Content step) async {
    step = step as Talk;
    var duration = const Duration(milliseconds: 500);
    if (step.isName) {
      _name.value = step;
    }
    _animatedListKey.currentState?.insertItem(_animatedItems.length);
    _animatedItems.add(step);
    await _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: duration,
        curve: Curves.easeOutQuart);

    if (step.isQuiz || step.type == ContentType.image) {
      await Future.delayed(const Duration(milliseconds: 10));
    } else {
      final text =
          step.isChat || step.isName ? step.targetValue : step.nativeValue;
      if (step.isChat || step.isName) {
        final narrator = step.isName
            ? Narrator.nova
            : step.isChat
                ? Narrator.fable
                : Narrator.onyx;
        serviceLocator<Speaker>().play(text, narrator: narrator);
      } else {
        duration = Duration(milliseconds: text.length * 40);
      }
    }

    await Future.delayed(duration);
  }

  Future<void> _onQuizResult(QuizState state, String text) async {
    const duration = Duration(milliseconds: 1500);
    serviceLocator<STT>().stop();
    if (state == QuizState.success) {
      await Future.delayed(duration);
      serviceLocator<STT>().state.value = QuizState.none;
      if (mounted) {
        controller.onStepResult(true);
      }
    } else if (state == QuizState.fail) {
      controller.onStepResult(false);
      await Future.delayed(duration);
      serviceLocator<STT>().start();
    }
  }

  @override
  Widget footerBuilder() {
    if (controller.stepIndex.value >= controller.steps.length) {
      return const SizedBox();
    }
    var step = controller.steps[controller.stepIndex.value] as Talk;
    if (!step.isQuiz) {
      return const SizedBox();
    }

    var footer = Column(children: [
      DirText(controller.practice,
          textAlign: TextAlign.center, style: TStyles.small),
      SizedBox(height: 24.d),
      ListenerBox(step, challengeMode: Get.arguments["challengeMode"])
    ]);

    controller.footerSize.value = getFooterHeight(context);
    return footer;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _nameDisplayBuilder() {
    return ValueListenableBuilder(
      valueListenable: _name,
      builder: (context, value, child) {
        if (_name.value == null) return const SizedBox();
        return Widgets.touchable(
          context,
          child: _chatBuilder(value!),
          onTap: () {
            _chatScrollController.animateTo(value.scrollPosition - 200.d,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutQuart);
          },
        );
      },
    );
  }
}
