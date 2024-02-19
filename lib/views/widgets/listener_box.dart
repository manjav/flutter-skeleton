import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_export.dart';

class ListenerBox extends StatelessWidget {
  const ListenerBox({super.key});

  @override
  Widget build(BuildContext context) {
    var stt = serviceLocator<STT>();
    var size = 100.d;
    return ValueListenableBuilder(
      valueListenable: stt.state,
      builder: (context, value, child) {
        return Column(
          children: [
            Widgets.button(
              context,
              width: size,
              height: size,
              radius: size,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              color: TColors.primary10,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ValueListenableBuilder(
                    valueListenable: stt.audioLevel,
                    builder: (context, value, child) => AnimatedContainer(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(size)),
                        color: TColors.primary20,
                      ),
                      width: size * stt.audioLevel.value,
                      height: size * stt.audioLevel.value,
                      duration: const Duration(milliseconds: STT.levelInterval),
                    ),
                  ),
                  Asset.load<SvgPicture>(
                    "mic",
                    width: size * 0.3,
                    svgColorFilter:
                        ColorFilter.mode(_getIconColor(), BlendMode.srcIn),
                  ),
                ],
              ),
              onPressed: stt.startListening,
            ),
            ValueListenableBuilder(
              valueListenable: stt.recognizedWords,
              builder: (context, value, child) => Text(value,
                  style: TStyles.medium.copyWith(color: _getIconColor())),
            ),
            SizedBox(height: 16.d),
          ],
        );
      },
    );
  }

  Color _getIconColor() {
    return switch (serviceLocator<STT>().state.value) {
      STTState.fail || STTState.error => TColors.error,
      STTState.success => TColors.green,
      STTState.disable => TColors.primary30,
      STTState.done => TColors.primary40,
      _ => TColors.primary60,
    };
  }
}
