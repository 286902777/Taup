import 'dart:io';
import 'dart:typed_data';

import 'package:android_id/android_id.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'bus_tool.dart';
import 'cache_tool.dart';

class ConfigTool {
  static ConfigTool get instance => GetIt.instance<ConfigTool>();

  final memberType = signal(''); //会员类型
  var deferred = false;

  String platform = '';
  String currentEmail = '';
  bool isLoadPage = false;
  String memberDate = ''; //到期时间
  bool canNewUser = false; //新注册用户
  bool trackingStatus = false;
  bool environment = false; //环境
  int playCount = 0; //播放第几个
  int productCount = 0; //显示订阅次数
  int productScreenTime = 0; //订阅页面显示时间
  int productPopTime = 0; //订阅弹出显示时间
  PackageInfo? appInfo; // app信息
  String directory = '';
  String userAdId = ''; // 广告id
  bool toPlaySceen = false; //是否进入播放页面
  List<String> eastHostList = []; //中东地址
  List<String> indiaHostList = []; //印度地址
  BaseDeviceInfo? deviceInfo; //设备信息

  // ChannelData? channelData; //频道数据
  // List<ChannelData> operationList = []; //推荐频道数据
  // String appMaxKey = 'GfQnlat0NBNnAweifSxxL5Z5z8ILJg2xAqWoDCTnH1Mpk0';
  // String appApplovinKey = 'HSeVtfFlzIeMTwr7HcIFtdOX6HmJGTsfaUIV_KON';

  /// 初始化数据
  Future initConfig() async {
    directory = (await getApplicationDocumentsDirectory()).path;
    appInfo = await PackageInfo.fromPlatform();

    deviceInfo = await DeviceInfoPlugin().deviceInfo;
    productCount = CacheTool.getInt(key: AppInfo.cachenProductCountKey);
    productPopTime = CacheTool.getInt(key: AppInfo.cachenProductPopKey);
    productScreenTime = CacheTool.getInt(key: AppInfo.cachenProductScreenKey);
    AppInfo.getUserId();
    // canNewUser = CacheTool.getBool(key: AppInfo.cacheNewUserKey);
    playCount = CacheTool.getInt(key: AppInfo.cachenPlayCountKey);

    // final channelList = await NoteClient.query(
    //   type: NoteType.channel,
    //   limit: 1,
    // );
    // if (channelList.isNotEmpty) {
    //   channelData = ChannelData.dbFromMap(channelList.first);
    // }
  }

  // Future setFireRemoteConfig() async {
  //   FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  //   final adDataString = remoteConfig.getString('max_config');
  //   await MaxTool.instance.updateConfigData(json: adDataString);
  //   final vipInfo = remoteConfig.getString('purchase_Info');
  //   await VipClient.instance.updateProductConfig(vipInfo);
  // }

  /// 请求云控数据
  // Future requestRemoteConfigData() async {
  //   FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  //   const time = Duration(minutes: 1);
  //   await remoteConfig.setConfigSettings(
  //     RemoteConfigSettings(fetchTimeout: time, minimumFetchInterval: time),
  //   );
  //   await setFireRemoteConfig();
  //   remoteConfig.fetchAndActivate();
  // }

  /// 更新频道数据
  // Future updateChannelData(ChannelData data) async {
  //   channelData = data;
  //   final where = 'userId = ?';
  //   final args = [data.userId];
  //   operationList.clear();
  //   await DataTool.delete(type: DataType.channel, where: where, args: args);
  //   await DataTool.insert(
  //     type: DataType.channel,
  //     map: data.toJson(isId: false),
  //   );
  // }

  /// 添加播放次数
  void updatePlayCount(int count) {
    playCount = count;
    CacheTool.saveValue(key: AppInfo.cachenPlayCountKey, value: count);
  }

  /// 弹出订阅弹窗
  static void openPopUp() {
    final can = ConfigTool.instance.canPopProductComponent(isScreen: false);
    if (can == false) return;
    BusTool.send(AppInfo.busProductPop);
  }

  bool canPopProductComponent({required bool isScreen}) {
    if (ConfigTool.instance.productCount > 2) return false;
    if (ConfigTool.instance.memberType.isNotEmpty) return false;
    final time = DateTime.now();
    final xTime = isScreen ? productScreenTime : productPopTime;
    final bTime = isScreen ? productPopTime : productScreenTime;
    final xPoorTime = DateTime.fromMillisecondsSinceEpoch(xTime);
    Duration xDifference = time.difference(xPoorTime);
    if (xDifference.inHours < 24 && xTime > 0) return false;
    final bPoorTime = DateTime.fromMillisecondsSinceEpoch(bTime);
    Duration bDifference = time.difference(bPoorTime);
    if (bDifference.inHours < 1 && bTime > 0) return false;
    // 更新时间
    final updateTime = time.millisecondsSinceEpoch;
    if (isScreen == false) {
      productPopTime = updateTime;
    } else {
      productScreenTime = updateTime;
    }
    productCount = productCount + 1;
    CacheTool.saveValue(
      key: AppInfo.cachenProductPopKey,
      value: productPopTime,
    );
    CacheTool.saveValue(
      key: AppInfo.cachenProductScreenKey,
      value: productScreenTime,
    );
    CacheTool.saveValue(
      key: AppInfo.cachenProductCountKey,
      value: productCount,
    );
    return true;
  }

  /// 请求广告权限
  void addTrack() async {
    if (trackingStatus == true) return;
    final status = await AppTrackingTransparency.requestTrackingAuthorization();
    trackingStatus = (status == TrackingStatus.authorized);
  }

