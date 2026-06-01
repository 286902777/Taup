import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:signals/signals_flutter.dart';
import 'package:taup/data/video_data.dart';
import 'package:taup/tool/data_tool.dart';

import '../generated/assets.dart';
import '../tool/bus_tool.dart';
import '../tool/config_tool.dart';

class RenameWidget extends StatefulWidget {
  final VideoData data;
  final Function(String name)? doneTap;
  const RenameWidget({super.key, required this.data, this.doneTap});
  @override
  State<RenameWidget> createState() => RenameWidgetState();
}

class RenameWidgetState extends State<RenameWidget> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final folderText = signal('');

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Color(0xFF262626),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rename',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.only(left: 12),
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Color(0x13FFFFFF),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: 1,
              maxLength: 50,
              scrollPadding: EdgeInsets.zero,
              textInputAction: TextInputAction.done,
              onEditingComplete: focusNode.unfocus,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
              onChanged: (_) {
                folderText.value = controller.text;
              },
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16,
                ), // 调整垂直内边距实现居中
                isDense: false, // 改为 false，让高度更灵活
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0x40FFFFFF),
                ),
                hintText: '',
                suffixIcon: Watch(
                  (ctx) => folderText.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: GestureDetector(
                            onTap: () {
                              controller.clear();
                              folderText.value = '';
                            },
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: Image.asset(
                                Assets.assetsFieldClose,
                                width: 20,
                                height: 20,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Watch(
              (ctx) => Text(
                '${controller.text.length}/50',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                  color: controller.text.length < 50
                      ? Color(0x80FFFFFF)
                      : Color(0xFFFF5858),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    SmartDialog.dismiss();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: Color(0x20FFFFFF),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    doneOnTap();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
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
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      'Comfirm',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color(0xFF04140A),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void doneOnTap() async {
    if (folderText.isEmpty) return;
    focusNode.unfocus();
    final str = controller.text.replaceAll(' ', '');
    if (str.isEmpty) {
      return;
    }
    widget.data.fileName = folderText.value;
    await DataTool.update(type: DataType.video, values: widget.data.toMap());
    widget.doneTap?.call(str);
    BusTool.send(AppInfo.busHome);
    BusTool.send(AppInfo.busHistory);
    SmartDialog.dismiss();
  }
}
