import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:taup/page/player/play_controller.dart';

import '../../../generated/assets.dart';

class PlayBrightness extends StatelessWidget {
  final PlayPopupType type;
  final Signal<double> value;
  const PlayBrightness({super.key, required this.type, required this.value});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 32,
          width: 136,
          child: Stack(
            children: [
              Positioned(
                child: Watch(
                  (ctx) => LinearProgressIndicator(
                    minHeight: 32,
                    value: value.value,
                    color: Colors.white,
                    backgroundColor: Color(0x40FFFFFF),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 4,
                bottom: 4,
                child: Image.asset(
                  type == PlayPopupType.brightness
                      ? Assets.assetsLightIcon
                      : Assets.assetsVolumeIcon,
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
