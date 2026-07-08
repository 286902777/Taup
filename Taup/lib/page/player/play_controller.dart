import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:signals/signals_flutter.dart';
import 'package:taup/tool/bus_tool.dart';
import 'package:taup/tool/data_tool.dart';
import 'package:taup/tool/open_tool.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../data/video_data.dart';
import '../../tool/config_tool.dart';
import '../../tool/event_tool.dart';

enum PlayLoadType { none, load, cache }

enum PlayPopupType {
  none,
  product,
  page,
  position,
  brightness,
  volume,
  rewind,
  forward,
  speed,
}

class PlayController {
  late final Player player = Player();
  late final VideoController controller = VideoController(player);

  List<VideoData> videoList = [];
  final loadType = signal<PlayLoadType>(PlayLoadType.none);
  final popupType = signal<PlayPopupType>(PlayPopupType.none);
  final showTool = signal<bool>(false);
  final brightness = signal<double>(0.0);
  final playIndex = signal<int>(0);
  final playPlaying = signal<bool>(false);
  final playDuration = signal<int>(0);
  final playPosition = signal<int>(0);
  final playVolume = signal<double>(0);
  final playSpeed = signal<double>(1);
  final playListCount = signal<int>(0);
  final double minS = 0.35;
  final double maxE = 0.65;
  final double dragSp = 0.005;

  // PlayCountLimiter? playLimiter;
  Timer? _timer; //定时器
  final List<StreamSubscription<dynamic>> _playerSubscriptions = [];
  double? _rateBeforeLongPress;
  // ChannelData? opChannel; //运营推荐
  Size viewSize = const Size(0, 0);
  DeviceOrientation orientation = DeviceOrientation.portraitUp; //屏幕方向

  VideoData get playData => videoList[playIndex.value]; // 播放数据
  EventValue adValue = EventValue.play;
  bool isHistory = false;

  /// 初始化
  void initState({
    required EventValue value,
    required bool history,
    required List<VideoData> list,
    required int index,
  }) {
    videoList = list;
    isHistory = history;
    playListCount.value = videoList.length;
    _bindPlayerStreams();
    playVideo(index: index, value: value, auto: false);
    ConfigTool.instance.toPlaySceen = true;
    WakelockPlus.enable();
    VolumeController.instance.showSystemUI = false;
    // loadRecommendVideoList();
    VolumeController.instance.addListener((volume) {
      playVolume.value = volume;
    });
    // playLimiter = PlayCountLimiter.limiter(
    // playFun: (play) {
    // play ? playerCtr?.play() : playerCtr?.pause();
    // loadType.value = play ? PlayLoadType.none : PlayLoadType.load;
    // },
    // );
  }

  /// 销毁
  void dispose() async {
    _timer?.cancel();
    for (final subscription in _playerSubscriptions) {
      await subscription.cancel();
    }
    _playerSubscriptions.clear();
    // playLimiter?.dispose();
    WakelockPlus.disable();
    VolumeController.instance.showSystemUI = true;
    VolumeController.instance.removeListener();
    BusTool.send(AppInfo.busHistory);
    ConfigTool.instance.toPlaySceen = false;
    ScreenBrightness.instance.resetApplicationScreenBrightness();
    // MaxTool.instance.display(
    //   scene: EventValue.playback,
    //   source: EventValue.play,
    //   videoData: playData,
    // );
    if (orientation == DeviceOrientation.landscapeRight) {
      orientation = DeviceOrientation.portraitUp;
      await SystemChrome.setPreferredOrientations([orientation]);
    }
    await player.dispose();
  }

  void _bindPlayerStreams() {
    if (_playerSubscriptions.isNotEmpty) return;

    _playerSubscriptions.addAll([
      player.stream.buffering.listen((bool buffer) {
        loadType.value = buffer ? PlayLoadType.cache : PlayLoadType.none;
      }),
      player.stream.videoParams.listen((VideoParams para) {
        final w = para.w ?? 0;
        final h = para.h ?? 0;
        if (w > 0 && h > 0) {
          loadType.value = PlayLoadType.none;
        }
      }),
      player.stream.position.listen((Duration position) async {
        playPosition.value = position.inSeconds;
        playData.position = position.inSeconds;
      }),
      player.stream.duration.listen((Duration duration) {
        playDuration.value = duration.inSeconds;
        playData.duration = duration.inSeconds;
        saveHistoryVideo();
      }),
      player.stream.playing.listen((bool playing) {
        playPlaying.value = playing;
      }),
      player.stream.completed.listen((bool completed) async {
        if (completed) {
          playPlaying.value = false;
          videoPlayNext(auto: true);
        }
      }),
    ]);
  }

