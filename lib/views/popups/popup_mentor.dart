import 'package:flutter/material.dart';
import 'package:lingai/app_export.dart';

class MentorPopup extends AbstractPopup {
  const MentorPopup({super.key}) : super(Routes.popupMentor);

  @override
  State<MentorPopup> createState() => _TutorialState();
}

class _TutorialState extends AbstractPopupState<MentorPopup> {
  String? message;
  MentorReaction? reaction;

  @override
  Color get backgroundColor => TColors.transparent;

  @override
  void initState() {
    message = widget.args["message"];
    reaction = widget.args["reaction"];
    super.initState();
  }

  @override
  Widget outerChromeFactory() =>
      Mentor(message!, reaction ?? MentorReaction.angry);
}
