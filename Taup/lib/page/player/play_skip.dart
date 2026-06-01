import 'package:flutter/material.dart';

import '../../../generated/assets.dart';

class PlaySkip extends StatelessWidget {
  final bool isRewind;

  const PlaySkip({super.key, required this.isRewind});

  @override
  Widget build(BuildContext context) {
    final path = isRewind ? Assets.assetsForwardIcon : Assets.assetsRewindIcon;
    final name = '10s';
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 138,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0x50000000),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(path, width: 20, height: 20),
            const SizedBox(width: 4),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