  /// 播放视频
  void playVideo({
    required int index,
    required EventValue value,
    required bool auto,
  }) async {
    if (videoList.isEmpty || index < 0 || index >= videoList.length) return;

    playIndex.value = index;
    final data = playData;
    if (data.recommend == true) {
      ConfigTool.instance.currentEmail = '';
    } else {
      ConfigTool.instance.currentEmail = '';
    }
    adValue = value;
    loadType.value = PlayLoadType.load;
    final EventValue method = auto ? EventValue.auto : EventValue.click;
    EventTool.otherTabEvent(
      event: EventName.playStart,
      method: method,
      data: data,
    );
    // _disPlayAds(scene: value);
    showOrHiddenToolWidget(true);

    try {
      final startPosition =
          data.position > 0 &&
              (data.duration == 0 || data.position < data.duration)
          ? Duration(seconds: data.position)
          : null;
      if (data.path != null) {
        final path = '${ConfigTool.instance.directory}/myApp${data.path}';
        await player.open(
          startPosition == null
              ? Media(path)
              : Media(path, start: startPosition),
          play: false,
        );
      } else {
        // if (playData.url == null) {
        //   final String? res = await HttpsApi.downloadFileUrl(playData);
        //   playData.url = res;
        // }
        if (data.url != null) {
          final url = data.url ?? '';
          await player.open(
            startPosition == null
                ? Media(url)
                : Media(url, start: startPosition),
            play: false,
          );
        } else {
          throw StateError('Missing media source');
        }
      }
      await player.play();
    } catch (e) {
      final code = e.hashCode.toString();
      loadType.value = PlayLoadType.none;

      EventTool.otherTabEvent(
        event: EventName.playFail,
        value: code,
        data: data,
      );
    }
    // final video = playerCtr?.value;
    // if (video == null || loadType.value == PlayLoadType.load) return;
    // if (MaxTool.instance.showAd == true ||
    //     popupType.value == PlayPopupType.product ||
    //     popupType.value == PlayPopupType.page) {
    //   playerCtr?.pause();
    //   playPlaying.value = false;
    //   return;
    // }
    // final positionSeconds = video.position.inSeconds;
    // playPlaying.value = video.isPlaying;
    // if (video.isPlaying) {
    //   reBuild.value = video.isPlaying;
    // }
    // playPosition.value = positionSeconds;
    // playData.position = positionSeconds;
    // loadType.value = video.isBuffering
    //     ? PlayLoadType.cache
    //     : PlayLoadType.none;
    // if (video.duration.inSeconds == 0) return;
    // // 播放完成 下一曲
    // if (video.isCompleted == true) {
    //   videoPlayNext(auto: true);
    //   return;
    // }
    //
    // if (isDocument == true || popupType.value == PlayPopupType.product) return;
    // playLimiter?.playProgressMonitoring(positionSeconds);
    // // 播放中的广告触发
    // final playTime = video.position.inSeconds;
    // final adConfig = MaxTool.instance.adConfig;
    // final playAdTime = adConfig.playAdTime;
    // if (ConfigTool.instance.playCount >= adConfig.playCount &&
    //     playTime >= adConfig.playTime &&
    //     adConfig.play.isNotEmpty) {
    //   _disPlayPlayingAd(
    //     scene: EventValue.play,
    //     source: EventValue.native,
    //   );
    // } else {
    //   if (playTime == 0 || playTime % playAdTime != 0) return;
    //   _disPlayPlayingAd(scene: EventValue.play_ten);
    // }
  }

  /// 上一曲
  void videoPlayPrevious() {
    if (playIndex.value == 0 || loadType.value == PlayLoadType.load) return;
    final index = playIndex.value - 1;
    playVideo(index: index, value: EventValue.playlist_next, auto: false);
  }

  /// 下一曲
  void videoPlayNext({bool auto = false}) {
    saveHistoryVideo();
    final index = playIndex.value + 1;
    if (index == videoList.length || loadType.value == PlayLoadType.load) {
      return;
    }
    playVideo(index: index, value: EventValue.playlist_next, auto: auto);
  }

