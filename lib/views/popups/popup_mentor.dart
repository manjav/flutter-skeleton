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
    return IgnorePointer(
        ignoring: true,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _balloon(
                offset: 2.4,
                left: 40.d,
                width: 8.d,
                height: 8.d,
                bottom: 150.d),
            _balloon(
                offset: 3.2,
                left: 24.d,
                width: 16.d,
                height: 16.d,
                bottom: 168.d),
            _balloon(
                offset: 4.0,
                left: 32.d,
                right: 32.d,
                bottom: 192.d,
                child: Text("widget.message", style: TStyles.mediumInvert)),
            Positioned(left: 0, bottom: 0, child: _loadCharacter())
          ],
        ));
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
                      radius: 16.d,
                      color: TColors.primary10.withOpacity(0.9),
                      padding: EdgeInsets.all(16.d),
                      child: child));
            }));
  }

  _loadCharacter() {
    return LoaderWidget(AssetType.animationZipped, "character",
        width: 200.d, height: 200.d, onRiveInit: (artboard) {
      final controller =
          StateMachineController.fromArtboard(artboard, 'Character');
      artboard.addController(controller!);
    });
  }
}

enum CharacterMood { wonder, happy, angry, search }
