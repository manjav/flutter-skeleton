import 'package:flutter/material.dart';
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
    var items = <Widget>[
      Text(
        "nice_job".l(),
        style: TStyles.large.copyWith(color: TColors.yellow),
      ),
      GroupResult(args: widget.args),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items,
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

  @override
  void initState() {
    super.initState();
    children = [/* animationBuilder("result") */];
    process(() async {
      await serviceLocator<AccountProvider>().saveScore(
        widget.args["id"]!,
        {"score": widget.args["score"]},
      );
      return true;
    });
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    _controller = super.onRiveInit(artboard, stateMachineName);
    updateRiveText("caption", "value");
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
