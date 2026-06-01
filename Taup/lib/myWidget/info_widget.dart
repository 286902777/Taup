import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:taup/myWidget/rename_widget.dart';
import 'package:taup/tool/bus_tool.dart';
import 'package:taup/tool/data_tool.dart';
import 'package:taup/tool/open_tool.dart';

import '../data/video_data.dart';
import '../generated/assets.dart';
import '../tool/config_tool.dart';
import 'alert_widget.dart';

class InfoWidget extends StatefulWidget {
  final VideoData data;
  const InfoWidget({super.key, required this.data});

  @override
  State<InfoWidget> createState() => _InfoWidgetState();
}

class _InfoWidgetState extends State<InfoWidget> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 290,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: AssetImage('assets/alert_bg.png'),
            fit: BoxFit.cover, // 覆盖全屏，保持比例
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.data.fileName,
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
            SizedBox(height: 15),
            const Divider(height: 1, color: Color(0x16FFFFFF)),
            SizedBox(height: 5),
            if (widget.data.video)
              _buildMenuItem(
                context,
                icon: Assets.assetsEditIcon,
                title: 'Edit',
                index: 0,
              ),
            _buildMenuItem(
              context,
              icon: Assets.assetsRenameIcon,
              title: 'Rename',
              index: 1,
            ),
            _buildMenuItem(
              context,
              icon: Assets.assetsDeleteIcon,
              title: 'Delete',
              index: 2,
            ),
            _buildMenuItem(
              context,
              icon: Assets.assetsInfoIcon,
              title: 'Info',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        clickItem(context, index);
      },
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            Image.asset(icon, width: 24, height: 24, fit: BoxFit.cover),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void clickItem(BuildContext context, int index) {
    switch (index) {
      case 0:
        OpenTool.toVideoEdit(context, widget.data);
      case 1:
        SmartDialog.show(
          clickMaskDismiss: false,
          maskColor: Color(0xB3000000),
          alignment: Alignment.center,
          builder: (_) {
            return RenameWidget(
              data: widget.data,
              doneTap: (name) {
                widget.data.fileName = name;
                setState(() {});
              },
            );
          },
        );
      case 2:
        SmartDialog.show(
          clickMaskDismiss: false,
          maskColor: Color(0xB3000000),
          alignment: Alignment.center,
          builder: (_) {
            return AlertWidget(title: 'Delete file?', comfirmTap: deleteData);
          },
        );
      default:
        OpenTool.toInfoDetailWidget(context, widget.data);
    }
  }

  void deleteData() {
    DataTool.delete(type: DataType.video, args: [widget.data.id]);
    BusTool.send(AppInfo.busHome);
    BusTool.send(AppInfo.busHistory);
  }
}
