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
  List<String> _choices = [], _answers = [], _pattern = [];
  final ValueNotifier<int> _quizState = ValueNotifier(0);

  @override
  Future<void> nextStep(int index) async {
    if (index < scenario!.thread.length) {
      var chat = scenario!.thread[index].chats
          .where((c) => c.type == ChatType.user)
          .first;
      _pattern = chat.value.split(" ");
      _choices = List.from(_pattern);
      _choices.shuffle();
      _answers = [];
    }
    await super.nextStep(index);
  }

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
            SizedBox(height: 8.d),
            _answerBox(),
          ],
        ),
      ),
    );
  }

  Widget _answerBox() {
    return Widgets.rect(
      radius: 20.d,
      color: TColors.primary10,
      padding: EdgeInsets.fromLTRB(16.d, 6.d, 6.d, 6.d),
      constraints: BoxConstraints.expand(height: 64.d),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _wrapper(_answers.length, (i) => Text("${_answers[i]}  ")),
            ),
          ),
          SizedBox(width: 8.d),
          _answers.isEmpty
              ? const SizedBox()
              : Widgets.button(
                  context,
                  width: 80.d,
                  color: TColors.primary20,
                  child: Container(
                    alignment: Alignment.center,
                    height: 14.d,
                    width: 13.d,
                    child: Asset.load<SvgPicture>("clear", width: 24.d),
                  ),
                  onPressed: () {
                    if (_quizState.value > -1) {
                      _answers.removeLast();
                      _quizState.value = _answers.length;
                    }
                  },
                ),
        ],
      ),
    );
  }

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
