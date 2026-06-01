import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:signals/signals_flutter.dart';

import '../data/video_data.dart';
import '../myWidget/alert_widget.dart';
import '../tool/bus_tool.dart';
import '../tool/config_tool.dart';
import '../tool/data_tool.dart';

class HistoryController {
  final historyList = <VideoData>[].toSignal();

  void loadData() async {
    historyList.value = [];
    final list = await DataTool.query(
      type: DataType.video,
      where: 'history = ?',
      args: [1],
    );
    historyList.value = list.map((i) => VideoData.dbFromMap(i)).toList();
  }

  /// 删除选中视频
  void deleteVideos({VideoData? item}) async {
    SmartDialog.show(
      clickMaskDismiss: false,
      maskColor: Color(0xB3000000),
      alignment: Alignment.center,
      builder: (_) {
        return AlertWidget(
          title: 'Delete history records?',
          comfirmTap: () async {
            if (item == null) {
              for (final data in historyList) {
                data.history = false;
                final json = data.toMap();
                await DataTool.update(type: DataType.video, values: json);
              }
            } else {
              item.history = false;
              final json = item.toMap();
              await DataTool.update(type: DataType.video, values: json);
            }
            BusTool.send(AppInfo.busHistory);
            loadData();
          },
        );
      },
    );
  }
}
