import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:taup/data/video_data.dart';
import 'package:taup/tool/time_tool.dart';

import '../generated/assets.dart';
import '../tool/config_tool.dart';

class HomeHistoryCell extends StatelessWidget {
  final VideoData data;
  final Function() clickTap;
  const HomeHistoryCell({
    super.key,
    required this.data,
    required this.clickTap,
  });

  Future<Uint8List?> _loadThumbnail() async {
    try {
      return await ConfigTool.getThumbnail(data.path ?? '');
    } catch (e) {
      print('获取缩略图失败: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: clickTap,
      child: SizedBox(
        width: 192,
        child: Column(
          children: [
            Stack(
              children: [
                Positioned(
                  child: FutureBuilder<Uint8List?>(
                    future: _loadThumbnail(),
                    builder: (context, snapshot) {
                      // 加载中
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 108,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }
                      // 加载完成
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 108,
                          child: snapshot.hasData && snapshot.data != null
                              ? Image.memory(
                                  snapshot.data!,
                                  width: 192,
                                  height: 108,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 40,
                                        color: Colors.white54,
                                      ),
                                    );
                                  },
                                )
                              : SizedBox.shrink(),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Image.asset(
                      Assets.assetsPlayIcon,
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (data.duration > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      height: 14,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        color: Color(0x8004140A),
                      ),
                      child: Text(
                        TimeTool.formatString(data.duration),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 9,
                          color: Color(0xFFFFFFFF),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                data.fileName,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
