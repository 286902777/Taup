import 'package:flutter/material.dart';

import '../../data/video_data.dart';
import '../../generated/assets.dart';

class PlayTitle extends StatelessWidget {
  final VideoData video;
  final Function() goBack;
  final Function() goVip;

  const PlayTitle({
    super.key,
    required this.video,
    required this.goBack,
    required this.goVip,
  });

  @override
  Widget build(BuildContext context) {
    final titlePadding = MediaQuery.paddingOf(context);
    final double t = (titlePadding.top == 0 ? 16 : titlePadding.top);
    final double l = (titlePadding.left == 0 ? 16 : titlePadding.left);
    final double r = (titlePadding.right == 0 ? 16 : titlePadding.right);
    return Container(
      alignment: Alignment.topCenter,
      height: t + 56,
      padding: EdgeInsets.only(left: l, right: r, top: t),
      child: Row(
        children: [
          GestureDetector(
            onTap: goBack,
            child: Image.asset(Assets.assetsPlayBack, width: 24, height: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              video.fileName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Color(0xFFFFFFFF),
              ),
              textAlign: TextAlign.start,
            ),
          ),
          // SizedBox(width: 12),
          // GestureDetector(
          //   onTap: goVip,
          //   child: Image.asset(
          //     Assets.assetVipNavBtn,
          //     width: 54,
          //     height: 24,
          //     fit: BoxFit.cover,
          //   ),
          // ),
        ],
      ),
    );
  }
}
