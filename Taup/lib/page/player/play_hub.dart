import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../generated/assets.dart';
import '../../tool/config_tool.dart';

class PlayHub extends StatefulWidget {
  final Function() clickVip;
  const PlayHub({super.key, required this.clickVip});

  @override
  PlayHubState createState() => PlayHubState();
}

class PlayHubState extends State<PlayHub> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final dataSize = signal(0.0);
  Timer? _timer;

  @override
  void initState() {
    // TODO: implement initState
    _startTimer();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer?.cancel();
    _controller.dispose();
    dataSize.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    final Random random = Random();
    dataSize.value = random.nextInt(80) + 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      dataSize.value = random.nextInt(80) + 30;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isVip = ConfigTool.instance.memberType.isNotEmpty;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _controller,
            child: Image.asset(Assets.assetsRenameIcon, width: 36, height: 36),
          ),
          SizedBox(height: 12),
          Watch(
            (_) => Text(
              isVip
                  ? 'Loading extremely fast…'
                  : 'Current line congestion... ${dataSize.value}kb/s',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFFFFFFFF),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (isVip == false) SizedBox(height: 12),
          if (isVip == false)
            GestureDetector(
              onTap: () {
                widget.clickVip();
              },
              child: Container(
                width: 211,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFF8D476), // 自定义颜色
                      Color(0xFF6020F0),
                      Color(0xFF1C46F5),
                    ],
                    stops: [0.0, 0.35, 1.0], // 颜色停止位置
                  ),
                ),
                child: Center(
                  child: Text(
                    'Exclusive acceleration line',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