  /// 返回
  void goBack(BuildContext context) async {
    if (orientation == DeviceOrientation.landscapeRight) {
      orientation = DeviceOrientation.portraitUp;
      await SystemChrome.setPreferredOrientations([orientation]);
      return;
    }
    OpenTool.back(context);
  }

  void clickAccelerate() async {
    player.pause();
    popupType.value = PlayPopupType.product;
    if (orientation == DeviceOrientation.landscapeRight) {
      orientation = DeviceOrientation.portraitUp;
      await SystemChrome.setPreferredOrientations([orientation]);
    }
    // Get.to(() => VipPage(source: EventValue.accelerate, click: true))?.then((
    //     result,
    //     ) {
    //   popupType.value = PlayPopupType.none;
    // });
  }

  void popAction() {
    player.pause();
    popupType.value = PlayPopupType.product;
    // SmartDialog.show(
    //   clickMaskDismiss: false,
    //   maskColor: Color(0x65000000),
    //   alignment: isFull ? Alignment.center : Alignment.bottomCenter,
    //   builder: (_) {
    //     return VipPop(
    //       isFull: isFull,
    //       source: EventValue.play,
    //       closeAction: () {
    //         popupType.value = PlayPopupType.none;
    //       },
    //     );
    //   },
    // );
  }

  void goVip() async {
    player.pause();
    popupType.value = PlayPopupType.product;
    if (orientation == DeviceOrientation.landscapeRight) {
      orientation = DeviceOrientation.portraitUp;
      await SystemChrome.setPreferredOrientations([orientation]);
    }
    // Get.to(() => VipPage(source: EventValue.play, click: true))?.then((
    //     result,
    //     ) {
    //   popupType.value = PlayPopupType.none;
    // });
  }

  /// 视频屏幕旋转
  void videoRotate() async {
    if (orientation == DeviceOrientation.portraitUp) {
      orientation = DeviceOrientation.landscapeRight;
    } else {
      orientation = DeviceOrientation.portraitUp;
    }
    await SystemChrome.setPreferredOrientations([orientation]);
  }

  /// 播放列表
  void videoShowList() {
    // showModalBottomSheet(
    //   context: Get.context!,
    //   isScrollControlled: false,
    //   isDismissible: true,
    //   backgroundColor: Colors.transparent,
    //   constraints: BoxConstraints(
    //     // 关键！
    //     maxWidth: MediaQuery.of(Get.context!).size.width,
    //   ),
    //   builder: (context) {
    //     return VideoListWidget(orientation: orientation, controller: this);
    //   },
    // );
  }

  /// 播放或暂停
  void videoPlayOrPause() {
    if (playPlaying.value == true) {
      player.pause();
    } else {
      if (player.state.completed == true) {
        player.seek(Duration(seconds: 0));
      }
      player.play();
    }
  }

  void showRateWidget() {
    // showOrHiddenToolWidget(false);
    // showModalBottomSheet(
    //   context: Get.context!,
    //   isScrollControlled: true,
    //   isDismissible: true,
    //   backgroundColor: Colors.transparent,
    //   constraints: BoxConstraints(
    //     // 关键！
    //     maxWidth: MediaQuery.of(Get.context!).size.width,
    //   ),
    //   builder: (context) {
    //     return VideoRateWidget(
    //       rate: playSpeed.value,
    //       orientation: orientation,
    //       onTap: clickRateAction,
    //     );
    //   },
    // );
  }

  void clickRateAction(double rate) {
    updatePlaybackSpeed(rate);
  }

  /// 更新播放速度
  void updatePlaybackSpeed(double value) async {
    if (player.state.playing == false) return;
    playSpeed.value = value;
    await player.setRate(value);
    player.play();
  }

  ///  播放进度开始拖动
  // void videoOnChangeStart(double size) {
  //   if (playerCtr?.value.isInitialized == false) return;
  //   popupType.value = PlayPopupType.position;
  //   showOrHiddenToolWidget(true);
  // }

  void videoOnChangeStart() {
    if (player.state.playing == false) return;
    popupType.value = PlayPopupType.position;
    showOrHiddenToolWidget(true);
  }

  // /// 播放进度拖动更新
  // void videoPlayChanged(double value) {
  //   if (playerCtr?.value.isInitialized == false) return;
  //   final duration = playerCtr!.value.duration;
  //   final progress = duration.inMilliseconds * value;
  //   playerCtr?.seekTo(Duration(milliseconds: progress.toInt()));
  // }

