import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:taup/data/video_data.dart';
import 'package:taup/tool/config_tool.dart';

import '../tool/time_tool.dart';

class HistoryCell extends StatelessWidget {
  final VideoData data;
  final Function() clickTap;
  const HistoryCell({super.key, required this.data, required this.clickTap});

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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 90,
        child: Row(
          children: [
            // 缩略图
            data.video
                ? SizedBox(
                    width: 120,
                    height: 90,
                    child: Stack(
                      children: [
                        FutureBuilder<Uint8List?>(
                          future: _loadThumbnail(),
                          builder: (context, snapshot) {
                            // 加载中
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[800],
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
                              child: Container(
                                width: 120,
                                height: 90,
                                color: Colors.grey[800],
                                child: snapshot.hasData && snapshot.data != null
                                    ? Image.memory(
                                        snapshot.data!,
                                        width: 120,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 40,
                                                  color: Colors.white54,
                                                ),
                                              );
                                            },
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.video_library,
                                          size: 40,
                                          color: Colors.white54,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        if (data.duration > 0)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              height: 14,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
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
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(
                        '${ConfigTool.instance.directory}/myApp${data.path}',
                      ),
                      width: 120,
                      height: 90,
                      fit: BoxFit.cover, // 图片填充方式
                    ),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.fileName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color(0xFFFFFFFF),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.videoInfo,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0x80FFFFFF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
