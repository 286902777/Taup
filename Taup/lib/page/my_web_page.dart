import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../generated/assets.dart';
import '../tool/open_tool.dart';
import 'base_page.dart';

enum WebLink {
  privacy('https://bxxx.com/privacy/'), //文档
  terms('https://bxxx.com/terms/'); //任务

  final String value;

  const WebLink(this.value);
}

class MyWebPage extends StatefulWidget {
  final WebLink link;
  const MyWebPage({super.key, required this.link});

  @override
  State<MyWebPage> createState() => _MyWebPageState();
}

class _MyWebPageState extends State<MyWebPage> {
  late final WebViewController _controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = WebViewController();
    _controller.loadRequest(Uri.parse(widget.link.value));
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      isBtn: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: navBar(),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }

  AppBar navBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              OpenTool.back(context);
            },
            child: Image.asset(
              Assets.assetsBack,
              width: 56,
              height: 24,
              fit: BoxFit.fitHeight,
            ),
          ),
        ],
      ),
    );
  }
}
