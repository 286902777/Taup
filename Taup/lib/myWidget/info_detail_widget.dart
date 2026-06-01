import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:path/path.dart' as path;

import '../data/video_data.dart';
import '../generated/assets.dart';
import '../tool/config_tool.dart';
import '../tool/time_tool.dart';

class InfoDetailWidget extends StatefulWidget {
  final VideoData data;
  const InfoDetailWidget({super.key, required this.data});

  @override
  State<InfoDetailWidget> createState() => _InfoDetailWidgetState();
}

class _InfoDetailWidgetState extends State<InfoDetailWidget> {
  @override
  Widget build(BuildContext context) {
    String extension = path
        .extension(widget.data.filePath)
        .replaceAll('.', '')
        .toUpperCase();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Info',
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
            SizedBox(height: 8),
            Text(
              widget.data.fileName,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xBFFFFFFF),
              ),
              maxLines: 2,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 15),
            const Divider(height: 1, color: Color(0x16FFFFFF)),
            SizedBox(height: 15),
            _buildMenuItem(
              icon: 'Size',
              title: ConfigTool.formatFileSize(widget.data.size),
            ),
            SizedBox(height: 16),
            _buildMenuItem(icon: 'Format', title: extension),
            SizedBox(height: 16),
            _buildMenuItem(icon: 'Path', title: 'CameraRoll'),
            SizedBox(height: 16),
            _buildMenuItem(
              icon: 'Modified',
              title: TimeTool.formatYmd(widget.data.time),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({required String icon, required String title}) {
    return SizedBox(
      height: 20,
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              icon,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Color(0xBAFFFFFF),
              ),
            ),
          ),
          Text(
            '|',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Color(0x16FFFFFF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
