import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:signals/signals_flutter.dart';
import 'package:taup/page/player/play_bottom_widget.dart';
import 'package:taup/page/player/play_brightness.dart';
import 'package:taup/page/player/play_center_widget.dart';
import 'package:taup/page/player/play_controller.dart';
import 'package:taup/page/player/play_skip.dart';
import 'package:taup/page/player/play_title.dart';
import 'package:taup/tool/bus_tool.dart';

import '../../data/video_data.dart';
import '../../tool/config_tool.dart';
import '../../tool/event_tool.dart';

class PlayPage extends StatefulWidget {
  final List<VideoData> list;
  final int index;
  final EventValue form;
  const PlayPage({
    super.key,
    required this.list,
    required this.index,
    required this.form,
  });

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  final PlayController controller = PlayController();
  StreamSubscription? _streamSubscription;
  final animatedDuration = const Duration(milliseconds: 220);

  @override
  void initState() {
    // TODO: implement initState

    controller.initState(
      list: widget.list,
      value: EventValue.play,
      index: widget.index,
      history: widget.form == EventValue.history,
    );
    _streamSubscription = BusTool.on().listen((res) {
      if (res != AppInfo.busProductPop) return;
      controller.popAction();
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    _streamSubscription?.cancel();
    _streamSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _buildContentWidget(context),
      ),
    );
  }

  Widget _buildContentWidget(BuildContext context) {
    return Watch.builder(
      builder: (ctx) {
        final index = controller.playIndex.value;
        final video = controller.videoList[index];
        final show = controller.showTool.value;
        return Stack(
          children: [
            Center(
              child: Video(controller: controller.controller, controls: null),
            ),
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: controller.playSingOnTap,
                onDoubleTapDown: controller.playDoubleTapDown,
                onVerticalDragEnd: controller.playVerticalEndEvent,
                onLongPressStart: controller.playLongPressStartEvent,
                onVerticalDragStart: controller.playVerticalStartEvent,
                onVerticalDragUpdate: controller.playVerticalUpdateEvent,
                child: Container(
                  color: controller.showTool.value
                      ? Color(0x65000000)
                      : Colors.transparent,
                ),
              ),
            ),
            Visibility(
              visible: controller.popupType.value == PlayPopupType.brightness,
              child: PlayBrightness(
                type: PlayPopupType.brightness,
                value: controller.brightness,
              ),
            ),
            // Visibility(
            //   visible: controller.loadType.value != PlayLoadType.none,
            //   child: PlayHub(clickVip: controller.clickAccelerate),
            // ),
            Visibility(
              visible: controller.popupType.value == PlayPopupType.volume,
              child: PlayBrightness(
                type: PlayPopupType.volume,
                value: controller.playVolume,
              ),
            ),
            Visibility(
              visible:
                  (controller.popupType.value == PlayPopupType.rewind ||
                  controller.popupType.value == PlayPopupType.forward),
              child: PlaySkip(
                isRewind: controller.popupType.value == PlayPopupType.rewind,
              ),
            ),
            AnimatedPositioned(
              left: 0,
              right: 0,
              top: show ? 0 : -100,
              duration: animatedDuration,
              child: PlayTitle(
                video: video,
                goBack: goBack,
                goVip: controller.goVip,
              ),
            ),
            AnimatedPositioned(
              left: 0,
              right: 0,
              bottom: show ? 0 : -150,
              duration: animatedDuration,
              child: PlayBottomWidget(video: video, controller: controller),
            ),
            AnimatedPositioned(
              duration: animatedDuration,
              child: Visibility(
                visible: show,
                child: PlayCenterWidget(video: video, controller: controller),
              ),
            ),
          ],
        );
      },
    );
  }

  void goBack() {
    controller.goBack(context);
  }
}
