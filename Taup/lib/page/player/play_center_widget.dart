import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:taup/page/player/play_controller.dart';

import '../../data/video_data.dart';
import '../../generated/assets.dart';

class PlayCenterWidget extends StatefulWidget {
  final VideoData video;
  final PlayController controller;

  const PlayCenterWidget({
    super.key,
    required this.video,
    required this.controller,
  });

  @override
  State<PlayCenterWidget> createState() => _PlayCenterWidgetState();
}

class _PlayCenterWidgetState extends State<PlayCenterWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Watch.builder(
                builder: (ctx) {
                  final unBefore = widget.controller.playIndex.value == 0;
                  return SizedBox(
                    width: 56,
                    height: 56,
                    child: Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.controller.videoPlayPrevious,
                        child: Image.asset(
                          unBefore
                              ? Assets.assetsPlayUnBefore
                              : Assets.assetsPlayBefore,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Watch.builder(
                builder: (ctx) {
                  final path = widget.controller.playPlaying.value
                      ? Assets.assetsPlayPause
                      : Assets.assetsPlayPlay;
                  return SizedBox(
                    width: 88,
                    height: 88,
                    child: Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.controller.videoPlayOrPause,
                        child: Image.asset(path, width: 56, height: 56),
                      ),
                    ),
                  );
                },
              ),
              Watch.builder(
                builder: (ctx) {
                  final count = widget.controller.playListCount.value - 1;
                  final index = widget.controller.playIndex.value;
                  final unNext = count == index;
                  return SizedBox(
                    width: 56,
                    height: 56,
                    child: Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.controller.videoPlayNext,
                        child: Image.asset(
                          unNext
                              ? Assets.assetsPlayUnNext
                              : Assets.assetsPlayNext,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