  ///  播放进度结束拖动
  void videoOnChangeEnd() {
    popupType.value = PlayPopupType.none;
    player.play();
  }

  /// 视频单击
  void playSingOnTap() {
    showOrHiddenToolWidget(!showTool.value);
  }

  /// 视频双击
  void playDoubleTapDown(TapDownDetails details) {
    if (player.state.playing == false) return;
    final controller = player;
    final touchX = details.localPosition.dx;
    if (touchX < viewSize.width * 0.35) {
      // 快退
      popupType.value = PlayPopupType.rewind;
      final second = player.state.position.inSeconds;
      final current = Duration(seconds: second - 10);
      controller.seek(current);
      Future.delayed(const Duration(seconds: 2)).then((_) {
        popupType.value = PlayPopupType.none;
      });
    } else if (touchX > viewSize.width * 0.65) {
      // 快进
      popupType.value = PlayPopupType.forward;
      final second = controller.state.position.inSeconds;
      final current = Duration(seconds: second + 10);
      controller.seek(current);
      Future.delayed(const Duration(seconds: 2)).then((_) {
        popupType.value = PlayPopupType.none;
      });
    } else {
      // 播放暂停
      videoPlayOrPause();
    }
    showOrHiddenToolWidget(true);
  }

  /// 垂直滑动开始事件
  void playVerticalStartEvent(DragStartDetails details) async {
    if (player.state.playing == false) return;
    final touchDx = details.localPosition.dx;
    if (details.localPosition.dy > viewSize.height * 0.8) {
      return;
    }
    if (touchDx < viewSize.width * 0.35) {
      brightness.value = await ScreenBrightness.instance.application;
      popupType.value = PlayPopupType.brightness;
    } else if (touchDx > viewSize.width * 0.65) {
      // playVolume.value = playerCtr?.value.volume ?? 0.0;
      playVolume.value = await VolumeController.instance.getVolume();
      popupType.value = PlayPopupType.volume;
    }
    showOrHiddenToolWidget(true);
  }

  /// 垂直滑动变化事件
  void playVerticalUpdateEvent(DragUpdateDetails details) async {
    if (player.state.playing == false) return;
    final touchDx = details.localPosition.dx;
    if (details.localPosition.dy > viewSize.height * 0.8) {
      return;
    }
    if (touchDx < viewSize.width * 0.35) {
      // 调整亮度值
      double value = brightness.value;
      value = (value - details.delta.dy * 0.005).clamp(0.0, 1.0);
      brightness.value = value;
      ScreenBrightness.instance.setApplicationScreenBrightness(value);
    } else if (touchDx > viewSize.width * 0.65) {
      // 调整音量值
      double volume = playVolume.value;
      volume = (volume - details.delta.dy * 0.005).clamp(0.0, 1.0);
      playVolume.value = volume;
      VolumeController.instance.setVolume(volume);
      player.setVolume(volume);
    }
  }

  /// 垂直滑动结束
  void playVerticalEndEvent(DragEndDetails details) {
    popupType.value = PlayPopupType.none;
  }

  /// 长按快进
  void playLongPressStartEvent(LongPressStartDetails details) {
    if (player.state.playing == false) return;
    if (playSpeed.value == 2.0) return;
    double touchDx = details.localPosition.dx;
    if (touchDx > viewSize.width * minS && touchDx < viewSize.width * maxE) {
      _rateBeforeLongPress = playSpeed.value;
      playSpeed.value = 2.0;
      player.setRate(2.0);
    }
    showOrHiddenToolWidget(true);
  }

  void playLongPressEndEvent(LongPressEndDetails details) {
    final previousRate = _rateBeforeLongPress;
    if (previousRate == null) return;
    _rateBeforeLongPress = null;
    playSpeed.value = previousRate;
    player.setRate(previousRate);
  }

  /// 保存历史
  void saveHistoryVideo() async {
    playData.history = true;
    final map = playData.toMap();
    await DataTool.update(type: DataType.video, values: map);
  }

  void showOrHiddenToolWidget(bool show) {
    showTool.value = show;
    if (show == true) {
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 5), () {
        if (popupType.value != PlayPopupType.none) {
          showOrHiddenToolWidget(true);
        } else {
          showTool.value = false;
        }
      });
    }
  }
}
