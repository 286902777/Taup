import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:taup/tool/open_tool.dart';

import '../generated/assets.dart';
import '../tool/config_tool.dart';
import 'base_page.dart';

class ImagePage extends StatefulWidget {
  final String path;
  const ImagePage({super.key, required this.path});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  @override
  Widget build(BuildContext context) {
    final isUrl = widget.path.startsWith('http');
    return BasePage(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appNavbar(),
          body: Container(
            alignment: Alignment.center,
            child: isUrl
                ? CachedNetworkImage(imageUrl: widget.path)
                : Image.file(
                    File(
                      '${ConfigTool.instance.directory}/myApp${widget.path}',
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  AppBar appNavbar() {
    return AppBar(
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
    );
  }
}
