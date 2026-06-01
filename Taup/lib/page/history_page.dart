import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:signals/signals_flutter.dart';
import 'package:taup/controller/history_controller.dart';

import '../generated/assets.dart';
import '../myWidget/history_cell.dart';
import '../tool/event_tool.dart';
import '../tool/open_tool.dart';
import 'base_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryController controller = HistoryController();

  @override
  void initState() {
    // TODO: implement initState
    EventTool.otherTabEvent(event: EventName.historyExpose);
    controller.loadData();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appNavbar(),
          body: listWidget(),
        ),
      ),
    );
  }

  AppBar appNavbar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      leading: InkWell(
        splashColor: Colors.transparent, // 水波纹颜色透明
        highlightColor: Colors.transparent, // 高亮颜色透明
        hoverColor: Colors.transparent,
        onTap: () {
          OpenTool.back(context);
        },
        child: Center(
          child: Image.asset(
            Assets.assetsBack,
            width: 20,
            height: 20,
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        'History',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 17,
          color: Color(0xFFFFFFFF),
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        GestureDetector(
          onTap: () {
            controller.deleteVideos();
          },
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Image.asset(
                Assets.assetsCellDelete,
                width: 24,
                height: 24,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(width: 6),
      ],
    );
  }

  Widget listWidget() {
    final wid = MediaQuery.of(context).size.width;
    return Watch(
      (cxt) => ListView.separated(
        cacheExtent: 100,
        itemCount: controller.historyList.value.length,
        padding: EdgeInsets.zero,
        itemBuilder: (ctx, index) {
          final data = controller.historyList.value[index];
          return Slidable(
            key: UniqueKey(),
            // 滑动后显示的动作面板
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              extentRatio: 96 / wid, // 滑动动画效果
              children: [
                GestureDetector(
                  onTap: () async {
                    controller.deleteVideos(item: data);
                  },
                  child: Container(
                    width: 96,
                    decoration: BoxDecoration(color: Color(0xFFFF5858)),
                    child: Center(
                      child: Image.asset(
                        Assets.assetsCellDelete,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            child: HistoryCell(data: data, clickTap: () {}),
          );
        },
        separatorBuilder: (ctx, index) {
          return const SizedBox(height: 8);
        },
      ),
    );
  }
}
