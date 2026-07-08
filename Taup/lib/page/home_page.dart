import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:taup/controller/home_controller.dart';
import 'package:taup/data/video_data.dart';
import 'package:taup/myWidget/home_cell.dart';
import 'package:taup/myWidget/home_history_cell.dart';
import 'package:taup/page/base_page.dart';
import 'package:taup/tool/event_tool.dart';
import 'package:taup/tool/open_tool.dart';

import '../generated/assets.dart';
import '../myWidget/empty_widget.dart';
import '../tool/config_tool.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = HomeController();
  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(const Duration(seconds: 4)).then((v) {
      ConfigTool.instance.addTrack();
    });
    controller.initData();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Watch.builder(
      builder: (ctx) {
        return BasePage(
          isBtn: true,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: navBar(),
            body: Stack(
              children: [
                Positioned(
                  top: 10,
                  left: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      OpenTool.toEditList(context);
                    },
                    child: Container(
                      height: 98,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/edit_bg.png'),
                          fit: BoxFit.fill, // 覆盖全屏，保持比例
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  Assets.assetsStar,
                                  width: 21,
                                  height: 26,
                                  fit: BoxFit.fitWidth,
                                ),
                                SizedBox(width: 6),
                                Image.asset(
                                  Assets.assetsEasy,
                                  width: 129,
                                  height: 24,
                                  fit: BoxFit.fitWidth,
                                ),
                              ],
                            ),
                            Spacer(),
                            Container(
                              width: 52,
                              height: 28,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF86ECC5),
                                    Color(0xFF88F160),
                                    Color(0xFFE2F96B),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                              child: Center(
                                child: Image.asset(
                                  Assets.assetsArrowBlank,
                                  width: 18,
                                  height: 18,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 104,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: controller.hasData.value
                      ? ValueListenableBuilder(
                          valueListenable: controller.valueNotifier,
                          builder: (_, _, _) {
                            return Column(
                              children: [
                                if (controller.historyList.value.isNotEmpty)
                                  _buildHistorySection(),
                                if (controller.localList.value.isNotEmpty)
                                  _buildLibraryHeader(),
                                if (controller.localList.value.isNotEmpty)
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount:
                                          controller.localList.value.length,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (ctx, index) {
                                        final item =
                                            controller.localList.value[index];
                                        return HomeCell(
                                          data: item,
                                          clickTap: () {
                                            if (item.video == true) {
                                              List<VideoData> list = controller
                                                  .localList
                                                  .value
                                                  .where((n) => n.video == true)
                                                  .toList();
                                              int idx = list.indexOf(item);
                                              OpenTool.toPlay(
                                                context,
                                                list,
                                                idx,
                                                EventValue.home,
                                              );
                                            } else {
                                              OpenTool.toPhoto(context, item);
                                            }
                                          },
                                        );
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                            return const SizedBox(height: 8);
                                          },
                                    ),
                                  ),
                              ],
                            );
                          },
                        )
                      : EmptyWidget(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar navBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 16),
          Image.asset(Assets.assetsTaupText, height: 24, fit: BoxFit.fitHeight),
        ],
      ),
      leadingWidth: 180,
      actions: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            OpenTool.toSet(context);
          },
          child: Image.asset(
            Assets.assetsSetIcon,
            width: 56,
            height: 24,
            fit: BoxFit.fitHeight,
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 6, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'History',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  OpenTool.toHistoryList(context);
                },
                child: SizedBox(
                  width: 40,
                  height: 36,
                  child: Center(
                    child: Image.asset(
                      Assets.assetsEnter,
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 136,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            itemCount: controller.historyList.value.length,
            itemBuilder: (context, index) {
              final data = controller.historyList.value[index];
              return HomeHistoryCell(
                data: data,
                clickTap: () {
                  OpenTool.toPlay(
                    context,
                    controller.historyList.value,
                    index,
                    EventValue.history,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLibraryHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Library',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeSliverList extends StatelessWidget {
  final List<VideoData> items;
  final Widget Function(dynamic item, int index) itemBuilder;
  final double separatorHeight;

  const HomeSliverList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separatorHeight = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((ctx, index) {
        final item = items[index];
        return Column(
          children: [
            itemBuilder(item, index),
            if (index != items.length - 1) SizedBox(height: separatorHeight),
          ],
        );
      }, childCount: items.length),
    );
  }
}
