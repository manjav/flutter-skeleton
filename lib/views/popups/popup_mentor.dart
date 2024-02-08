import 'package:flutter/material.dart';
import 'package:lingai/app_export.dart';
import 'package:rive/rive.dart';

class MentorPopup extends AbstractPopup {
  // final String message;
  // final CharacterMood characterMood;
  const MentorPopup({super.key}) : super(Routes.popupMentor);

  @override
  State<MentorPopup> createState() => _TutorialState();
}

class _TutorialState extends AbstractPopupState<MentorPopup>
    with TickerProviderStateMixin {
  late AnimationController _appearedAnimation;
  @override
  void initState() {
    _appearedAnimation = AnimationController(
        vsync: this,
        upperBound: 5,
        duration: const Duration(milliseconds: 900));
    _appearedAnimation.animateTo(_appearedAnimation.upperBound);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TColors.transparent,
      child: Widgets.button(context,
          padding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _balloon(offset: 2.4, left: 40, width: 8, height: 8, bottom: 140),
              _balloon(
                  offset: 3.2, left: 24, width: 32, height: 32, bottom: 160),
              _balloon(
                  offset: 4.0,
                  left: 32,
                  right: 32,
                  bottom: 200,
                  child: const Text("widget.message")),
              Positioned(left: 0, bottom: 0, child: _loadCharacter())
            ],
          ),
          onPressed: () => Navigator.pop(context)),
    );
  }

  _balloon(
      {double? left,
      double? right,
      double? bottom,
      double? width,
      double? height,
      Widget? child,
      double offset = 0}) {
    return Positioned(
        left: left,
        right: right,
        bottom: bottom,
        width: width,
        height: height,
        child: AnimatedBuilder(
            animation: _appearedAnimation,
            builder: (_, __) {
              var opacity =
                  (_appearedAnimation.value - offset).clamp(0, 1).toDouble();
              return Transform.scale(
                  scale: opacity,
                  alignment: Alignment.bottomLeft,
                  child: Widgets.rect(
                      decoration: BoxDecoration(
                        color: TColors.primary0,
                        border:
                            Border.all(color: TColors.primary30, width: 2.d),
                        borderRadius: BorderRadius.all(Radius.circular(16.d)),
                      ),
                      padding: EdgeInsets.all(16.d),
                      child: child));
            }));
  }

  _loadCharacter() {
    return LoaderWidget(AssetType.animationZipped, "character",
        width: 200, height: 200, onRiveInit: (artboard) {
      final controller =
          StateMachineController.fromArtboard(artboard, 'Character');
      controller!.findInput<double>("reaction")?.value = 4;
      artboard.addController(controller);
    });
  }
}

enum CharacterMood { wonder, happy, angry, search, normal }
