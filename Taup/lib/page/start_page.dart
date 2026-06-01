import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals/signals_flutter.dart';
import 'package:taup/generated/assets.dart';

import '../tool/cache_tool.dart';
import '../tool/config_tool.dart';
import '../tool/open_tool.dart';
import 'base_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final progress = signal<double>(0);
  Timer? _timer;
  double totalTime = 5.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 3000), () {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    });
    initConfig();
    _startTimer();
  }

  void _startTimer() {
    if (_timer != null) return;
    int recordTime = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      recordTime += 10;
      progress.value = recordTime / (totalTime * 100);
      if (recordTime >= (totalTime * 100)) {
        _cancelTime();
      }
    });
  }

  void _cancelTime() {
    _timer?.cancel();
    _timer = null;
    toHomePage();
  }

  void toHomePage() {
    if (mounted) {
      OpenTool.toHome(context);
    }
  }

  Future initConfig() async {
    await CacheTool.instance.initConfig();
    await ConfigTool.instance.initConfig();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BasePage(
      child: SizedBox(
        width: size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: size.height * 0.2),
            Image.asset(
              Assets.assetsLogoIcon,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 18),
            Image.asset(
              Assets.assetsStartText,
              width: 102,
              fit: BoxFit.fitWidth,
            ),
            Spacer(),
            Text(
              'Resource loading…',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 10,
                color: Color(0xFFFFFFFF),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 4,
              width: 190,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                  child: Watch(
                    (ctx) => LinearProgressIndicator(
                      value: progress.value,
                      backgroundColor: Color(0xB3FFFFFF),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF76FC81),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 72),
          ],
        ),
      ),
    );
  }
}
