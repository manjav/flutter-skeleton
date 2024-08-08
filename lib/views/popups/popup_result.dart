import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifetalk/app_export.dart';
import 'package:lifetalk/skeleton/mixins/feast_mixin.dart';
import 'package:rive/rive.dart';

class ResultPopup extends AbstractPopup {
  const ResultPopup({super.key}) : super(Routes.popupResult);

  @override
  State<ResultPopup> createState() => _PopupState();
}

class _PopupState extends AbstractPopupState<ResultPopup> {
  String? message;

  @override
  Widget contentFactory() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            width: 330.d, height: 390.d, child: GroupResult(args: widget.args)),
      ],
    );
  }
}

class GroupResult extends StatefulWidget {
  final Map<String, dynamic> args;
  const GroupResult({super.key, required this.args});

  @override
  State<GroupResult> createState() => _GroupResultState();
}

class _GroupResultState extends State<GroupResult> with FeastMixin {
  StateMachineController? _controller;
  int score = 0;
  @override
  void initState() {
    super.initState();
    children = [animationBuilder("result")];
    process(() async {
      score = (widget.args["score"] / widget.args["quizCount"]).round();
      await serviceLocator<AccountProvider>().saveScore(
        widget.args["id"]!,
        {
          "score": score,
          "quizCount": widget.args["quizCount"],
          "sentenceCount": widget.args["sentenceCount"],
        },
      );
      return true;
    });
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    _controller = super.onRiveInit(artboard, stateMachineName);
    final formatter = NumberFormat("00");
    updateRiveText("message", "done_label".l());
    updateRiveText("scoreLabel", "score_level_good".l());
    updateRiveText("scoreValue", formatter.format(score));
    updateRiveText("sentencesLabel", "sentences_label".l());
    updateRiveText(
        "sentencesValue", formatter.format(widget.args["sentenceCount"]));
    return _controller!;
  }

  @override
  void onRiveEvent(RiveEvent event) {
    super.onRiveEvent(event);
    if (state == FeastState.closed) {}
  }

  @override
  void dismiss() {
    super.dismiss();
    Navigator.pop(context);
  }
}
