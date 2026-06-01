import 'package:flutter/material.dart';

import '../generated/assets.dart';
import '../tool/open_tool.dart';

class EmptyWidget extends StatefulWidget {
  const EmptyWidget({super.key});

  @override
  State<EmptyWidget> createState() => _EmptyWidgetState();
}

class _EmptyWidgetState extends State<EmptyWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            OpenTool.toUploadSelect(context);
          },
          child: Image.asset(
            Assets.assetsEmpty,
            width: 250,
            height: 250,
            fit: BoxFit.cover,
          ),
        ),
        Text(
          'No content',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0x80FFFFFF),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 36),
        GestureDetector(
          onTap: () {
            OpenTool.toUploadSelect(context);
          },
          child: Container(
            width: 200,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
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
            ),
            child: Center(
              child: Text(
                'Import',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF04140A),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
