import 'package:flutter/cupertino.dart';
import 'package:signals/signals_flutter.dart';
import 'package:taup/tool/bus_tool.dart';
import 'package:taup/tool/data_tool.dart';

import '../data/video_data.dart';
import '../tool/config_tool.dart';
import '../tool/time_tool.dart';

class HomeController {
  final localList = <VideoData>[].toSignal();
  late final localVideoList = computed(() {
    return localList.value.where((i) => i.video == true).toList();
  });

  final historyList = <VideoData>[].toSignal();
  // final channelList = <ChannelData>[].toSignal();
  final hasData = Signal(false);
  final ValueNotifier<int> valueNotifier = ValueNotifier(0);

  void initData() {
    loadLocalData();
    loadHistoryData();
    BusTool.on().listen((res) {
      if (res == AppInfo.busHome) loadLocalData();
      if (res == AppInfo.busHistory) loadHistoryData();
      // if (res == AppInfo.busChannel) loadChannelData();
    });
    // EventTool.otherTabEvent(event: AppEventName.homeExpose);
    // Future.delayed(const Duration(seconds: 2)).then((v) {
    //   final str = channelList.length.toString();
    //   EventTool.otherTabEvent(
    //     event: AppEventName.homHistoryExpose,
    //     history: str,
    //   );
    //   EventTool.otherTabEvent(event: AppEventName.homeChannelExpose);
    // });
  }

  void loadLocalData() async {
    localList.value = [];
    final list = await DataTool.query(
      type: DataType.video,
      where: 'local = ?',
      args: [1],
    );
    localList.value = list.map((i) => VideoData.dbFromMap(i)).toList();
    isHasData();
  }

  /// 加载历史数据
  void loadHistoryData() async {
    historyList.value = [];
    final list = await DataTool.query(
      type: DataType.video,
      where: 'history = ?',
      args: [1],
    );
    historyList.value = list.map((i) => VideoData.dbFromMap(i)).toList();
    isHasData();
  }

  void isHasData() {
    if (localList.value.isNotEmpty || historyList.value.isNotEmpty) {
      hasData.value = true;
    } else {
      hasData.value = false;
    }
    valueNotifier.value = TimeTool.millisecondsSince();
  }
}
