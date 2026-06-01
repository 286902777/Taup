import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../generated/assets.dart';

enum ToastType {
  none('none'),
  success(Assets.assetsSuccess),
  warning(Assets.assetsWarning),
  fail(Assets.assetsFail);

  final String value;

  const ToastType(this.value);
}

class ToastTool {
  static void show(String msg, {ToastType type = ToastType.none}) {
    SmartDialog.showToast(
      msg,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(maxWidth: 220, maxHeight: 200),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xBF666666),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (type != ToastType.none)
                Image.asset(
                  type.value,
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                ),
              if (type != ToastType.none) SizedBox(width: 4),
              Flexible(
                child: Text(
                  msg,
                  style: TextStyle(
                    color: Color(0xFFFCFCFF),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 10,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
      displayType: SmartToastType.normal,
      displayTime: Duration(seconds: 2),
      alignment: Alignment.center,
    );
  }
}
