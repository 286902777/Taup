import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals/signals_flutter.dart';
import 'package:taup/page/player/play_controller.dart';

import '../../data/video_data.dart';
import '../../generated/assets.dart';
import '../../tool/time_tool.dart';

class PlayBottomWidget extends StatefulWidget {
  final VideoData video;
  final PlayController controller;
  const PlayBottomWidget({
    super.key,
    required this.video,
    required this.controller,
  });

  @override
  State<PlayBottomWidget> createState() => _PlayBottomWidgetState();
}

class _PlayBottomWidgetState extends State<PlayBottomWidget> {
  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final double b = (padding.bottom == 0 ? 20 : padding.bottom);
    final double l = (padding.left == 0 ? 20 : padding.left);
    final double r = (padding.right == 0 ? 20 : padding.right);
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(left: l, right: r, bottom: b),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sliderView(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _buildVideoVControlWidgets(),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildVideoVControlWidgets() {
    return [
      Watch(
        (ctx) => Text(
          TimeTool.formatString(widget.controller.playPosition.value),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
      Watch(
        (ctx) => Text(
          ' / ${TimeTool.formatString(widget.controller.playDuration.value)}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
      Spacer(),
      Watch.builder(
        builder: (ctx) {
          final portrait =
              widget.controller.orientation == DeviceOrientation.portraitUp;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.controller.videoRotate,
            child: Image.asset(
              portrait ? Assets.assetsPlayFull : Assets.assetsPlayFullUn,
              width: 24,
              height: 24,
            ),
          );
        },
      ),
    ];
  }

  Widget _sliderView() {
    return Watch((ctx) {
      final position = widget.controller.playPosition.value;
      final duration = widget.controller.playDuration.value;
      // 如果 duration 无效，不显示 Slider
      if (duration <= 0) return const SizedBox.shrink();
      return SliderTheme(
        data: SliderThemeData(
          trackHeight: 4,
          activeTrackColor: const Color(0xFF76FC81), // 轨道绿色
          inactiveTrackColor: const Color(0xFFBBBBBB),
          thumbShape: const RoundedRectSliderThumbShape(
            width: 12,
            height: 12,
            radius: 2,
          ),
          thumbColor: Colors.white,
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
        ),
        child: Slider(
          padding: const EdgeInsets.all(0),
          value: position.clamp(0.0, duration).toDouble(),
          min: 0,
          max: duration.toDouble(),
          onChanged: (value) {
            widget.controller.player.seek(Duration(seconds: value.toInt()));
          },
          onChangeStart: (value) async {
            widget.controller.videoOnChangeStart();
          },
          onChangeEnd: (value) async {
            widget.controller.videoOnChangeEnd();
          },
        ),
      );
    });
  }
}

class RoundedRectSliderThumbShape extends SliderComponentShape {
  final double width;
  final double height;
  final double radius;

  const RoundedRectSliderThumbShape({
    this.width = 16,
    this.height = 10,
    this.radius = 4,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(width, height);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.blue
      ..style = PaintingStyle.fill;

    // 绘制圆角矩形
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rrect, paint);
  }
}