  static void unFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// 显示键盘
  static void showFocus() {
    FocusManager.instance.primaryFocus?.requestFocus();
  }

  static String formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";

    const int kb = 1024;
    const int mb = 1024 * 1024;
    const int gb = 1024 * 1024 * 1024;

    if (bytes < kb) {
      return "$bytes B";
    } else if (bytes < mb) {
      return "${(bytes / kb).toStringAsFixed(2)} KB";
    } else if (bytes < gb) {
      return "${(bytes / mb).toStringAsFixed(2)} MB";
    } else {
      return "${(bytes / gb).toStringAsFixed(2)} GB";
    }
  }

  static String getNoteTopic(dynamic value) {
    if (value is String) {
      return value;
    } else if (value is Map) {
      return '[${value['type']}]';
    } else {
      return '[${value.runtimeType}]';
    }
  }

  static Future<Uint8List?> getThumbnail(String videoPath) async {
    if (videoPath.isEmpty) {
      print('视频路径为空');
      return null;
    }

    try {
      final path = '${ConfigTool.instance.directory}/myApp$videoPath';
      final file = File(path);
      if (!await file.exists()) {
        print('视频文件不存在: $path');
        return null;
      }

      // 使用 video_thumbnail 插件
      final uint8List = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 200,
        quality: 80,
      );

      return uint8List;
    } catch (e) {
      print('生成缩略图失败: $e');
      return null;
    }
  }
}

class AppInfo {
  static const String busHome = 'busHome';
  static const String busHistory = 'busHistory';
  static const String busChannel = 'busChannel';
  static const String busProductPop = 'busProductPop';

  static const String cacheUUIDkey = 'cacheUUIDkey';
  static const String cacheNewUserKey = 'cacheNewUserKey';
  static const String cachenKeychainkey = 'cachenKeychainkey';
  static const String cachenGoogleAdIdkey = 'cachenGoogleAdIdkey';
  static const String cachenTbaHttpkey = 'cachenTbaHttpkey';
  static const String cachenOneOpenKey = 'cachenOneOpenKey';
  static const String cachenOnePlayKey = 'cachenOnePlayKey';
  static const String cachenOneLinkKey = 'cachenOneLinkKey';
  static const String cachenPlayCountKey = 'cachenPlayCountKey';
  static const String cachenProductCountKey = 'cachenProductCountKey';
  static const String cachenProductScreenKey = 'cachenProductScreenKey';
  static const String cachenProductPopKey = 'cachenProductPopKey';

  static Future<String> getUserId() async {
    String deviceID = CacheTool.getString(key: cachenKeychainkey);
    if (deviceID.isEmpty) {
      if (Platform.isAndroid) {
        const androidIdPlugin = AndroidId();
        deviceID = await androidIdPlugin.getId() ?? "";
      } else {
        final storage = const FlutterSecureStorage();
        String? appDeviceID = await storage.read(key: cachenKeychainkey);
        if (appDeviceID == null) {
          appDeviceID = const Uuid().v4();
          storage.write(key: cachenKeychainkey, value: appDeviceID);
          CacheTool.saveValue(key: cacheNewUserKey, value: true);
        }
        deviceID = appDeviceID;
      }
      CacheTool.saveValue(key: cachenKeychainkey, value: deviceID);
    }
    return deviceID;
  }

  /// 获取后台埋点字典
  // static Map<String, dynamic> getReportedData() {
  //   return {
  //     'mxdkyhkiqr': 'v2', //version
  //     'vomity': 'US', //os_country
  //     'aplodontia': ConfigTool.instance.canNewUser ? 1 : 0, //is_nru
  //     'obsequent': InfoKey.getIdfv, //idfv
  //     'whumping': const Uuid().v4(), //log_id
  //     'uncurved': InfoKey.getVersion, //app_version
  //     "cqqguql007": ConfigTool.instance.userAdId, //gaid
  //     "travest": Platform.isIOS ? 'ios' : 'android', //os
  //     'isangoma': InfoKey.getAndroidId, //android_id
  //     'isochlor': InfoKey.getOsVersion, //os_version
  //     'deedier': InfoKey.getDistinctId, //distinct_id
  //     'chinnier': InfoKey.getClientTs, //client_ts
  //     'unplace': InfoKey.getManufacturer, //manufacturer
  //     "pellagric": {"depaints": InfoKey.getBundleId}, //bundle_id
  //   };
  // }
  //
  // /// tba参数ios
  // static Map<String, dynamic> getIosTabData() {
  //   return {
  //     "merge": {
  //       "stumpy": InfoKey.getBundleId,
  //       "baseman": InfoKey.getOs,
  //       "tyrosine": InfoKey.getVersion,
  //       "pray": InfoKey.getDistinctId,
  //       "agitate": InfoKey.getLogId,
  //       "quintus": InfoKey.getClientTs,
  //       "songbook": 'apple',
  //       "garcia": InfoKey.getDeviceModel,
  //       "etude": InfoKey.getOsVersion,
  //       "boogie": InfoKey.getOperator,
  //       "halftone": InfoKey.getLanguage,
  //       "kalmia": InfoKey.getIdfv,
  //     },
  //   };
  // }

  // static AppEventValue getPageValue({
  //   required AppEventValue value,
  //   required bool recommend,
  // }) {
  //   if (recommend == true) {
  //     if (value == AppEventValue.landpage_hot ||
  //         value == AppEventValue.landpage_recently ||
  //         value == AppEventValue.landpage_file) {
  //       return AppEventValue.landpage_recommend;
  //     } else {
  //       return AppEventValue.channel_recommend;
  //     }
  //   }
  //   return value;
  // }
}
