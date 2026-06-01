import 'package:flutter/material.dart';
import 'package:taup/tool/open_tool.dart';

import '../generated/assets.dart';

class BasePage extends StatelessWidget {
  final Widget child;
  final bool isBtn;
  const BasePage({super.key, required this.child, this.isBtn = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: AssetImage('assets/start_bg.png'),
              fit: BoxFit.cover, // 覆盖全屏，保持比例
            ),
          ),
        ),
        child,
        if (isBtn == true)
          Positioned(
            right: 16,
            bottom: 58,
            child: GestureDetector(
              onTap: () {
                OpenTool.toUploadSelect(context);
              },
              child: Image.asset(
                Assets.assetsAdd,
                width: 88,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }
}
