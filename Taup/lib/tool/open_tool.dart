import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:taup/data/video_data.dart';
import 'package:taup/myWidget/edit_list_page.dart';
import 'package:taup/myWidget/system_select_page.dart';
import 'package:taup/page/edit_content_page.dart';
import 'package:taup/page/history_page.dart';
import 'package:taup/page/home_page.dart';
import 'package:taup/page/image_page.dart';
import 'package:taup/page/my_web_page.dart';
import 'package:taup/page/player/play_page.dart';
import 'package:taup/tool/bus_tool.dart';
import 'package:taup/tool/data_tool.dart';

import '../main.dart';
import '../myWidget/info_detail_widget.dart';
import '../myWidget/info_widget.dart';
import '../page/set_page.dart';
import 'config_tool.dart';
import 'event_tool.dart';

class OpenTool {
  static void toHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false, // 返回false表示移除所有页面
    );
  }

  static void toSet(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SetPage()));
  }

  static void toWeb(BuildContext context, WebLink link) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyWebPage(link: link)),
    );
  }

  static void toHistoryList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  static void toPhoto(BuildContext context, VideoData data) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ImagePage(path: data.path ?? '')),
    );
  }

  static void toPlay(
    BuildContext context,
    List<VideoData> list,
    int idx,
    EventValue form,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayPage(list: list, index: idx, form: form),
      ),
    );
  }

  static void toVideoEdit(BuildContext context, VideoData data) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => EditContentPage(
          data: data,
          doneTap: (path) {
            data.path = path;
            DataTool.update(type: DataType.video, values: data.toMap());
            BusTool.send(AppInfo.busHome);
            BusTool.send(AppInfo.busHistory);
          },
        ),
      ),
    );
  }

  static void toUploadSelect(BuildContext context) {
    SmartDialog.show(
      clickMaskDismiss: false,
      maskColor: Color(0xB3000000),
      alignment: Alignment.bottomCenter,
      builder: (_) {
        return SystemSelectPage();
      },
    );
  }

  static void toEditList(BuildContext context) {
    SmartDialog.show(
      clickMaskDismiss: false,
      maskColor: Color(0xB3000000),
      alignment: Alignment.bottomCenter,
      builder: (_) {
        return EditListPage();
      },
    );
  }

  static void toMoreWidget(BuildContext context, VideoData data) {
    SmartDialog.show(
      clickMaskDismiss: false,
      maskColor: Color(0xB3000000),
      alignment: Alignment.bottomCenter,
      builder: (_) {
        return InfoWidget(data: data);
      },
    );
  }

  static void toInfoDetailWidget(BuildContext context, VideoData data) {
    SmartDialog.show(
      clickMaskDismiss: false,
      maskColor: Color(0xB3000000),
      alignment: Alignment.bottomCenter,
      builder: (_) {
        return InfoDetailWidget(data: data);
      },
    );
  }

  static void back(BuildContext context) {
    Navigator.pop(context);
  }
}
