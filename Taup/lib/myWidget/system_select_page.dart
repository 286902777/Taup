import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:taup/data/local_file_data.dart';
import 'package:taup/data/video_data.dart';
import 'package:taup/tool/data_tool.dart';
import 'package:taup/tool/toast_tool.dart';

import '../generated/assets.dart';
import '../tool/bus_tool.dart';
import '../tool/config_tool.dart';

class SystemSelectPage extends StatefulWidget {
  const SystemSelectPage({super.key});

  @override
  State<SystemSelectPage> createState() => _SystemSelectPageState();
}

class _SystemSelectPageState extends State<SystemSelectPage> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 278,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(16, 4, 16, 42),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          image: DecorationImage(
            image: AssetImage('assets/alert_bg.png'),
            fit: BoxFit.cover, // 覆盖全屏，保持比例
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Import Video',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  Spacer(),
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
            SizedBox(
              height: 176,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: subItem(true)),
                  SizedBox(width: 9),
                  Expanded(child: subItem(false)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget subItem(bool video) {
    return GestureDetector(
      onTap: () {
        clickItem(video);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Color(0x16FFFFFF),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              video ? Assets.assetsVideoIcon : Assets.assetsFileIcon,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 24),
            Text(
              video ? 'Videos' : 'File',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void clickItem(bool video) async {
    final LocalFileData? data = await showFile(video);
    if (data != null) {
      BusTool.send(AppInfo.busHome);
    }
  }

  // Future<bool> saveVideo(LocalFileData data) async {
  //   try {
  //     final path = File('${ConfigTool.instance.directory}/myApp${data.path}');
  //     if (!path.existsSync()) {
  //       await path.create(recursive: true);
  //       await path.copy(data.filePath);
  //       print('文件: ${data.filePath}');
  //       if (await path.exists()) {
  //         final size = await path.length();
  //         print('文件复制成功: ${path.path}, 大小: $size bytes');
  //       }
  //       VideoData mod = data.toVideo();
  //       mod.local = true;
  //       mod.size = data.size;
  //       if (data.type == DocumentType.image) {
  //         mod.video = false;
  //       } else {
  //         mod.video = true;
  //       }
  //       DataTool.insert(type: .video, map: mod.toMap());
  //       return true;
  //     } else {
  //       ToastTool.show('File already exists!', type: ToastType.fail);
  //     }
  //     return false;
  //   } catch (e) {
  //     ToastTool.show('Save failed', type: ToastType.fail);
  //     return false;
  //   }
  // }

  Future<LocalFileData?> showFile(bool video) async {
    LocalFileData? data = await pickFiles(video);
    return data;
  }

  static Future<LocalFileData?> pickFiles(bool video) async {
    FileType fileType = video ? FileType.media : FileType.custom;
    const fileExtensions = ['m3u8', 'mov', 'mp4'];
    List<String>? allowedExtensions = video ? null : fileExtensions;
    FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: fileType,
      allowedExtensions: allowedExtensions,
    );
    if (result == null) return null;
    final item = result.xFiles.first;
    final size = await item.length();
    final data = LocalFileData.create(
      fileName: item.name,
      filePath: item.path,
      size: size,
    );
    try {
      final path = File('${ConfigTool.instance.directory}/myApp${data.path}');
      if (!path.existsSync()) {
        await path.create(recursive: true);
        await File(item.path).copy(path.path);
        print('文件: ${item.path}, ${item.path.length}');
        if (await path.exists()) {
          final size = await path.length();
          print('文件复制成功: ${path.path}, 大小: $size bytes');
        }
        VideoData mod = data.toVideo();
        mod.local = true;
        mod.size = data.size;
        if (data.type == DocumentType.image) {
          mod.video = false;
        } else {
          mod.video = true;
        }
        DataTool.insert(type: .video, map: mod.toMap());
        return data;
      } else {
        ToastTool.show('File already exists!', type: ToastType.fail);
        return null;
      }
    } catch (e) {
      ToastTool.show('Save failed', type: ToastType.fail);
      return null;
    }
  }
}
