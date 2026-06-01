import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:signals/signals_flutter.dart';
import 'package:taup/tool/open_tool.dart';

import '../controller/home_controller.dart';
import '../generated/assets.dart';
import 'empty_widget.dart';
import 'home_cell.dart';

class EditListPage extends StatefulWidget {
  const EditListPage({super.key});

  @override
  State<EditListPage> createState() => _EditListPageState();
}

class _EditListPageState extends State<EditListPage> {
  final HomeController controller = HomeController();

  @override
  void initState() {
    // TODO: implement initState
    controller.initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Watch(
        (ctx) => Container(
          height: 460,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(0, 20, 0, 42),
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: AssetImage('assets/edit_content.png'),
              fit: BoxFit.cover, // 覆盖全屏，保持比例
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Edit your video',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFFFFFFFF),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(width: 16),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        SmartDialog.dismiss();
                      },
                      child: Image.asset(
                        Assets.assetsAlertClose,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: controller.localVideoList.value.isNotEmpty
                    ? listWidget(context)
                    : EmptyWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listWidget(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 16),
      itemCount: controller.localVideoList.value.length,
      itemBuilder: (ctx, index) {
        final item = controller.localVideoList.value[index];
        return HomeCell(
          data: item,
          isMore: false,
          clickTap: () {
            OpenTool.toVideoEdit(context, item);
          },
        );
      },
      separatorBuilder: (ctx, index) {
        return const SizedBox(height: 8);
      },
    );
  }
}
