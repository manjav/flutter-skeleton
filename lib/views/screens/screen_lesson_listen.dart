import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_export.dart';

class LessonListenScreen extends AbstractScreen {
  LessonListenScreen({super.key}) : super(Routes.listen);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<LessonListenScreen>
    with LessonMixin {
  final ValueNotifier<int> _quizState = ValueNotifier(0);

  @override
  void startQuiz(Chat chat) {
    _quizState.value = 0;
  }
  @override
  Widget footerBuilder() {
    var size = 80.d;
    var chat = currentTalk!.chats.where((c) => c.type == ChatType.user).first;
    return ValueListenableBuilder<int>(
      valueListenable: _quizState,
      builder: (context, value, child) => Padding(
        padding: EdgeInsets.all(8.d),
        child: Column(
          children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Widgets.button(
            context,
            radius: size,
            width: size * 0.5,
            height: size * 0.5,
            color: TColors.primary10,
            alignment: Alignment.center,
            padding: EdgeInsets.all(12.d),
            child: StreamBuilder(
              stream: serviceLocator<Sounds>()
                  .getPlayer(chat.value)
                  .onPlayerStateChanged,
              builder: (context, snapshot) => Asset.load<SvgPicture>(
                  snapshot.data == PlayerState.playing ? "stop" : "play",
                  width: size * 0.3),
            ),
            onPressed: () => serviceLocator<Speaker>()
                .play(chat.value, narrator: chat.type.narrator),
          ),
          DirText(currentTalk!.chats.first.value),
        ],
      ),
          ],
        ),
      ),
    );
  }

  Widget _answerBox() {
    return Widgets.rect(
      radius: 20.d,
  Widget _wrapper(
    int itemCount,
    Widget Function(int) itemBuilder,
  ) {
    return Wrap(
      children: [
        for (var i = 0; i < itemCount; i++) itemBuilder(i),
      ],
    );
  }
  }
